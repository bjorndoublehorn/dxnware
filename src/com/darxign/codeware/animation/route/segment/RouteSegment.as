package com.darxign.codeware.animation.route.segment {
	import com.darxign.codeware.animation.route.RoutePoint;
	import com.darxign.codeware.geom.Geom;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * The base class for all the types of segments of a route
	 * @author darxign
	 */
	public class RouteSegment {
		
		protected const geom:Geom = Geom.ins
		
		public var $next:RouteSegment
		public var $prev:RouteSegment
		public var $index:int
		
		public var $begin:Point
		public var $end:Point
		public var $length:Number
		
		/**
		 * Inits a route segment.
		 * @param	begin the start point of the segment.
		 * @param	end the end point of the segment.
		 * @param	length the length of the segment.
		 */
		protected final function initRouteSegment(begin:Point, end:Point, length:Number):RouteSegment {
			this.$begin = begin
			this.$end = end
			this.$length = length
			return this
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
		public function draw(	g:Graphics,
								pathThickness:Number,
								pathColor:uint,
								auxiliaryThickness:Number,
								auxiliaryColor:uint):void { }
		
		/**
		 * Fills the var 'routePoint' with data in accordance with the var 'shift'.
		 * @param	shift the distance from the begin of the segment where the routePoint resides.
		 * @param	routePoint the var that must be filled as the result of work of the method.
		 */
		public function fillRoutePoint(shift:Number, routePoint:RoutePoint):void {
			routePoint.shift = shift
		}
		
	}

}