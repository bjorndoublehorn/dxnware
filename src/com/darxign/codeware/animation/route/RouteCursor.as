package com.darxign.codeware.animation.route {
	import com.darxign.codeware.animation.route.segment.RouteSegment;
	import flash.display.DisplayObject;
	/**
	 * Provides fast and convinient approach of using a route.
	 * It gets attached to a route and an object.
	 * The move method moves the object along the route in accordance with a given distance.
	 * @author darxign
	 */
	public class RouteCursor {
		
		protected var route:ARoute
		protected var object:DisplayObject
		protected var segment:RouteSegment
		protected var shift:Number
		
		/**
		 * Creates a route cursor.
		 * @param	route the route with which the cursor must be connected.
		 * @param	object the object to move.
		 * @param	distance the init distance on the route to place the object.
		 */
		public function RouteCursor(route:ARoute, object:DisplayObject, distance:Number = 0) {
			this.reset(route, object, distance)
		}
		
		/**
		 * @return The route of this cursor
		 */
		public final function getRoute():ARoute {
			return this.route
		}
		
		/**
		 * Resets the data of the cursor.
		 * @param	route		the route along which the object must run.
		 * @param	object		the object to run.
		 * @param	distance	the init distance from the begining of the route to put the object.
		 */
		public final function reset(route:ARoute, object:DisplayObject, distance:Number):void {
			if (route == null) throw new Error("route is null")
			if (object == null) throw new Error("route is null")
			
			this.route = route
			this.object = object
			this.segment = route.getHeadSegment()
			this.shift = 0
			
			this.move(distance)
		}
		
		/**
		 * Updates x, y, and rotation of the object in accordance with the new position on the route.
		 * @param	distance	how many pixels must be added to the current position.
		 * @return	whether the object is out of the route (the path is already finished).
		 */
		public final function move(distance:Number):Boolean {
			var routePoint:RoutePoint = this.route.getRoutePoint(this.shift + distance, this.segment)
			
			this.segment = routePoint.segment
			this.shift = routePoint.shift
			this.object.x = routePoint.x
			this.object.y = routePoint.y
			this.object.rotation = routePoint.rotation
			
			return routePoint.outOfRoute
		}
		
		/**
		 * Populates inbound routePoint with data that would exist after moving at some distance.
		 * @param	distance	how many pixels must be added to the current position.
		 * @param	routePoint The route point to populate
		 * @return If the point is out of route
		 */
		public final function predict(distance:Number, routePoint:RoutePoint):Boolean {
			var internalRoutePoint:RoutePoint = this.route.getRoutePoint(this.shift + distance, this.segment)
			internalRoutePoint.copyRoutePointData(routePoint)
			return routePoint.outOfRoute
		}
		
	}

}