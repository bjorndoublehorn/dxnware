package com.darxign.codeware.sound {
	import com.darxign.codeware.control.identification.Id;
	import flash.events.Event;
	/**
	 * @author darxign
	 */
	public class DynamicSoundHandler extends SoundHandler {
		
		private var dynamicSoundChannel:DynamicSoundChannel
		
		public function DynamicSoundHandler(dynamicSoundChannel:DynamicSoundChannel, soundGroup:SoundHandlerGroup, volume:Number, volumeChangeType:Id) {
			super(soundGroup, volume, volumeChangeType)
			this.dynamicSoundChannel = dynamicSoundChannel
			this.dynamicSoundChannel.addEventListener(Event.SOUND_COMPLETE, this.onSoundChannelComplete)
		}
		
		override public final function updateVolume():void {
			SoundConstants.soundTransform.volume = this.volume * this.soundGroup.$primaryVolume * this.soundGroup.$secondaryVolume
			this.dynamicSoundChannel.soundTransform = SoundConstants.soundTransform
		}
		
		override public final function stopAndRemoveFromSoundGroup():void {
			this.dynamicSoundChannel.removeEventListener(Event.SOUND_COMPLETE, this.onSoundChannelComplete)
			this.dynamicSoundChannel.stop()
			super.stopAndRemoveFromSoundGroup()
		}
		
	}

}