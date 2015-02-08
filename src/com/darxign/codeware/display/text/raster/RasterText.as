package com.darxign.codeware.display.text.raster {
	import com.darxign.codeware.control.identification.Id;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * Serves as a graphic object for a raster text.
	 * @author darxign
	 */
	public class RasterText extends Sprite {
		
		static public const ALIGN_CENTER:Id = Id.xtr(1)
		static public const	ALIGN_LEFT:Id = Id.xtr(2)
		static public const	ALIGN_RIGHT:Id = Id.xtr(3)
		
		protected var content:Bitmap;
		protected var font:RasterFont;
		protected var string:String;
		protected var align:Id;
		
		public function RasterText(string:String, font:RasterFont, align:Id) {
			this.addChild(this.content = new Bitmap());
			this.string = string;
			if (font == null) throw new Error("font must be provided");
			this.font = font;
			this.font.draw(this);
			this.setAlign(align);
		}
		
		public final function getString():String {
			return this.string;
		}
		
		public final function setString(string:String):void {
			if (this.string == string) {
				return;
			}
			this.string = string;
			this.font.draw(this);
			this.setAlign(this.align);
		}
		
		public final function getFont():RasterFont {
			return this.font;
		}
		
		public final function setFont(font:RasterFont):void {
			if (font == null) throw new Error("font must be provided")
			this.font = font;
			this.font.draw(this);
			this.setAlign(this.align);
		}
		
		public final function setAlign(align:Id):void {
			switch (align) {
				case RasterText.ALIGN_CENTER:
				this.content.x = -this.content.width / 2;
				break;
				case RasterText.ALIGN_LEFT:
				this.content.x = 0;
				break;
				case RasterText.ALIGN_RIGHT:
				this.content.x = -this.content.width;
				break;
				default: throw new Error("wrong align id");
			}
			this.align = align;
		}
		
		public final function getContent():Bitmap {
			return this.content;
		}
		
	}

}