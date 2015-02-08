package com.darxign.codeware.animation.route.segment {
	import com.darxign.codeware.animation.route.RoutePoint;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * Arc segment of a route
	 * @author darxign
	 */
	public class ArcRouteSegment extends RouteSegment {
		
		// drawing helpers
		private const vectorInt_:Vector.<int> = new Vector.<int>()
		private const vectorNumber_:Vector.<Number> = new Vector.<Number>()
		
		public var $center:Point
		public var $angle:Number
		public var $radius:Number
		public var $rotationBegin:Number
		
		/**
		 * Inits an arc segment.
		 * @param	begin the start point of the segment.
		 * @param	end the end point of the segment.
		 * @param	center the center point of the implicit circle.
		 * @param	clockwise the rotation direction. If 'False' it's counterclockwise.
		 */
		public final function initArcRouteSegment(begin:Point, end:Point, center:Point, clockwise:Boolean):ArcRouteSegment {
			var _rotationBegin:Number = geom.getAngleBetween(center.x, center.y, begin.x, begin.y)
			var _rotationEnd:Number = geom.getAngleBetween(center.x, center.y, end.x, end.y)
			var _angle:Number = clockwise ? geom.getAngleAbreastClockwise(_rotationBegin, _rotationEnd) : geom.getAngleAbreastCounterclockwise(_rotationBegin, _rotationEnd)
			var _radius:Number = geom.getDistance(center.x, center.y, begin.x, begin.y)
			this.$center = center
			this.$angle = _angle
			this.$radius = _radius
			this.$rotationBegin = _rotationBegin
			this.initRouteSegment(begin, end, Math.PI * this.$radius * Math.abs(this.$angle) / 180)
			return this
		}
		
		/**
		 * Fills the var "routePoint" with data in accordance with the var "shift".
		 * @param	shift the distance from the begin of the segment where the routePoint resides.
		 * @param	routePoint the var that must be filled as the result of work of the method.
		 */
		override public final function fillRoutePoint(shift:Number, routePoint:RoutePoint):void {
			super.fillRoutePoint(shift, routePoint)
			var r:Number = this.$rotationBegin + this.$angle * shift / this.$length
			geom.getEndPoint(this.$center.x, this.$center.y, this.$radius, r, routePoint)
			routePoint.rotation = geom.toNormalScope(this.$angle >=0 ? r + 90 : r - 90)
		}
		
		/**
		 * Draws the path and its auxiliary markup.
		 * Note: to not show the lines of a linetype set its thickness to -1.
		 * @param	g the Graphics to draw on.
		 * @param	pathThickness the thickness of the main path line
		 * @param	pathColor the color of the main path line
		 * @param	auxiliaryThickness the thickness of the auxiliary lines
		 * @param	auxiliaryColor the color of the auxiliary lines
		 */
		override public final function draw(g:Graphics,
											pathThickness:Number,
											pathColor:uint,
											auxiliaryThickness:Number,
											auxiliaryColor:uint
		):void {

			if (auxiliaryThickness!=-1) {
				g.lineStyle(auxiliaryThickness, auxiliaryColor)
				g.moveTo(this.$begin.x, this.$begin.y)
				g.lineTo(this.$center.x, this.$center.y)
				g.lineTo(this.$end.x, this.$end.y)
			}
			
			if (pathThickness!=-1) {
				geom.buildArc(this.$center.x, this.$center.y, this.$radius, this.$angle, this.$rotationBegin, this.vectorInt_, this.vectorNumber_)
				g.lineStyle(pathThickness, pathColor)
				g.drawPath(vectorInt_, vectorNumber_)
			}
			
			this.vectorInt_.length = 0
			this.vectorNumber_.length = 0
			
		}
		
	}

}