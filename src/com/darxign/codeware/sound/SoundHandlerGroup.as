package com.darxign.codeware.sound {
	import flash.utils.Dictionary;
	/**
	 * Contains tools for working with multiple sounds
	 * @author darxign
	 */
	public class SoundHandlerGroup extends ASoundGroup {
		
		// how many null values in the module stack can form before the void cleaning process.
		static private const NULL_LIMIT:int = 20
		
		// how many null values has formed in the module stack by now
		private var nulls:int = 0
		
		private const handlerIndexes:Dictionary = new Dictionary()
		
		public const handlers:Vector.<SoundHandler> = new Vector.<SoundHandler>()
		
		override public final function setPrimaryVolume(volume:Number):void {
			this.$primaryVolume = volume
			this.updateVolumeInAllHandlers()
		}
		
		override public final function setSecondaryVolume(volume:Number):void {
			this.$secondaryVolume = volume
			this.updateVolumeInAllHandlers()
		}
		
		private final function updateVolumeInAllHandlers():void {
			for each (var handler:SoundHandler in this.handlers) {
				if (handler) {
					handler.updateVolume()
				}
			}
		}
		
		public final function addSoundHandler(handler:SoundHandler):void {
			var length:int = this.handlers.length
			this.handlers[length] = handler
			this.handlerIndexes[handler] = length
		}
		
		public final function removeSound(handler:SoundHandler):void {
			this.handlers[this.handlerIndexes[handler]] = null
			delete this.handlerIndexes[handler]
		}
		
		public final function cleanVoids():void {
			this.nulls += 1
			// Void Cleaning: removing all null values from the module stack and updating the indexes
			if (this.nulls > SoundHandlerGroup.NULL_LIMIT) {
				for (var i:int = 0, length:int = handlers.length; i < length; i++) {
					var handler:SoundHandler = this.handlers[i]
					if (handler != null) {
						this.handlerIndexes[handler] = i
					} else {
						this.handlers.splice(i, 1)
						length -= 1
						i -= 1
					}
				}
				this.nulls = 0
			}
		}
		
		override public final function clear():void {
			for each (var handler:SoundHandler in this.handlers) {
				if (handler) {
					handler.stopAndRemoveFromSoundGroup()
				}
			}
		}
		
	}

}