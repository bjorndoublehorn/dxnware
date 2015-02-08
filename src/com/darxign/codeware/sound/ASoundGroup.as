package com.darxign.codeware.sound {
	import com.darxign.codeware.Constant;
	import com.darxign.codeware.control.identification.Id;
	/**
	 * @author darxign
	 */
	public class ASoundGroup {
		
		static public const VOLUME_NO_CHANGE:Id = Id.xtr(0)
		static public const VOLUME_INCREASING:Id = Id.xtr(1)
		static public const VOLUME_DECREASING:Id = Id.xtr(2)
		
		public var secondaryVolumeChangeType:Id
		
		public var $primaryVolume:Number
		public var $secondaryVolume:Number
		
		public function setPrimaryVolume(volume:Number):void {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
		public function setSecondaryVolume(volume:Number):void {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
		public function clear():void {
			throw new Error(Constant.ERROR_OBLIGATORY_ABSTRACT_METHOD)
		}
		
	}
	
}