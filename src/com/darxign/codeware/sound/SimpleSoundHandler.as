package com.darxign.codeware.sound {
	import com.darxign.codeware.control.identification.Id;
	import flash.events.Event;
	import flash.media.SoundChannel;
	/**
	 * @author darxign
	 */
	public class SimpleSoundHandler extends SoundHandler {
		
		private var soundChannel:SoundChannel
		
		public function SimpleSoundHandler(soundChannel:SoundChannel, soundGroup:SoundHandlerGroup, volume:Number, volumeChangeType:Id) {
			super(soundGroup, volume, volumeChangeType)
			this.soundChannel = soundChannel
			this.soundChannel.addEventListener(Event.SOUND_COMPLETE, this.onSoundChannelComplete)
		}
		
		override public final function updateVolume():void {
			SoundConstants.soundTransform.volume = this.volume * this.soundGroup.$primaryVolume * this.soundGroup.$secondaryVolume
			this.soundChannel.soundTransform = SoundConstants.soundTransform
		}
		
		override public final function stopAndRemoveFromSoundGroup():void {
			this.soundChannel.removeEventListener(Event.SOUND_COMPLETE, this.onSoundChannelComplete)
			this.soundChannel.stop()
			super.stopAndRemoveFromSoundGroup()
		}
		
	}

}