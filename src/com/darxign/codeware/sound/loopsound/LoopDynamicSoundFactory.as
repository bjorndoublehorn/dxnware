package com.darxign.codeware.sound.loopsound {
	import com.darxign.codeware.Common;
	import com.darxign.codeware.sound.ASoundFactory;
	import com.darxign.codeware.sound.DynamicSoundChannel;
	import com.darxign.codeware.sound.DynamicSoundHandler;
	import com.darxign.codeware.sound.SoundConstants;
	import com.darxign.codeware.sound.SoundHandler;
	import com.darxign.codeware.sound.SoundHandlerGroup;
	import flash.display.Stage;
	import flash.media.Sound;
	/**
	 * @author darxign
	 */
	public class LoopDynamicSoundFactory extends ASoundFactory {
		
		protected var delay:Number
		protected var fadeInDuration:Number
		protected var fadeOutDuration:Number
		protected var sequence:Array
		
		public function LoopDynamicSoundFactory(
		delay:Number,
		fadeInDuration:Number,
		fadeOutDuration:Number,
		sequence:Array,
		soundHandlerGroup:SoundHandlerGroup,
		stage:Stage)
		{
			super(soundHandlerGroup)
			if (sequence.length == 0) {
				throw new Error("no elements in sequence")
			}
			if (!Common.oneClassOnly(Sound, sequence)) {
				throw new Error("an element of sequence is not a Sound")
			}
			this.delay = delay
			this.fadeInDuration = fadeInDuration
			this.fadeOutDuration = fadeOutDuration
			this.sequence = sequence
		}
		
		override public final function createSound():SoundHandler {
			if (SoundHandler.usedChannels < SoundHandler.MAX_CHANNELS) {
				SoundConstants.soundTransform.volume = 0
				var dynamicSoundChannel:DynamicSoundChannel = new DynamicSoundChannel(true, this.delay, this.fadeInDuration, this.fadeOutDuration, this.sequence, SoundConstants.soundTransform, this.msPerEnterFrame)
				return new DynamicSoundHandler(dynamicSoundChannel, this.soundHandlerGroup, 1, SoundHandler.VOLUME_NO_CHANGE)
			}
			return null
		}
		
	}

}