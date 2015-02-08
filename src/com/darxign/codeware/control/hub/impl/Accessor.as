package com.darxign.codeware.control.hub.impl {
	import com.darxign.codeware.control.hub.AHub;
	import com.darxign.codeware.control.identification.Id;
	import flash.utils.Dictionary;
	/**
	 * Hub for accessing entities.
	 * It caches entities.
	 * @author darxign
	 */
	public class Accessor extends AHub {
		
		/**
		 * cache for entities
		 */
		protected const storage:Dictionary = new Dictionary()
		
		/**
		 * @inheritDoc
		 */
		public function Accessor(idSize:int, preparator:Function) {
			super(idSize, preparator)
		}
		
		/**
		 * @return	An entity from the storage (creates the entity if it isn't found in the storagee).
		 */
		public final function access(id:Id = null, data:* = null):* {
			this.checkId(id)
			var entity:Object
			if (id && id.getSize() > 0) {
				entity = this.storage[id]				
			} else {
				entity = this.storage[0]
			}
			if (entity == null) {
				entity = this.prepareEntity(id, data)
				this.storage[id] = entity
			}
			return entity
		}
		
	}

}