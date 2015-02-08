package com.darxign.codeware.animation.route.segment {
	import com.darxign.codeware.animation.route.RoutePoint;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * Straight segment of a route
	 * @author darxign
	 */
	public class LineRouteSegment extends RouteSegment {
		
		public var $rotation:Number
		
		/**
		 * Creates a line segment.
		 * @param	begin the start point of the segment.
		 * @param	end the end point of the segment.
		 */
		public final function initLineRouteSegment(begin:Point, end:Point):LineRouteSegment {
			var xLength:Number = begin.x - end.x
			var yLength:Number = begin.y - end.y
			this.$rotation = geom.getAngleBetween(begin.x, begin.y, end.x, end.y)
			this.initRouteSegment(begin, end, Math.sqrt(xLength * xLength + yLength * yLength))
			return this
		}
		
		/**
		 * Fills the var "routePoint" with data in accordance with the var "shift".
		 * @param	shift the distance from the begin of the segment where the routePoint resides.
		 * @param	routePoint the var that must be filled as the result of work of the method.
		 */
		override public final function fillRoutePoint(shift:Number, routePoint:RoutePoint):void {
			super.fillRoutePoint(shift, routePoint)
			var part:Number = shift / this.$length
			routePoint.x = this.$begin.x + (this.$end.x - this.$begin.x) * part
			routePoint.y = this.$begin.y + (this.$end.y - this.$begin.y) * part
			routePoint.rotation = this.$rotation
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
			if (pathThickness!=-1) {
				g.lineStyle(pathThickness, pathColor)
				g.moveTo(this.$begin.x, this.$begin.y)
				g.lineTo(this.$end.x, this.$end.y)
			}
		}
		
	}

}