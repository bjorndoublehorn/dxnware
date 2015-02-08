package com.darxign.codeware.sound.loopsound {
	import com.darxign.codeware.sound.ASimpleSoundFactory;
	import com.darxign.codeware.sound.SimpleSoundHandler;
	import com.darxign.codeware.sound.SoundConstants;
	import com.darxign.codeware.sound.SoundHandler;
	import com.darxign.codeware.sound.SoundHandlerGroup;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	/**
	 * Wrapper for a Loop Sound.
	 * @author darxign
	 */
	public class LoopSimpleSoundFactory extends ASimpleSoundFactory {
		
		public function LoopSimpleSoundFactory(soundFactory:Sound, soundHandlerGroup:SoundHandlerGroup) {
			super(soundFactory, soundHandlerGroup)
		}
		
		override public final function createSound():SoundHandler {
			if (SoundHandler.usedChannels < SoundHandler.MAX_CHANNELS) {
				SoundConstants.soundTransform.volume = 0
				var soundChannel:SoundChannel = this.soundFactory.play(0, int.MAX_VALUE, SoundConstants.soundTransform)
				if (soundChannel) {
					return new SimpleSoundHandler(soundChannel, this.soundHandlerGroup, 0, SoundHandler.VOLUME_INCREASING)
				}
			}
			return null
		}
		
	}
	
}