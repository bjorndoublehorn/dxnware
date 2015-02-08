package com.darxign.codeware.control.hub {
	import com.darxign.codeware.control.identification.Id;
	/**
	 * The base class for all the hubs.
	 * A hub is an object which is responsible for creating (and caching if necessary) and returning an entity for a particular id.
	 * The entities are supposed (but not compeled) to be of a certain category to meet a logical condition of the hub.
	 * For example they all can be ShadowFilters tuned specifically for a particular id.
	 * An entity is always of a referential type.
	 * @author darxign
	 */
	public class AHub {
		
		/**
		 * The number of the elements in the id of any entity.
		 * If it is 0 then the identification is not supported.
		 */ 
		private var idSize:int
		
		/**
		 * The function that must create and return an entity based on the inbound id.
		 * It must return not-null-referential value.
		 * It must define 1 or 2 inbound parameters: (id:Id) or (id:Id, data:Object) and return Object.
		 */
		private var preparator:Function
		
		/**
		 * @param	idSize {@see #idSize}
		 * @param	preparator {@see #preparator}
		 */
		public function AHub(idSize:int, preparator:Function) {
			if (idSize < 0) throw new Error("idSize must be 0 or higher")
			if (idSize == int.MAX_VALUE) throw new Error("idSize must be less than int.MAX_VALUE")
			this.idSize = idSize
			if (preparator == null) throw new Error("preparator is null")
			this.preparator = preparator
		}

		/**
		 * Checks if the id has the same idSize as the hub's idSize.
		 * Must be used in subclasses before invoking the preparator.
		 * @see #idSize
		 */
		protected final function checkId(id:Id):void {
			if ((id && id.getSize() != this.idSize) || (!id && this.idSize > 0)) throw new Error("not proper id size")
		}
		
		/**
		 * Must be used in subclasses in order to obtain an entity from the preparator
		 * if there's no entity in the cache. Then the entity must be saved in the cache.
		 * @see #preparator
		 */		
		protected final function prepareEntity(id:Id, data:*):Object {
			var entity:* = data ? this.preparator.call(this, id, data) : id && id.getSize() > 0 ? this.preparator.call(this, id) : this.preparator.call(this)
			if (!entity) throw new Error("null entity is created by the given id")
			if (!(entity is Object)) throw new Error("preparator result must be a referential value")
			return entity
		}
		
	}

}