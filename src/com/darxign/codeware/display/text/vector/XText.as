package com.darxign.codeware.display.text.vector {
	import com.darxign.codeware.Constant;
	import com.darxign.codeware.control.identification.Id;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * Wrapper for TextField supporting centration.
	 * @author darxign
	 */
	public class XText extends Sprite {
		
		static public const X_POSITION_AT_LEFT:Id = Id.xtr(1)
		static public const X_POSITION_AT_CENTER:Id = Id.xtr(2)
		static public const X_POSITION_AT_RIGHT:Id = Id.xtr(3)
		
		static public const Y_POSITION_AT_TOP:Id = Id.xtr(4)
		static public const Y_POSITION_AT_CENTER:Id = Id.xtr(5)
		static public const Y_POSITION_AT_BOTTOM:Id = Id.xtr(6)
		
		protected var textField:TextField
		protected var xPosition:Id
		protected var yPosition:Id
		
		public function XText(text:String, textFormat:TextFormat, xPosition:Id, yPosition:Id) {
			this.textField = new TextField()
			this.textField.autoSize = TextFieldAutoSize.LEFT
			this.textField.defaultTextFormat = textFormat
			this.textField.embedFonts = true
			this.textField.background = false
			this.textField.selectable = false
			this.textField.mouseEnabled = false
			if (text == null) text = ""
			this.textField.text = text
			this.xPosition = xPosition
			this.yPosition = yPosition
			this.update()
			this.addChild(this.textField)
		}
		
		public final function setText(text:String):void {
			this.textField.text = text
			this.update()
		}
		
		private final function update():void {
			switch (this.xPosition) {
				case X_POSITION_AT_LEFT:	this.textField.x = 0; break;
				case X_POSITION_AT_CENTER:	this.textField.x = -this.textField.width / 2; break;
				case X_POSITION_AT_RIGHT:	this.textField.x = -this.textField.width; break;
				default: throw new Error(Constant.ERROR_WRONG_ID);
			}
			switch (this.yPosition) {
				case Y_POSITION_AT_TOP:		this.textField.y = 0; break;
				case Y_POSITION_AT_CENTER:	this.textField.y = -this.textField.height / 2; break;
				case Y_POSITION_AT_BOTTOM:	this.textField.y = -this.textField.height; break;
				default: throw new Error(Constant.ERROR_WRONG_ID);
			}
		}
		
	}
	
}