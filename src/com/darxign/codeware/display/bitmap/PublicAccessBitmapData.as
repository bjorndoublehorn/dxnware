package com.darxign.codeware.display.bitmap {
	import flash.display.BitmapData;
	/**
	 * @author darxign
	 */
	public class PublicAccessBitmapData extends BitmapData {
		
		public var $width:int
		
		public var $height:int
		
		public function PublicAccessBitmapData(width:int, height:int, transparent:Boolean = true, fillColor:uint = 4294967295) {
			super(width, height, transparent, fillColor)
			this.$width = width
			this.$height = height
		}
		
	}

}