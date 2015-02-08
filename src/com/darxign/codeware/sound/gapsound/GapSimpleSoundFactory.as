package com.darxign.codeware.sound.gapsound {
	import com.darxign.codeware.sound.ASimpleSoundFactory;
	import com.darxign.codeware.sound.SimpleSoundHandler;
	import com.darxign.codeware.sound.SoundConstants;
	import com.darxign.codeware.sound.SoundHandler;
	import com.darxign.codeware.sound.SoundHandlerGroup;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getTimer;
	/**
	 * Wrapper for a Simple Sound.
	 * @author darxign
	 */
	public class GapSimpleSoundFactory extends ASimpleSoundFactory {
		
		private var gap:int
		private var lastPlay:int
		
		/**
		 * @param	gap The number of miliseconds to wait until the next play. It serves as a protector against resonance.
		 */
		public function GapSimpleSoundFactory(audioFactory:Sound, soundHandlerGroup:SoundHandlerGroup, gap:int) {
			super(audioFactory, soundHandlerGroup)
			this.gap = gap
			this.lastPlay = 0
		}
		
		override public final function createSound():SoundHandler {
			if (SoundHandler.usedChannels < SoundHandler.MAX_CHANNELS) {
				var t:int = getTimer()
				if ((t - this.lastPlay) > this.gap) {
					this.lastPlay = t
					SoundConstants.soundTransform.volume = this.soundHandlerGroup.$primaryVolume * this.soundHandlerGroup.$secondaryVolume
					var soundChannel:SoundChannel = this.soundFactory.play(0, 0, SoundConstants.soundTransform)
					if (soundChannel) {
						return new SimpleSoundHandler(soundChannel, this.soundHandlerGroup, 1, SoundHandler.VOLUME_NO_CHANGE)
					}
				}
			}
			return null
		}
		
	}

}