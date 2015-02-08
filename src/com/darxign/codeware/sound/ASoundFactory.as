package com.darxign.codeware.sound {
	import com.darxign.codeware.Constant;
	/**
	 * A base sound class for xmodule framework
	 * @author darxign
	 */
	public class ASoundFactory {
		
		protected var soundHandlerGroup:SoundHandlerGroup
		
		public function ASoundFactory(soundHandlerGroup:SoundHandlerGroup) {
			this.soundHandlerGroup = soundHandlerGroup
		}
		
		public function createSound():SoundHandler {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
	}
	
}