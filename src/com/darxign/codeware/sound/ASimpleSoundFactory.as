package com.darxign.codeware.sound {
	import flash.media.Sound;
	/**
	 * @author darxign
	 */
	public class ASimpleSoundFactory extends ASoundFactory {
		
		protected var soundFactory:Sound
		
		public function ASimpleSoundFactory(soundFactory:Sound, soundHandlerGroup:SoundHandlerGroup) {
			super(soundHandlerGroup)
			this.soundFactory = soundFactory
		}
		
	}

}