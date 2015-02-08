package com.darxign.codeware.sound {
	import com.darxign.codeware.control.identification.Id;
	import flash.events.Event;
	/**
	 * @author darxign
	 */
	public class SoundHandler {
		
		static public const VOLUME_NO_CHANGE:Id = Id.xtr(0)
		static public const VOLUME_INCREASING:Id = Id.xtr(1)
		static public const VOLUME_DECREASING:Id = Id.xtr(2)
		
		static public const MAX_CHANNELS:int = 32
		
		static public var usedChannels:int = 0
		
		public var volumeChangeType:Id
		public var volume:Number
		
		protected var soundGroup:SoundHandlerGroup
		
		public function SoundHandler(soundGroup:SoundHandlerGroup, volume:Number, volumeChangeType:Id) {
			SoundHandler.usedChannels += 1
			this.soundGroup = soundGroup
			this.volume = volume
			this.volumeChangeType = volumeChangeType
			this.soundGroup.addSoundHandler(this)
		}
		
		public function updateVolume():void {}
		
		public function stopAndRemoveFromSoundGroup():void {
			this.soundGroup.removeSound(this)
			SoundHandler.usedChannels -= 1
		}
		
		protected final function onSoundChannelComplete(event:Event):void {
			this.stopAndRemoveFromSoundGroup()
		}
		
	}

}