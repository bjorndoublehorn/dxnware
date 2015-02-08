package com.darxign.codeware.mode {
	import com.darxign.codeware.Constant;
	import com.darxign.codeware.control.identification.Id;
	/**
	 * Abstract container for all the mode data
	 * @author darxign
	 */
	public class AMode {
		
		/**
		 * Activates the mode
		 * @param	data The auxiliary data if necessery.
		 */
		public function activate(data:Object):void {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
		/**
		 * @abstract
		 * There are two ways to deactivate the mode
		 * 1. Instant, when true is returned and then the ModeController immediately invokes deactivate().
		 * 2. Gradual, when a deactivation process starts (e.g. a module) and false is returned.
		 *    The deactivation process must invoke completeSwitch() on the ModeController in order for it
		 *    to invoke deactivate() on the mode.
		 * @param nextModeId
		 * @param nextModeData
		 * @return	true if it allows instant mode switch completion, false otherwise
		 */
		public function prepareForDeactivation(nextModeId:Id, nextModeData:Object):Boolean {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
		/**
		 * @abstract
		 * Deactivates the mode
		 * @return	true if it allows instant mode switch completion, false otherwise
		 */
		public function deactivate():void {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
	}

}