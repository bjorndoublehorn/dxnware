package com.darxign.codeware.display.bitmap {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author darxign
	 */
	public class ScrollableBitmap extends Bitmap {
		
		private var texture:BitmapData
		private var textureWidth:int
		private var textureHeight:int
		
		public var $currentScrollX:int
		public var $currentScrollY:int
		
		private const rect:Rectangle = new Rectangle()
		private const point:Point = new Point()
		
		public function ScrollableBitmap(texture:BitmapData, bitmapData:BitmapData, pixelSnapping:String = "auto", smoothing:Boolean = false) {
			super(bitmapData, pixelSnapping, smoothing)
			this.texture = texture
			this.textureWidth = texture.width
			this.textureHeight = texture.height
			this.$currentScrollX = 0
			this.$currentScrollY = 0
		}
		
		override public function set bitmapData(value:BitmapData):void {
			super.bitmapData = value
			this.scrollAbsolute(this.$currentScrollX, this.$currentScrollY)
		}
		
		public function scroll(x:int, y:int):void {
			this.scrollAbsolute(this.$currentScrollX + x, this.$currentScrollY + y)
		}
		
		public function scrollAbsolute(x:int, y:int):void {
			this.$currentScrollX = x
			this.$currentScrollY = y
			while (this.$currentScrollX > 0) {
				this.$currentScrollX -= textureWidth
			}
			while (this.$currentScrollX <= -textureWidth) {
				this.$currentScrollX += textureWidth
			}
			while (this.$currentScrollY > 0) {
				this.$currentScrollY -= textureHeight
			}
			while (this.$currentScrollY <= -textureHeight) {
				this.$currentScrollY += textureHeight
			}
			var pxFinal:int = this.bitmapData.width
			var pyFinal:int = this.bitmapData.height
			for ( var px:int = this.$currentScrollX; px < pxFinal; px += this.textureWidth ) {
				for ( var py:int = this.$currentScrollY; py < pyFinal; py += this.textureHeight ) {
					if (px < 0) {
						point.x = 0
						rect.x = -px
						rect.width = this.textureWidth + px
					} else {
						point.x = px
						rect.x = 0
						rect.width = this.textureWidth
					}
					if (point.x + rect.width > pxFinal) {
						rect.width = pxFinal - point.x
					}
					if (py < 0) {
						point.y = 0
						rect.y = -py
						rect.height = this.textureHeight + py
					} else {
						point.y = py
						rect.y = 0
						rect.height = this.textureHeight
					}
					if (point.y + rect.height > pyFinal) {
						rect.height = pyFinal - point.y
					}
					this.bitmapData.copyPixels(this.texture, rect, point)
				}
			}
		}
		
	}

}