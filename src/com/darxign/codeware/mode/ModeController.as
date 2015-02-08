package com.darxign.codeware.mode {
	import com.darxign.codeware.control.identification.Id;
	/**
	 * The controller of the application's modes.
	 * Every different mode is present as a Mode object.
	 * There can be only 1 mode in one time.
	 * @author darxign
	 */
	public class ModeController {
		
		static public const STATE_UNDEFINED:Id =					Id.xtr(1)
		static public const STATE_ACTIVE:Id =						Id.xtr(2)
		static public const STATE_SWITCH:Id =						Id.xtr(3)		
		static public const STATE_IN_FUNCTION_INITIATE_SWITCH:Id =	Id.xtr(4)
		static public const STATE_IN_FUNCTION_COMPLETE_SWITCH:Id =	Id.xtr(5)
		static public const STATE_IN_FUNCTION_START_WITH_MODE:Id =	Id.xtr(6)
		
		private var modeAccessor:ModeAccessor
		
		// the state of the mode controller
		public var $stateId:Id
		
		// current mode data
		public var $modeId:Id
		public var $mode:AMode
		
		// next mode data
		private var nextModeId:Id
		private var nextModeData:Object
		
		/**
		 * Creates a ModeController.
		 * @param	modeAccessor The accessor for all the possible application modes.
		 */
		public function ModeController(modeAccessor:ModeAccessor) {
			if (modeAccessor == null) throw new Error("modeAccessor is null")
			this.modeAccessor = modeAccessor
			this.$modeId = null
			this.$mode = null
			this.nextModeId = null
			this.nextModeData
			this.$stateId = STATE_UNDEFINED
		}
		
		/**
		 * Prepares the current mode for deactivation.
		 * However the final switch to the new mode is performed with invoking completeSwitch().
		 * Works for STATE_ACTIVE only; other states are ignored.
		 * @param	modeId The id of the new mode.
		 * @param	data Auxiliary data for the mode if necessery.
		 */
		public final function initiateSwitch(modeId:Id, data:Object):void {
			if (this.$stateId == STATE_ACTIVE) {
				this.$stateId = STATE_IN_FUNCTION_INITIATE_SWITCH
				this.nextModeId = modeId
				this.nextModeData = data
				if (this.$mode.prepareForDeactivation(this.nextModeId, this.nextModeData)) {
					this.$stateId = STATE_SWITCH
					this.completeSwitch()
				} else {
					this.$stateId = STATE_SWITCH
				}
			}
		}
		
		/**
		 * Invokes activation of the new mode.
		 * Works for STATE_SWITCH only; other states are ignored.
		 */
		public final function completeSwitch():void {
			if (this.$stateId == STATE_SWITCH) {
				this.$stateId = STATE_IN_FUNCTION_COMPLETE_SWITCH
				this.$mode.deactivate()
				this.$modeId = this.nextModeId
				if (this.$modeId == null) {
					this.$stateId = STATE_UNDEFINED
					var data:Array = this.nextModeData as Array
					var f:Function = data[0] as Function
					var o:Object = data[1]
					var p:Array = data.slice(2)
					f.apply(o, p)
					this.nextModeData = null					
				} else {
					this.$mode = this.modeAccessor.accessMode(this.$modeId)
					this.$mode.activate(this.nextModeData)
					this.nextModeId = null
					this.nextModeData = null
					this.$stateId = STATE_ACTIVE
				}
			}
		}
		
		/**
		 * Sets the first mode after the current mode. As opposed to the initiateSwitch()
		 *  it doesn't deactivate the previous mode.
		 * Works for STATE_UNDEFINED only; other states are ignored.
		 * @param	modeId The id of the new mode.
		 * @param	data Auxiliary data for the mode if needed.
		 */
		public final function startWithMode(modeId:Id, data:Object):void {
			if (this.$stateId == STATE_UNDEFINED) {
				this.$stateId = STATE_IN_FUNCTION_START_WITH_MODE
				this.$modeId = null
				this.$mode = null
				this.$mode = this.modeAccessor.accessMode(modeId)
				this.$mode.activate(data)
				this.$modeId = modeId
				this.$stateId = STATE_ACTIVE
			}
		}
		
	}

}