package com.darxign.codeware.animation.route {
	import com.darxign.codeware.animation.route.segment.RouteSegment;
	import com.darxign.codeware.animation.route.segment.RouteSegmentList;
	import com.darxign.codeware.geom.Geom;
	import flash.display.Graphics;
	/**
	 * @abstract
	 * The base class for routs.
	 * It's considered abstract so it's forbidden for instantiating.
	 * Only its subclasses can represent a real route.
	 * The main target of the class is to represent a smoothed path on a surface.
	 * The path is determined with control points that are set as an incoming parameter.
	 * The path through the points is made rounded in accordance with the smoothRadius.
	 * @author darxign
	 */
	public class ARoute {

		public var $length:Number // full length of the route

		protected var geom:Geom = Geom.ins
		
		protected const segmentList:RouteSegmentList = new RouteSegmentList() // contains all the segments
		protected var p:RouteKeyPointList // contains the real points of the path
		
		/**
		 * Draws the path, its auxiliary markup and primary path on g:Graphics.
		 * @param	g
		 * @param	pathThickness - thickness of the main path line
		 * @param	pathColor - color of the main path line
		 * @param	auxiliaryThickness - thickness of the auxiliary lines
		 * @param	auxiliaryColor - color of the auxiliary lines
		 * @param	primaryPathThickness - thickness of the primary path
		 * @param	primaryPathColor - color of the primary path
		 * Primary path - the path that would be if only the key points were presented.
		 * If the lines of a linetype mustn't be shown - its thickness must be -1.
		 */
		public function draw(	g:Graphics,
						pathThickness:Number = 2,
						pathColor:uint = 0,
						auxiliaryThickness:Number = 1,
						auxiliaryColor:uint = 0x333333,
						primaryPathThickness:Number = -1,
						primaryPathColor:int = 0xFF0000):void { }
		
	
		/**
		 * Calculates a route point on the distance of "distance" pixels
		 * from the begin of the segment with "startSegment" index.
		 * Thus the startSegment must reside in the diapason of [0; segmentsCount - 1].
		 * If the result position of the point goes under 0 (or over full length) it becomes 0 (or full length)
		 * and the route point is given the outOfRoute flag.
		 * @param	distance		the count of pixels from the begining of the startSegment.
		 * @param	startSegment	the segment from the begin of which the distance is calculated.
		 * @return 	[CACHED] route point. Note: this object is cached, so in order to work with it
		 * after calling the method you need to make a copy. (Just invoke the clone() method).
		 */
		protected const _routePoint_:RoutePoint = new RoutePoint() // [CACHE]
		public final function getRoutePoint(distance:Number, startSegment:RouteSegment = null):RoutePoint {
			if (!startSegment) {
				startSegment = this.segmentList.$head
			}
			var sLength:Number
			if (distance > 0) {
				for (var segment:RouteSegment = startSegment; segment; segment = segment.$next) {
					sLength = segment.$length
					if (distance >= sLength) {
						distance -= sLength
					} else {
						segment.fillRoutePoint(distance, this._routePoint_)
						this._routePoint_.segment = segment
						this._routePoint_.shift = distance
						this._routePoint_.outOfRoute = false
						return this._routePoint_
					}
				}
				this.segmentList.$tail.fillRoutePoint(this.segmentList.$tail.$length, this._routePoint_)
				this._routePoint_.segment = this.segmentList.$tail
				this._routePoint_.shift = this.segmentList.$tail.$length
				this._routePoint_.outOfRoute = true
				return this._routePoint_
			} else {
				for (segment = startSegment.$prev; segment; segment = segment.$prev) {
					sLength = segment.$length
					// CODE
					if (-distance >= sLength) {
						distance += sLength
					} else {
						segment.fillRoutePoint(sLength + distance, this._routePoint_)
						this._routePoint_.segment = segment
						this._routePoint_.shift = sLength + distance
						this._routePoint_.outOfRoute = false
						return this._routePoint_
					}
				}
				this.segmentList.$head.fillRoutePoint(0, this._routePoint_)
				this._routePoint_.segment = this.segmentList.$head
				this._routePoint_.shift = 0
				this._routePoint_.outOfRoute = true
				return this._routePoint_
			}
			
		}
		
		public final function getHeadSegment():RouteSegment {
			return this.segmentList.$head
		}
		
		/**
		 * Calculates the full length of the route.
		 * It must be invoked in subclasses just after creating the segments.
		 */
		protected final function calculateLength():void {
			
			// calculate the overall length
			this.$length = 0
			for (var segment:RouteSegment = this.segmentList.$head; segment; segment = segment.$next) {
				this.$length += segment.$length
			}
			
		}
		
	}
	
}