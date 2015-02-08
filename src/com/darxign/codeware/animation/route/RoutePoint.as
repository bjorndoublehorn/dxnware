package com.darxign.codeware.animation.route {
	import com.darxign.codeware.animation.route.segment.RouteSegment;
	import flash.geom.Point;
	/**
	 * Describes geometrical data of an object on a route
	 * @author darxign
	 */
	public class RoutePoint extends Point {
		
		public var $next:RoutePoint
		public var $prev:RoutePoint
		
		public var rotation:Number		// the rotation on this point of the route
		public var segment:RouteSegment	// the segment the point belongs to
		public var shift:Number			// the shift in pixels from the begining of the segment
		
		public var outOfRoute:Boolean	// whether the route point was forced to be at the end or the begin of the route coz it doesn't fit the route distance
		
		public final function cloneRoutePoint():RoutePoint {
			return this.copyRoutePointData(new RoutePoint())
		}
		
		public final function copyRoutePointData(routePoint:RoutePoint):RoutePoint {
			routePoint.x = this.x
			routePoint.y = this.y
			routePoint.rotation = this.rotation
			routePoint.segment = this.segment
			routePoint.shift = this.shift
			routePoint.outOfRoute = this.outOfRoute
			return routePoint
		}
	}

}