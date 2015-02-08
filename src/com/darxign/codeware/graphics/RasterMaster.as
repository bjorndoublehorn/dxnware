package com.darxign.codeware.graphics {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author darxign
	 */
	public class RasterMaster {
		
		static public const FLIP_NOTHING:int = 0
		static public const FLIP_HORIZONTAL:int = 1
		static public const FLIP_VERTICAL:int = 2
		static public const FLIP_HORIZONTAL_AND_VERTICAL:int = 3
		
		static public const ROTATE_NOTHING:int = 0
		static public const ROTATE_CLOCKWISE:int = 1
		static public const ROTATE_COUNTERCLOCKWISE:int = 2
		
		static public function transform (
		bitmapData:BitmapData,
		flipType:int,
		rotationType:int,
		leftRightCorner:Point,
		operationalField1:BitmapData,
		operationalField2:BitmapData):BitmapData {
			
			var a:int = 1, d:int = 1, tx:int = 0, ty:int = 0
			
			var ofRect:Rectangle = operationalField1.rect
			
			if (flipType == FLIP_HORIZONTAL || flipType == FLIP_HORIZONTAL_AND_VERTICAL) {
				a = -1
				tx = ofRect.width
			}
			
			if (flipType == FLIP_VERTICAL || flipType == FLIP_HORIZONTAL_AND_VERTICAL) {
				d = -1
				ty = ofRect.height
			}
			
			var matrix:Matrix = new Matrix(a, 0, 0, d , tx, ty)
			
			if (rotationType == ROTATE_CLOCKWISE) {
				matrix.concat(new Matrix(0, 1, -1, 0, ofRect.width, 0))
			} else if (rotationType == ROTATE_COUNTERCLOCKWISE) {
				matrix.concat(new Matrix(0, -1, 1, 0, 0, ofRect.height))
			}
			
			ofRect.x = leftRightCorner.x
			ofRect.y = leftRightCorner.y
			operationalField1.copyPixels(bitmapData, ofRect, new Point())
			
			ofRect.x = 0
			ofRect.y = 0
			operationalField2.fillRect(ofRect, 0)
			operationalField2.draw(operationalField1, matrix)
			
			bitmapData.copyPixels(operationalField2, ofRect, leftRightCorner)
			
			return bitmapData
		}
		
		static public function simpleTransform (
		sourceBitmapData:BitmapData,
		destBitmapData:BitmapData,
		flipType:int,
		rotationType:int):BitmapData {
			
			var a:int = 1, d:int = 1, tx:int = 0, ty:int = 0
			
			var ofRect:Rectangle = sourceBitmapData.rect
			
			if (flipType == FLIP_HORIZONTAL || flipType == FLIP_HORIZONTAL_AND_VERTICAL) {
				a = -1
				tx = ofRect.width
			}
			
			if (flipType == FLIP_VERTICAL || flipType == FLIP_HORIZONTAL_AND_VERTICAL) {
				d = -1
				ty = ofRect.height
			}
			
			var matrix:Matrix = new Matrix(a, 0, 0, d , tx, ty)
			
			if (rotationType == ROTATE_CLOCKWISE) {
				matrix.concat(new Matrix(0, 1, -1, 0, ofRect.width, 0))
			} else if (rotationType == ROTATE_COUNTERCLOCKWISE) {
				matrix.concat(new Matrix(0, -1, 1, 0, 0, ofRect.height))
			}
			
			destBitmapData.fillRect(ofRect, 0)
			destBitmapData.draw(sourceBitmapData, matrix)
			
			return destBitmapData
		}
		
		static public function colorTransform(bitmapData:BitmapData, colorTransform:ColorTransform, rect:Rectangle = null):BitmapData {
			if (!rect) {
				rect = bitmapData.rect
			}
			bitmapData.colorTransform(rect, colorTransform)
			return bitmapData
		}
		
		static public function switchChannels(bitmapData:BitmapData, channel1:uint, channel2:uint, rect:Rectangle = null):BitmapData {
			if (!rect) {
				rect = bitmapData.rect
			}
			var copyBitmapData:BitmapData = bitmapData.clone()
			bitmapData.copyChannel(copyBitmapData, rect, new Point(0, 0), channel1, channel2)
			bitmapData.copyChannel(copyBitmapData, rect, new Point(0, 0), channel2, channel1)
			return bitmapData
		}
		
		static public function applyFilter(bitmapData:BitmapData, filter:BitmapFilter, rect:Rectangle = null):BitmapData {
			if (!rect) {
				rect = bitmapData.rect
			}
			bitmapData.applyFilter(bitmapData, rect, new Point(0, 0), filter)
			return bitmapData
		}
		
	}
		
}