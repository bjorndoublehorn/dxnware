package com.darxign.codeware.display.text.raster {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Raster font.
	 * @author darxign
	 */
	public class RasterFont {
		
		static public const SMALL_LETTERS_SET:String	= "abcdefghijklmnopqrstuvwxyz";
		static public const BIG_LETTERS_SET:String		= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
			
		protected var interval:int;
		protected var chars:Array;
		protected var charHeight:int;
			
		protected var _rect:Rectangle = new Rectangle();
		protected var _point:Point = new Point();
		
		/*
		 * fontImage - image with symbols
		 * symbolSet - array of correspondance between fontImage and real symbols
		 * interval - pixel count between two symbols when typing. WARNING: in the font file must always be 1 pixel between 2 symbols.
		 * charHeight - default height of every char
		 * ...rest - set of [s, x] arrays where s:String - a symbol string from symbolSet, x:int - their custom width
		 */
		public function RasterFont(fontData:BitmapData, symbolSet:String, interval:int, ...charWidths) {
			
			// validation...
			if (fontData == null)	throw new Error("fontData mustn't be null");
			if (symbolSet == null)	throw new Error("symbolSet mustn't be null");
			if (interval < 0)		throw new Error("interval must be 0 or more");
			
			this.charHeight = fontData.height
			
			var checkSymbols:String = "";
			for (var i:int = 0; i < charWidths.length; i++) {
				if (charWidths[i] is Array) {
					var cw:Array = charWidths[i]; // cw - chars and width, for example: ['abc',13]
					var seq:String = cw[0] as String;
					if (seq) {
						if (seq.length != 0) {
							for (var n:int = 0; n < seq.length; n++) {
								if (symbolSet.indexOf(seq.charAt(n)) == -1) {
									throw new Error("charWidths[" + i + "][0]: no such symbol in symbolSet: " + seq.charAt(n));
								}
								if (checkSymbols.indexOf(seq.charAt(n)) != -1) {
									throw new Error("charWidths[" + i + "][0]: symbol already exists in charWidths: " + seq.charAt(n));
								}
								checkSymbols = checkSymbols.concat(seq.charAt(n));
							}
						} else {
							throw new Error("charWidths[" + i + "][0]: must be at least 1 symbol");
						}
					} else {
						throw new Error("charWidths[" + i + "][0]: must be a String");
					}
					if (cw[1] is int) {
						if (cw[1] < 1) {
							throw new Error("charWidths[" + i + "][1]: must be more than 0");
						}
					} else {
						throw new Error("charWidths[" + i + "][1]: must be an int");
					}
				} else {
					throw new Error("charWidths[" + i + "]: must be an array");
				}
			}
			var checkSymbolSet:String = "";
			for (i = 0; i < symbolSet.length; i++) {
				if (checkSymbolSet.indexOf(symbolSet.charAt(i)) != -1) {
					throw new Error("symbolSet[" + i + "]: symbol '" + symbolSet.charAt(i) + "' already exists in symbolSet");
				}
				if (checkSymbols.indexOf(symbolSet.charAt(i)) == -1) {
					throw new Error("symbolSet[" + i + "]: symbol '" + symbolSet.charAt(i) + "' has no width");
				}
				checkSymbolSet = checkSymbolSet.concat(symbolSet.charAt(i));
			}
			
			// prepare widths...
			this.chars = new Array();
			for (i = 0; i < symbolSet.length; i++) {
				this.chars[symbolSet.charCodeAt(i)] = null;
			}
			for (i = 0; i < charWidths.length; i++) {
				cw = charWidths[i];
				seq = cw[0];
				for (var j:int = 0; j < seq.length; j++) {
					this.chars[seq.charCodeAt(j)] = cw[1];
				}
			}
			// ...done
			
			var summaryWidth:int = -1;
			for (i = 0; i < symbolSet.length; i++) {
				summaryWidth += this.chars[symbolSet.charCodeAt(i)] + 1;
			}
			if (fontData.width < summaryWidth) {
				throw new Error("fontImage hasn't necessary width");
			}
			
			// ...done
			
			// create bitmap datas...
			//var fontData:BitmapData = new BitmapData(fontImage.width, fontImage.height, true, 0);
			//fontData.draw(fontImage);
			
			_rect.x = -1;
			_rect.y = 0;
			_rect.height = charHeight;
			_rect.width = 0;
			_point.x = 0;
			_point.y = 0;
			
			for (i = 0; i < symbolSet.length; i++) {
				_rect.x = _rect.x + _rect.width + 1;
				_rect.width = int(this.chars[symbolSet.charCodeAt(i)]);
				
				var char:BitmapData = new BitmapData(_rect.width, _rect.height, true, 0);
				char.copyPixels(fontData, _rect, _point);
				this.chars[symbolSet.charCodeAt(i)] = char;
			}
			// ...done
			
			this.interval = interval;
			this.charHeight = charHeight;
		}
		
		/*
		 * Draws the string of the text object as a set of images
		 */
		public final function draw(text:RasterText):void {
			
			var txtString:String = text.getString();
			var txtLength:int
			if (txtString == null || (txtLength = txtString.length) == 0) {
				text.getContent().bitmapData = null
				return
			};
			
			var w:int = (txtString.length - 1) * this.interval;
			var h:int = this.charHeight;
			for (var i:int = 0; i < txtLength; i++) {
				if (this.chars[txtString.charCodeAt(i)] == null) {
					this.chars[txtString.charCodeAt(i)] = new BitmapData(this.charHeight, this.charHeight)
				}
				w += (this.chars[txtString.charCodeAt(i)] as BitmapData).width;
			}
			
			_rect.x = 0;
			_rect.y = 0;
			_rect.width = w;
			_rect.height = h;
			
			var txtData:BitmapData = text.getContent().bitmapData;
			
			if (txtData && txtData.width == w && txtData.height == h) {
				txtData.fillRect(_rect, 0);
			} else {
				if (txtData) {
					txtData.dispose()
				}
				txtData = new BitmapData(w, h, true, 0);
			}
			
			_point.x = 0;
			_point.y = 0;
			
			for (i = 0; i < txtLength; i++) {
				var data:BitmapData = this.chars[txtString.charCodeAt(i)];
				_rect.width = data.width;
				_rect.height = data.height;
				txtData.copyPixels(data, _rect, _point);
				_point.x += _rect.width + this.interval;
			}
			
			text.getContent().bitmapData = txtData;
		}
		
		public final function getCharHeight():int {
			return this.charHeight;
		}
		
		public final function getCharWidth(charCode:Number):int {
			return this.getChar(charCode).width;
		}
		
		public final function getTextWidth(txtString:String):int {
			var txtLength:int = txtString.length;
			var w:int = (txtLength - 1) * this.interval;
			for (var i:int = 0; i < txtLength; i++) {
				w += this.getChar(txtString.charCodeAt(i)).width;
			}
			return w;
		}
		
		private final function getChar(charCode:Number):BitmapData {
			var char:BitmapData = this.chars[charCode];
			if (!char) {
				// chars that don't exist must all be just a square
				char = new BitmapData(this.charHeight, this.charHeight);
				this.chars[charCode] = char;
			}
			return char;
		}
		
		public final function getInterval():int {
			return this.interval;
		}
		
	}

}