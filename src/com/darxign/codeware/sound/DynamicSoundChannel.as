package com.darxign.codeware.sound {
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	/**
	 * @author darxign
	 */
	[Event(name="soundComplete", type="flash.events.Event")]
	public class DynamicSoundChannel extends EventDispatcher {
		
		static public const TIME_AHEAD_inMs:int = 5000
		static public const TIME_CHECK_inMs:int = 1000
		
		static private const SAMPLES_PER_MILLISECOND:Number = 44.1
		static private const TIME_PER_TAG_inMs:int = 100
		static private const SAMPLES_PER_TAG:Number = SAMPLES_PER_MILLISECOND * TIME_PER_TAG_inMs
		
		static private const DEFAULT_FPS_VALUE:int = 30
		
		private var soundList:Vector.<Sound>
		private var currentSound:int
		private var currentSample:Number
		
		private var fadeInLastSound:int
		private var fadeInLastSample:Number
		private var fadeInChangePerSample:Number
		
		private var fadeOutFirstSound:int
		private var fadeOutFirstSample:Number
		private var fadeOutChangePerSample:Number
		
		private var currentFadeMltplr:Number
		
		private var repeatConstantly:Boolean
		
		private var delaySamples:Number
		
		private var fps:Object
		
		private var timeAhead:int
		
		private var currentFlvTime:int
		
		private var nc:NetConnection
		
		private var ns:NetStream
		private var temporarySndTransform:SoundTransform
		
		private var video:Video
		
    /**
    * @param repeatConstantly  If the sound sequence should replay again and again
    * @param delay             Time in milliseconds before the sound generation starts
    * @param fadeInDuration    Time in milliseconds of the fade in period
    * @param fadeOutDuration   Time in milliseconds of the fade out period
    * @param sequence          An array with sounds that should play consecutively
    * @param sndTransform      Initial sound transform
    * @param fps               The object which must implement returning the current application FPS in its value field (fps.value)
    * @param timeAhead         How much time the NetStream tends to pregenerate flv data in its cache
    * @param timeCheck         Depricated   
    */
		public function DynamicSoundChannel (
		repeatConstantly:Boolean,
		delay:Number,
		fadeInDuration:Number,
		fadeOutDuration:Number,
		sequence:Array,
		sndTransform:SoundTransform,
		fps:Object,
		timeAhead:int = TIME_AHEAD_inMs,
		timeCheck:int = TIME_CHECK_inMs)
		{
			
			if (fps == null) {
				throw new Error("fps object is null")
			}
			
			if (timeAhead < timeCheck) {
				throw new Error("timeAheadMs < timeCheckMs")
			}
			
			this.soundList = new Vector.<Sound>()
			for (var i:int = 0; i < sequence.length; i += 1) {
				var sound:Sound = sequence[i] as Sound
				if (!sound) {
					throw new Error("element [" + i + "] is not a Sound")
				}
				this.soundList[i] = sound
			}
			if (this.soundList.length == 0) {
				throw new Error("no sounds in sequence")
			}
			this.soundList.fixed = true
			this.currentSound = 0
			this.currentSample = 0
			
			this.fadeInChangePerSample = 1 / (fadeInDuration * SAMPLES_PER_MILLISECOND)
			this.fadeOutChangePerSample = 1 / (fadeOutDuration * SAMPLES_PER_MILLISECOND)
			
			fadeInLastSound = -1 // fadeIn will never be used
			if (fadeInDuration > 0) {
				for (i = 0; i < this.soundList.length; i += 1) {
					if (fadeInDuration - this.soundList[i].length < 0) {
						fadeInLastSound = i
						fadeInLastSample = Math.floor(fadeInDuration * SAMPLES_PER_MILLISECOND)
						break
					} else {
						fadeInDuration -= this.soundList[i].length
					}
				}
				if (fadeInLastSound == -1) {
					throw new Error("fadeIn exceeds full sound length")
				}
			}
			
			fadeOutFirstSound = this.soundList.length // fadeOut will never be used
			if (fadeOutDuration > 0) {
				for (i = this.soundList.length - 1; i >= 0; i -= 1) {
					if (fadeOutDuration - this.soundList[i].length <= 0) {
						fadeOutFirstSound = i
						fadeOutFirstSample = Math.max(0, Math.floor((this.soundList[i].length - fadeOutDuration) * SAMPLES_PER_MILLISECOND))
						break
					} else {
						fadeOutDuration -= this.soundList[i].length
					}
				}
				if (fadeOutFirstSound == this.soundList.length) {
					throw new Error("fadeOut exceeds full sound length")
				}
			}
			
			if (fadeInLastSound > fadeOutFirstSound || (fadeInLastSound == fadeOutFirstSound && (fadeInLastSample > fadeOutFirstSample))) {
				throw new Error("fadeIn overlaps fadeOut")
			}
			
			this.repeatConstantly = repeatConstantly
			
			this.delaySamples = Math.floor(delay * SAMPLES_PER_MILLISECOND)
			
			this.fps = fps
			
			this.timeAhead = timeAhead
			this.currentFlvTime = 0
			
			this.temporarySndTransform = sndTransform ? sndTransform : new SoundTransform(1, 0)
			
			this.nc = new NetConnection()
			this.nc.addEventListener(NetStatusEvent.NET_STATUS, onConnect)
			this.nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
			
			var metaSniffer:Object=new Object()
			nc.client=metaSniffer
			metaSniffer.onMetaData = function (mdata:Object):void {video.width=mdata.width/2;video.height=mdata.height/2;}
			nc.connect(null)
			metaSniffer = null
			
		}
		
		public final function get soundTransform():SoundTransform {
			if (this.ns) {
				return this.ns.soundTransform
			} else {
				return this.temporarySndTransform
			}
		}
		
		public final function set soundTransform(sndTransform:SoundTransform):void {
			if (this.ns) {
				this.ns.soundTransform = sndTransform
			} else {
				this.temporarySndTransform = sndTransform
			}
		}
		
		private final function onConnect(e:NetStatusEvent):void {
			if (e.info.code == "NetConnection.Connect.Success") {
				
				this.ns = new NetStream(e.target as NetConnection)
				this.ns.client = { }
				this.ns.soundTransform = this.temporarySndTransform
				this.ns.play(null)
				this.ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN)
				this.temporarySndTransform = null
				
				this.writeFlvHeader()
				
				this.video = new Video()
				
				this.video.addEventListener(Event.ENTER_FRAME, checkBufferState)
				this.checkBufferState(null)
				
				this.video.attachNetStream(this.ns)
				
				this.nc.removeEventListener(NetStatusEvent.NET_STATUS, onConnect)
			}
		}
		
		public final function stop():void {
			
			if (this.video) {
				if (this.video.hasEventListener(Event.ENTER_FRAME)) {
					this.video.removeEventListener(Event.ENTER_FRAME, checkBufferState)
				}
				this.video = null
			}
			
			if (this.ns) {
				if (this.ns.hasEventListener(NetStatusEvent.NET_STATUS)) {
					this.ns.removeEventListener(NetStatusEvent.NET_STATUS, onStatus)
				}
				this.ns.close()
				this.ns = null
			}
			
			if (this.nc) {
				if (this.nc.hasEventListener(NetStatusEvent.NET_STATUS)) {
					this.nc.removeEventListener(NetStatusEvent.NET_STATUS, onConnect)
				}
				if (this.nc.hasEventListener(AsyncErrorEvent.ASYNC_ERROR)) {
					this.nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onError)
				}
				this.nc.close()
				this.nc = null
			}
			
			this.soundList.fixed = false
			this.soundList.length = 0
			this.soundList = null
		}
		
		private final function onError(e:Event):void {
			this.stop()
			this.dispatchEvent(new Event(Event.SOUND_COMPLETE))
		}
		
		private final function onStatus(e:NetStatusEvent):void {
			if (e.info.code == "NetStream.Buffer.Empty") {
				this.stop()
				this.dispatchEvent(new Event(Event.SOUND_COMPLETE))
			}
		}
		
		private final function checkBufferState(e:Event):void {
			if (!this.video || !this.video.hasEventListener(Event.ENTER_FRAME)) {
				return
			}
			var fpsValue:int = this.fps.value
			if (fpsValue < 1) {
				trace("wrong fps.value provided: " + this.fps.value)
				fpsValue = DEFAULT_FPS_VALUE
			}
			var tagsToWrite:int = Math.ceil((this.timeAhead - this.ns.bufferLength * 1000) * SAMPLES_PER_MILLISECOND / SAMPLES_PER_TAG)
			//or tagsToWrite:int = Math.ceil((getTimer() + this.timeAhead - this.initTime - this.currentTime) * SAMPLES_PER_MILLISECOND / SAMPLES_PER_TAG)
			var msPerEnterFrame:int = 1000 / fpsValue
			var maxTagsPerEnterFrame:int = Math.ceil(msPerEnterFrame * 2.1 / TIME_PER_TAG_inMs) // 2.1 is just to overcome possible silence gaps on borders
			if (tagsToWrite > maxTagsPerEnterFrame) {
				tagsToWrite = maxTagsPerEnterFrame
			}
			if (tagsToWrite > 0) {
				this.writeTags(tagsToWrite)
			}
		}
		
		private final function writeTags(flvAudioTags:int):void {
			
			if (flvAudioTags <= 0) {
				return
			}
			
			var finishChannel:Boolean = false
			
			// float-point sample buffers for fadeIn, plain and fadeOut parts of current sample sequence
			var buffers:Vector.<SampleByteArray> = new Vector.<SampleByteArray>()
			
			var samplesToCreate:Number = this.extractEmptyDelaySamples(buffers, flvAudioTags * SAMPLES_PER_TAG)
			
			for (; samplesToCreate > 0; samplesToCreate -= length) {
				
				var sound:Sound = this.soundList[this.currentSound]
				var fullSoundSamples:Number = Math.floor(sound.length * SAMPLES_PER_MILLISECOND)
				var length:Number = samplesToCreate
				if (this.currentSample + samplesToCreate > fullSoundSamples) {
					length = fullSoundSamples - this.currentSample
				}
				
				if (this.currentSound > this.fadeInLastSound && this.currentSound < this.fadeOutFirstSound) {
					this.extractToBuffer(buffers, SampleByteArray.PLAIN, sound, length, this.currentSample)
				} else if (this.currentSound < this.fadeInLastSound) {
					this.extractToBuffer(buffers, SampleByteArray.FADE_IN, sound, length, this.currentSample)
				} else if (this.currentSound > this.fadeOutFirstSound) {
					this.extractToBuffer(buffers, SampleByteArray.FADE_OUT, sound, length, this.currentSample)
				} else {
					var fadeInSampleCount:Number = 0
					if (this.currentSound == this.fadeInLastSound) {
						fadeInSampleCount = this.fadeInLastSample - this.currentSample
						if (fadeInSampleCount > 0) {
							if (fadeInSampleCount > length) {
								fadeInSampleCount = length
							}
						} else {
							fadeInSampleCount = 0
						}
					}
					var fadeOutSampleCount:Number = 0
					if (this.currentSound == this.fadeOutFirstSound) {
						fadeOutSampleCount = this.currentSample + length - this.fadeOutFirstSample
						if (fadeOutSampleCount > 0) {
							if (fadeOutSampleCount > length) {
								fadeOutSampleCount = length
							}
						} else {
							fadeOutSampleCount = 0
						}
					}
					var plainSampleCount:Number = length - fadeInSampleCount - fadeOutSampleCount
					if (plainSampleCount < 0) {
						trace("DynamicSoundChannel: unexpected case: fadeInLastSample and fadeOutFirstSample intersect")
						this.extractToBuffer(buffers, SampleByteArray.PLAIN, sound, length, this.currentSample)
					} else {
						if (fadeInSampleCount > 0) {
							this.extractToBuffer(buffers, SampleByteArray.FADE_IN, sound, fadeInSampleCount, this.currentSample)
						}
						if (plainSampleCount > 0) {
							this.extractToBuffer(buffers, SampleByteArray.PLAIN, sound, plainSampleCount, this.currentSample + fadeInSampleCount)
						}
						if (fadeOutSampleCount > 0) {
							this.extractToBuffer(buffers, SampleByteArray.FADE_OUT, sound, fadeOutSampleCount, this.currentSample + fadeInSampleCount + plainSampleCount)
						}
					}
				}
				this.currentSample += length
				if (this.currentSample >= fullSoundSamples) {
					this.currentSound += 1
					if (this.currentSound >= this.soundList.length) {
						if (this.repeatConstantly) {
							this.currentSound = 0
						} else {
							samplesToCreate -= length
							//flvAudioTags -= Math.floor(samplesToCreate / SAMPLES_PER_TAG)
							this.extractEmptyTailSamples(buffers, samplesToCreate % SAMPLES_PER_TAG)
							//samplesToCreate = 0
							finishChannel = true
							break
						}
					}
					this.currentSample = 0
				}
			}
			
			for each (var sba:SampleByteArray in buffers) {
				sba.position = 0
			}
			
			var wavBytes:ByteArray = rawBytesBuffersToWav(buffers)
			this.ns.appendBytes(wavBytes)
			wavBytes.clear()
			wavBytes = null
			
			if (finishChannel) {
				if (this.video) {
					if (this.video.hasEventListener(Event.ENTER_FRAME)) {
						this.video.removeEventListener(Event.ENTER_FRAME, checkBufferState)
					}
					this.video = null
				}
				this.ns.addEventListener(NetStatusEvent.NET_STATUS, onStatus)
				this.ns.appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE)
			}
		}
		
		private final function rawBytesBuffersToWav(buffers:Vector.<SampleByteArray>):ByteArray {
			var b:ByteArray = new ByteArray()
			while (buffers.length > 0) {
				// audio tag
				b.writeByte(0x08)
				
				// wavData length: 24 bits
				var dataLength:uint = SAMPLES_PER_TAG * 4 + 1 //data.length + audio-tag-header
				b.writeByte(dataLength >> 16)
				b.writeByte(dataLength >> 8)
				b.writeByte(dataLength)
				
				// timestamp: lower 24 bits of the 32-bit structure
				b.writeByte(this.currentFlvTime >> 16)
				b.writeByte(this.currentFlvTime >> 8)
				b.writeByte(this.currentFlvTime)
				this.currentFlvTime += TIME_PER_TAG_inMs
				
				// timestamp: higher 8 bits of the 32-bit structure
				b.writeByte(this.currentFlvTime >> 24)
				
				// streamId
				b.writeByte(0)
				b.writeShort(0)
				
				// audio-tag-header: soundFormat=3(PCM-LE), soundRate=3(44kHz), soundSize=1(16-bit-samples), soundType=1(Stereo)
				b.writeByte(0x3F)
				
				// data
				b.endian = Endian.LITTLE_ENDIAN
				for (var allSamples:Number = 0; allSamples < SAMPLES_PER_TAG; ) {
					var n:Number
					var sba:SampleByteArray = buffers[0]
					switch (sba.type) {
						case SampleByteArray.FADE_IN:
							if (sba.hasFadeInitialSample) {
								this.currentFadeMltplr = 0
								sba.hasFadeInitialSample = false
							}
							var fadeInSamplesAvailable:Number = sba.bytesAvailable / 8
							for (n = 0; allSamples < SAMPLES_PER_TAG && n < fadeInSamplesAvailable; allSamples += 1, n += 1) {
								b.writeShort(sba.readFloat() * 32767 * this.currentFadeMltplr/*+ 0.5*/)
								b.writeShort(sba.readFloat() * 32767 * this.currentFadeMltplr/*+ 0.5*/)
								this.currentFadeMltplr += this.fadeInChangePerSample
								if (this.currentFadeMltplr > 1) {
									this.currentFadeMltplr = 1
								}
							}
							break
						case SampleByteArray.FADE_OUT:
							if (sba.hasFadeInitialSample) {
								this.currentFadeMltplr = 1
								sba.hasFadeInitialSample = false
							}
							var fadeOutSamplesAvailable:Number = sba.bytesAvailable / 8
							for (n = 0; allSamples < SAMPLES_PER_TAG && n < fadeOutSamplesAvailable; allSamples += 1, n += 1) {
								b.writeShort(sba.readFloat() * 32767 * this.currentFadeMltplr/*+ 0.5*/)
								b.writeShort(sba.readFloat() * 32767 * this.currentFadeMltplr/*+ 0.5*/)
								this.currentFadeMltplr -= this.fadeOutChangePerSample
								if (this.currentFadeMltplr < 0) {
									this.currentFadeMltplr = 0
								}
							}
							break
						case SampleByteArray.PLAIN:
							var plainSamplesAvailable:Number = sba.bytesAvailable / 8
							for (n = 0; allSamples < SAMPLES_PER_TAG && n < plainSamplesAvailable; allSamples += 1, n += 1) {
								b.writeShort(sba.readFloat() * 32767 /*+ 0.5*/)
								b.writeShort(sba.readFloat() * 32767 /*+ 0.5*/)
							}
							break
						default:
							trace("unexpected SampleByteArray type: " + sba.type)
							plainSamplesAvailable = sba.bytesAvailable / 8
							for (n = 0; allSamples < SAMPLES_PER_TAG && n < plainSamplesAvailable; allSamples += 1, n += 1) {
								b.writeShort(sba.readFloat() * 32767 /*+ 0.5*/)
								b.writeShort(sba.readFloat() * 32767 /*+ 0.5*/)
							}
							break
					}
					if (sba.bytesAvailable == 0) {
						sba.clear()
						buffers.shift()
					}
				}
				b.endian = Endian.BIG_ENDIAN
				
				// flvTagLength info
				var tagLength:uint = dataLength + 11
				b.writeByte(tagLength >> 24)
				b.writeByte(tagLength >> 16)
				b.writeByte(tagLength >> 8)
				b.writeByte(tagLength)
				
			}
			return b
		}
		
		private final function extractEmptyDelaySamples(buffers:Vector.<SampleByteArray>, samplesToCreate:Number):Number {
			if (this.delaySamples > 0) {
				var sba:SampleByteArray = new SampleByteArray()
				sba.type = SampleByteArray.PLAIN
				buffers[0] = sba
				var delaySamplesToCreate:Number = Math.min(this.delaySamples, samplesToCreate)
				for (var n:Number = 0; n < delaySamplesToCreate; n += 1) {
					sba.writeUnsignedInt(0)
					sba.writeUnsignedInt(0)
				}
				this.delaySamples -= delaySamplesToCreate
				samplesToCreate -= delaySamplesToCreate
			}
			return samplesToCreate
		}
		
		private final function extractEmptyTailSamples(buffers:Vector.<SampleByteArray>, tailSamplesAmmount:Number):void {
			if (tailSamplesAmmount <= 0) {
				return
			}
			var sba:SampleByteArray = buffers.length > 0 ? buffers[buffers.length - 1] : null
			if (!sba || sba.type != SampleByteArray.PLAIN) {
				sba = new SampleByteArray()
				sba.type = SampleByteArray.PLAIN
				buffers[buffers.length] = sba
			}
			for (var n:Number = 0; n < tailSamplesAmmount; n += 1) {
				sba.writeUnsignedInt(0)
				sba.writeUnsignedInt(0)
			}
		}
		
		private final function extractToBuffer(buffers:Vector.<SampleByteArray>, type:int, sound:Sound, samplesAmount:Number, firstSampleIndex:Number):void {
			var sba:SampleByteArray = buffers.length > 0 ? buffers[buffers.length - 1] : null
			if (!sba || sba.type != type) {
				sba = new SampleByteArray()
				sba.type = type
				switch (type) {
					case SampleByteArray.FADE_IN:
						sba.hasFadeInitialSample = this.currentSound == 0 && firstSampleIndex == 0
						break
					case SampleByteArray.FADE_OUT:
						sba.hasFadeInitialSample = this.currentSound == this.fadeOutFirstSound && firstSampleIndex == this.fadeOutFirstSample
						break
				}
				buffers[buffers.length] = sba
			}
			sound.extract(sba, samplesAmount, firstSampleIndex)
		}
		
		private final function writeFlvHeader():void {
			var header:ByteArray = new ByteArray()
			header.writeByte(0x46) // F
			header.writeByte(0x4C) // L
			header.writeByte(0x56) // V
			header.writeByte(0x01) // flv version 1
			header.writeByte(0x04) // 0000100 = only audio tags
			header.writeUnsignedInt(0x09) // length of this header
			header.writeUnsignedInt(0x00) // stub
			this.ns.appendBytes(header)
			header.clear()
			header = null
		}
		
	}

}
import flash.utils.ByteArray;
class SampleByteArray extends ByteArray {
	static public const FADE_IN:int = 1
	static public const FADE_OUT:int = 2
	static public const PLAIN:int = 3
	public var type:int
	public var hasFadeInitialSample:Boolean
}
