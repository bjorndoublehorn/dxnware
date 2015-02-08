package com.darxign.codeware.mode {
	import com.darxign.codeware.control.hub.impl.Accessor;
	import com.darxign.codeware.control.identification.Id;
	/**
	 * Accessor to application modes.
	 * This class must be extended.
	 * Preparator must return the app's possible Modes by their id.
	 * @author darxign
	 */
	public class ModeAccessor extends Accessor {
		
		public function ModeAccessor(preparator:Function) { super(1, preparator) }
		
		public final function accessMode(id:Id):AMode {
			return this.access(id) as AMode
		}
		
	}

}