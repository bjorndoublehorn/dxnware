package com.darxign.codeware.control.hub.impl {
	import com.darxign.codeware.control.hub.AHub;
	import com.darxign.codeware.control.identification.Id;
	import flash.utils.Dictionary;
	/**
	 * A pool-container for entities.
	 * Opposed to Accessor it can store many entities under the same Id in so called "cells".
	 * Use method lockEntity() to retrieve an object from cells. The returned object
	 * becomes locked and can't be got again till it's unlocked.
	 * Use method unlockEntity() to unlock the locked object.
	 * You can specify whether the cells are unlimited in the number of objects or not.
	 * If not - what is the maximal number of objects.
	 * Additionally this hub caches entities.
	 * @author darxign
	 */
	public class Locker extends AHub {
		
		// all lockers
		static private const lockers:Array = new Array()
		
		/**
		 * @return true id all the lockers are empty (all enitites unlocked), false otherwise
		 */
		static public function getBusyLockers():Array {
			var busyLockers:Array = []
			for each (var locker:Locker in Locker.lockers) {
				if (locker.getLockedNumber() > 0) {
					busyLockers.push(locker)
				}
			}
			return busyLockers
		}
		
		/**
		 * The size of the cells.
		 * If it is 0 then cells have ulimited capacity.
		 */
		private var cellSize:int
		
		/**
		 * cache for all entities
		 */ 
		private const storage:Dictionary = new Dictionary()
		
		/**
		 * the set of currantly locked objects
		 */
		private const lockSet:Dictionary = new Dictionary()
		
		/**
		 * @inheritDoc
		 * @param	cellSize {@see #cellSize}
		 */
		public function Locker(idSize:int, preparator:Function, cellSize:int = 0) {
			
			super(idSize, preparator)
			
			if (cellSize < 0) throw new Error("cellSize can not be less than 0")
			if (cellSize == int.MAX_VALUE) throw new Error("cellSize must be less than int.MAX_VALUE")
			this.cellSize = cellSize
			
			if (idSize == 0) {
				this.storage[0] = new Cell()
			}
			
			Locker.lockers.push(this)
			
		}
		
		/**
		 * Locks an entity of the storage and returns it.
		 * @param	id The id of the entity to capture.
		 * @return	The captured object.
		 */
		public final function lock(id:Id = null, data:* = null):* {
			
			this.checkId(id)
			
			var cell:Cell
			
			if (id && id.getSize() > 0) {
				cell = this.storage[id]
				if (cell == null) {
					cell = new Cell()
					this.storage[id] = cell
				}
			} else {
				cell = this.storage[0]
			}
			
			// find an unlocked entity from the cell
			var entity:Object
			for (var cellUnit:CellUnit = cell.$head; cellUnit; cellUnit = cellUnit.$next) {
				if (cellUnit.locked) {
					continue
				}
				entity = cellUnit.entity
				cellUnit.locked = true
				this.lockSet[entity] = cellUnit
				return entity
			}
			if (this.cellSize == 0 || cell.$size < this.cellSize) {
				entity = this.prepareEntity(id, data)
				var lockerizedEntity:Lockerized = entity as Lockerized
				if (lockerizedEntity) {
					lockerizedEntity.setLocker(this)
				}
				cellUnit = new CellUnit()
				cellUnit.entity = entity
				cellUnit.locked = true
				cell.addCellUnit(cellUnit)
				this.lockSet[entity] = cellUnit
				return entity
			}
			throw new Error("all the possible entities are locked")
		}
		
		/**
		 * Unlocks a locked entity of the storage
		 * @param	entity
		 */
		public final function unlock(entity:Object):void {
			
			var cellUnit:CellUnit = this.lockSet[entity]
			if (cellUnit != null) {
				cellUnit.locked = false
				this.lockSet[entity] = null
			} else if (entity == null) {
				throw new Error("given entity is null")
			}
		}
		
		/**
		 * @return The nubmer of currantly locked entities
		 */
		public final function getLockedNumber():int {
			var i:int = 0
			for (var x:* in this.lockSet) {
				if (this.lockSet[x] != null) {
					i += 1
				}
			}
			return i
		}
		
		public final function unlockAll():void {
			var lockedEntities:Array = []
			for (var o:* in this.lockSet) {
				lockedEntities[lockedEntities.length] = o
			}
			for each (o in lockedEntities) {
				this.unlock(o)
			}
		}
		
	}

}

class CellUnit {
	
	public var $next:CellUnit
	public var $prev:CellUnit
	
	public var entity:Object
	public var locked:Boolean
	
}

class Cell {
	
	public var $size:int
	public var $head:CellUnit
	public var $tail:CellUnit
	
	public final function addCellUnit(cellUnit:CellUnit):void {
		cellUnit.$prev = this.$tail
		if (this.$tail) {
			this.$tail.$next = cellUnit
		} else {
			this.$head = cellUnit
		}
		this.$tail = cellUnit
		cellUnit.$next = null
		this.$size += 1
	}
	
}