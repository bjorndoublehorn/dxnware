package com.darxign.codeware.animation.route {
	import flash.geom.Point;
	/**
	 * Describes a point which connects segments of a route
	 * @author darxign
	 */
	public class RouteKeyPoint extends Point {
		
		public var $next:RouteKeyPoint
		public var $prev:RouteKeyPoint
		
		public final function RouteKeyPoint(x:Number, y:Number) {
			super(x, y)
		}
		
	}

}