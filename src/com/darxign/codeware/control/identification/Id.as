package com.darxign.codeware.control.identification {
	import com.darxign.codeware.Common;
	/**
	 * A storage of identifying information.
	 * The identifier consists of a set of "uint" elements.
	 * @author darxign
	 */
	public final class Id {
		
		// THE STATIC PART: intended to serve as an object pool for all the id objects.

		// the key for the constructor's privacy 
		static private const staticKey:Object = new Object()
		
		// the main branch of the object pool itself: contains all the ids of the app.
		static private const trunk:Vector.<IdNode> = new Vector.<IdNode>()
		
		// the Id object that contains no elements
		static private const emptyId:Id = new Id([], Id.staticKey)
		
		// helper array
		static private const _lmnts:Array = []
		
		/**
		 * Single Element Id Extractor.
		 * If it's a new id it's saved in the cache.
		 * @param	element The element for needed Id.
		 * @return	The needed Id.
		 */
		static public function xtr(element:int):Id {
			_lmnts[0] = element
			_lmnts.length = 1
			return xtrm(_lmnts)
		}
		
		/**
		 * Empty Element Id Extractor.
		 * @return	The empty Id.
		 */
		static public function xtre():Id {
			return Id.emptyId
		}
		
		/**
		 * Multiple Elements Id Extractor.
		 * If it's a new id it's saved in the cache.
		 * @param	elements The elements for needed Id.
		 * @return	The needed Id.
		 */
		static public function xtrm(elements:Array):Id {
			
			var lengthUint:uint = elements.length
			if (lengthUint == 0) throw new Error("elements length is 0. If supposed the empty Id use method xtre().")
			if (lengthUint >= int.MAX_VALUE) throw new Error("must be less than int.MAX_VALUE elements")
			if (!Common.oneExactClassOnly(int, elements)) throw new Error("all elements must be int")
			
			var branch:Vector.<IdNode> = Id.trunk
			var node:IdNode = null
			var element:int
			
			for (var i:int = 0, length:int = lengthUint, preLength:int = lengthUint - 1; i < length; i += 1) /* Why to use int length? Geeks say it's faster. */ {
				
				element = elements[i]
				if (element < 0) throw new Error("the element [" + i + "] is less than 0")
				if (element >= int.MAX_VALUE) throw new Error("the max value for an element is (int.MAX_VALUE - 1) but the element [" + i + "] is " + element)
				
				if (branch.length <= element) {
					branch.length = element + 1
				}
				
				node = branch[element]
				if (node == null) {
					node = new IdNode()
					branch[element] = node
				}
				
				if (i < preLength) /* if it's last iteration the branch is not needed */ {
					branch = node.branch
					if (branch == null) {
						branch = new Vector.<IdNode>()
						node.branch = branch
					}
				}
				
			}
			
			var id:Id = node.id
			if (id == null) {
				id = new Id(elements, staticKey)
				node.id = id
			}
			
			return id
		}
		
		/**
		 * Checks if the given id resides among an array containing ids.
		 * @param	id A given id to be checked.
		 * @param	array The array containing ids.
		 * @param	nullElementsEligible Whether null elements should be treated as correct coincidence.
		 * @return	True - if the given id resides among the array; False - otherwise and if the array is empty.
		 */
		static public function isInArray(id:Id, array:Array, nullElementsEligible:Boolean = false):Boolean {
			if (!array) throw new Error("array is null")
			if (array.length == 0) return false
			if (!id && !nullElementsEligible) {
				throw new Error("inbound id is null however null elements aren't allowed")
			}
			for each (var idInArray:Id in array) {
				if (id == idInArray) {
					return true
				}
			}
			return false
		}
		
		/**
		 * Checks if the given id resides among a vector containing ids.
		 * @param	id A given id to be checked.
		 * @param	vector The vector containing ids.
		 * @param	nullElementsEligible Whether null elements should be treated as correct coincidence.
		 * @return	True - if the given id resides among the vector; False - otherwise and if the vector is empty.
		 */
		static public function isInVector(id:Id, vector:Vector.<Id>, nullElementsEligible:Boolean = false):Boolean {
			if (!vector) throw new Error("array is null")
			if (vector.length == 0) return false
			if (!id && !nullElementsEligible) {
				throw new Error("inbound id is null however null elements aren't allowed")
			}
			for each (var idInVector:Id in vector) {
				if (id == idInVector) {
					return true
				}
			}
			return false
		}
		
		// the number of the elements in the Id
		private var size:int
		
		// the id elements themselves
		private var elements:Vector.<int>
		
		/**
		 * Creates an Id.
		 * It can be invoked from the Id.xtr(...).
		 * @param	elements The elements for the id. They are validated in Id.xtr(...) to contain UINT values only.
		 * @param	key The Id.key object. Given to maintain the protection from invoking outside.
		 */
		public function Id(elements:Array, key:Object) {
			Common.checkKeys(staticKey, key)
			this.size = elements.length
			this.elements = new Vector.<int>(this.size, true)
			for (var i:int = 0; i < this.size; i += 1) {
				this.elements[i] = elements[i]
			}
		}
		
		public final function getSize():int {
			return this.size
		}
		
		public final function getElement(index:int):int {
			return this.elements[index]
		}
		
		public final function getElements():Array {
			var result:Array = []
			for (var i:int = 0; i < this.size; i += 1) {
				result[i] = this.elements[i]
			}
			return result
		}
		
		public final function xtrSubId(index:int):Id {
			return Id.xtr(this.elements[index])
		}
		
	}

}