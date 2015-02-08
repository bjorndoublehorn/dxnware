package com.darxign.codeware.control.hub.impl {
	import com.darxign.codeware.control.hub.AHub;
	import com.darxign.codeware.control.identification.Id;
	/**
	 * Hub for creation of entities.
	 * It doesn't cache entities.
	 * @author darxign
	 */
	public class Creator extends AHub {
		
		/**
		 * @inheritDoc
		 */
		public function Creator(idSize:int, preparator:Function) {
			super(idSize, preparator)
		}
		
		/**
		 * @return An entity by its id.
		 */
		public final function create(id:Id, data:* = null):* {
			this.checkId(id)
			return this.prepareEntity(id, data)
		}
		
	}

}