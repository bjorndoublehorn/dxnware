package com.darxign.codeware.animation.route.impl {
	import com.darxign.codeware.animation.route.ARoute;
	import com.darxign.codeware.animation.route.RouteKeyPoint;
	import com.darxign.codeware.animation.route.RouteKeyPointList;
	import com.darxign.codeware.animation.route.segment.ArcRouteSegment;
	import com.darxign.codeware.animation.route.segment.LineRouteSegment;
	import com.darxign.codeware.animation.route.segment.RouteSegment;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * Arc-shaped route. 
	 * The route is smoothed with arcs and lines.
	 * The client must specify not only the basic points but also the radius of smoothing.
	 * Remember that the resulted radius of smoothing depends on the length of the current segment too.
	 * @author darxign
	 */
	public class ArcRoute extends ARoute {
		
		private const lineRouteSegmentBank:Vector.<LineRouteSegment> = new Vector.<LineRouteSegment>(0, true)
		private var lineRouteSegmentBankLength$Full:int = 0
		private var lineRouteSegmentBankLength$Used:int = 0
		
		private const arcRouteSegmentBank:Vector.<ArcRouteSegment> = new Vector.<ArcRouteSegment>(0, true)
		private var arcRouteSegmentBankLength$Full:int = 0
		private var arcRouteSegmentBankLength$Used:int = 0
		
		/**
		 * Inits smoothed route.
		 * @param	points the basic points of the route.
		 * @param	radius the radius of smoothing. Must be greater than 0.
		 */
		public final function initArcRoute(pList:RouteKeyPointList, smoothRadius:Number):void {
			if (pList == null) throw new Error("points is null")
			if (smoothRadius <= 0) throw new Error("smoothRadius is <= 0")
			
			if (pList.$length < 2) {
				throw new Error("There must be at least 2 route points.")
			}
			
			// eliminate coincidence: points_ array must consist of not-coinciding points and the var pointsLength contains its length
			for (var rkp:RouteKeyPoint = pList.$head.$next; rkp; rkp = rkp.$next) {
				if (rkp.x == rkp.$prev.x && rkp.y == rkp.$prev.y) {
					pList.remove(rkp)
					rkp = rkp.$prev
				}
			}
			
			if (pList.$length < 2) {
				throw new Error(pList.$length + " not-coinciding points on the route. Must be at least 2.")
			}
			// NOW: in points_ array at least 2 points
			
			var point:Point = new Point()
			
			this.p = pList
			
			this.segmentList.clear()
			this.lineRouteSegmentBankLength$Used = 0
			this.arcRouteSegmentBankLength$Used = 0
			
			// the rotation of the current p-line
			var rotationCurrent:Number
			
			// the rotation of the next p-line
			// (on the first iteration it's copied to rotationCurrent)
			var rotationNext:Number = geom.getAngleBetween(p.$head.x, p.$head.y, p.$head.$next.x, p.$head.$next.y)
			
			// on the first iteration savedBeta is copied to 'alpha' thus it must be 90 now
			var savedBeta:Number = 90
			
			// the vars for the segment points
			var arc1Center:Point
			var arc2Center:Point
			var tangentBegin:Point
			var tangentEnd:Point
			
			/**
			 * On every iteration we consider a pair of points (the line of which is called p-line) from 'p' array.
			 * It starts from the index 1 coz every p-line is the combination of ([i-1],[i]) points.
			 */
			for (rkp = this.p.$head.$next; rkp; rkp = rkp.$next) {
				rotationCurrent = rotationNext
				// the angle between the current p-line and the bisector between it and the previous p-line
				var alpha:Number = savedBeta
				if (rkp.$next == null) {
					// the last point
					savedBeta = 90
				} else {
					// not the last point
					rotationNext = geom.getAngleBetween(rkp.x, rkp.y, rkp.$next.x, rkp.$next.y)	
					var abreastToNext:Number = geom.getAngleAbreast(rotationCurrent, rotationNext)
					savedBeta = abreastToNext < 0 ? (-180 - abreastToNext) / 2 : (180 - abreastToNext) / 2
				}
				// the angle between the current p-line and the bisector between it and the next p-line:
				var beta:Number = savedBeta
				// NOW: both 'alpha' and 'beta' are in the scope (-90; +90]
				
				// the first point of the p-line
				var B:RouteKeyPoint = rkp.$prev
				
				// the second point of the p-line
				var E:RouteKeyPoint = rkp
				
				// excluding of processing the situation where there must be just a line
				if (alpha == 90 && beta == 90) {
					this.segmentList.add(getLineRouteSegment(B, E))
					continue
				}
				
				// length and half-length of the p-line
				var L:Number = geom.getDistance(B.x, B.y, E.x, E.y)
				var halfL:Number = L / 2
				
				// excluding of processing the situation where there must be just an arc
				if (alpha == 0 && beta == 0 && smoothRadius >= halfL) {
					this.segmentList.add(getArcRouteSegment(B, E, geom.getMiddlePoint(B.x, B.y, E.x, E.y, point).clone(), true))
					continue
				}
				
				var alphaRotation:Number = geom.toNormalScope(rotationCurrent + alpha)
				var betaRotation:Number = geom.toNormalScope(rotationNext + beta)
				
				var alphaRadAbs:Number = geom.toRadians(Math.abs(alpha))
				var betaRadAbs:Number = geom.toRadians(Math.abs(beta))
				
				// rotation between the two arcs
				var arcsRotation:Number
				// radius also can't be greater than halfL
				var r:Number = smoothRadius < halfL ? smoothRadius : halfL
				
				// c-shape:
				if ((alpha >= 0 && beta >= 0) || (alpha < 0 && beta < 0)) {
					
					// inversion radius: the radius that makes c-shape change to s-shape
					// it may be broken when gammaSin == 0 or gammaCos == 1
					// but that condition has already been checked (the situation of 0 and 0 degrees (look above))
					var inversionRadius:Number = 0
					if (alpha != 90 && beta != 90) {
						var gammaRadAbs:Number = geom.toRadians(180 - Math.abs(alpha) - Math.abs(beta))
						var gammaSin:Number = Math.sin(gammaRadAbs)
						var gammaCos:Number = Math.cos(gammaRadAbs)
						inversionRadius = alphaRadAbs < betaRadAbs ?
							 L * ((Math.sin(alphaRadAbs) - Math.sin(betaRadAbs) * gammaCos) / (gammaSin * (1 - gammaCos))) :
							 L * ((Math.sin(betaRadAbs) - Math.sin(alphaRadAbs) * gammaCos) / (gammaSin * (1 - gammaCos)))
					}
										
					if (r > inversionRadius) {
						if (alphaRadAbs < betaRadAbs) {
							beta = beta > 0 ? beta - 180 : beta + 180
							betaRotation = geom.toNormalScope(rotationNext + beta)
							betaRadAbs = geom.toRadians(Math.abs(beta))
						} else {
							alpha = alpha > 0 ? alpha - 180 : alpha + 180
							alphaRotation = geom.toNormalScope(rotationCurrent + alpha)
							alphaRadAbs = geom.toRadians(Math.abs(alpha))
						}
					} else if (r == inversionRadius) {
						// here must be only 2 segments: an arc and a line
						if (alphaRadAbs < betaRadAbs) {
							arc1Center = geom.getEndPoint(B.x, B.y, r, alphaRotation, point).clone()
							tangentBegin = geom.getEndPoint(arc1Center.x, arc1Center.y, r, 180 - betaRotation, point).clone()
							if (alpha >= 0 && beta >= 0) {
								this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, true))
							} else {
								this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, false))
							}
							this.segmentList.add(getLineRouteSegment(tangentBegin, E))
						} else {
							arc2Center = geom.getEndPoint(E.x, E.y, r, betaRotation, point).clone()
							tangentEnd = geom.getEndPoint(arc2Center.x, arc2Center.y, r, 180 - alphaRotation, point).clone()
							this.segmentList.add(getLineRouteSegment(B, tangentEnd))
							if (alpha >= 0 && beta >= 0) {
								this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, true))
							} else {
								this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, false))
							}
						}
						continue
					} else {
						
						// arc centers						
						arc1Center = geom.getEndPoint(B.x, B.y, r, alphaRotation, point).clone()
						arc2Center = geom.getEndPoint(E.x, E.y, r, betaRotation, point).clone()
					
						arcsRotation = geom.getAngleBetween(arc1Center.x, arc1Center.y, arc2Center.x, arc2Center.y)
					
						// angle1 = angle2 = Math.acos((radius1 - radius2) / rotationBetweenArcs) * 180 / Math.PI
						// => angle1 = angle2 = 90
						if (alpha >= 0 && beta >= 0) {
							tangentBegin = geom.getEndPoint(arc1Center.x, arc1Center.y, r, arcsRotation - 90, point).clone()
							tangentEnd = geom.getEndPoint(arc2Center.x, arc2Center.y, r, arcsRotation - 90, point).clone()
							this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, true))
							this.segmentList.add(getLineRouteSegment(tangentBegin, tangentEnd))
							this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, true))
						} else {
							tangentBegin = geom.getEndPoint(arc1Center.x, arc1Center.y, r, arcsRotation + 90, point).clone()
							tangentEnd = geom.getEndPoint(arc2Center.x, arc2Center.y, r, arcsRotation + 90, point).clone()
							this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, false))
							this.segmentList.add(getLineRouteSegment(tangentBegin, tangentEnd))
							this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, false))
						}
						continue
					}
					
				}
				// :c-shape
				
				// s-shape:
				// find the max radius:
				var failure:Boolean = false
				var maxRadius:Number
					
				var a:Number = 1 - Math.cos(alphaRadAbs - betaRadAbs)
				var b:Number = L * (Math.cos(alphaRadAbs) + Math.cos(betaRadAbs))
				var c:Number = - (L * L) / 2
				if (a == 0) {
					if (b != 0) {
						maxRadius = -c / b
					} else {
						failure = true
					}
				} else {
					var d:Number = b * b - 4 * a * c
					if (d >= 0) {
						var x1:Number = ( -b + Math.sqrt(d)) / (2 * a)
						var x2:Number = ( -b - Math.sqrt(d)) / (2 * a)
						maxRadius = x1 > 0 && x2 > 0 ? Math.min(x1, x2) : Math.max(x1, x2)
					} else {
						failure = true
					}
				}
				if (failure || maxRadius <= 0) {
					// throw new Error("S-Shape fails")
					this.segmentList.add(getLineRouteSegment(B, E))
					continue
				}
				
				if (r < maxRadius) {
												
					// arc centers
					arc1Center = geom.getEndPoint(B.x, B.y, r, alphaRotation, point).clone()
					arc2Center = geom.getEndPoint(E.x, E.y, r, betaRotation, point).clone()
					
					var arcsLength:Number = geom.getDistance(arc1Center.x, arc1Center.y, arc2Center.x, arc2Center.y)
					
					var angle:Number = (2 * r) / arcsLength
					// check for miscalculations
					if (!isNaN(angle) && angle < 1) {
						var shiftA:Number = geom.fromRadians(Math.acos(angle))
						var shiftB:Number = shiftA - 180
						arcsRotation = geom.getAngleBetween(arc1Center.x, arc1Center.y, arc2Center.x, arc2Center.y)
						if (alpha >= 0 && beta < 0) {
							tangentBegin = geom.getEndPoint(arc1Center.x, arc1Center.y, r, arcsRotation - shiftA, point).clone()
							tangentEnd = geom.getEndPoint(arc2Center.x, arc2Center.y, r, arcsRotation - shiftB, point).clone()
							this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, true))
							this.segmentList.add(getLineRouteSegment(tangentBegin, tangentEnd))
							this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, false))
						} else {
							tangentBegin = geom.getEndPoint(arc1Center.x, arc1Center.y, r, arcsRotation + shiftA, point).clone()
							tangentEnd = geom.getEndPoint(arc2Center.x, arc2Center.y, r, arcsRotation + shiftB, point).clone()
							this.segmentList.add(getArcRouteSegment(B, tangentBegin, arc1Center, false))
							this.segmentList.add(getLineRouteSegment(tangentBegin, tangentEnd))
							this.segmentList.add(getArcRouteSegment(tangentEnd, E, arc2Center, true))
						}
						continue
					}
				}
				
				// there must be only 2 arcs
				arc1Center = geom.getEndPoint(B.x, B.y, maxRadius, alphaRotation, point).clone()
				arc2Center = geom.getEndPoint(E.x, E.y, maxRadius, betaRotation, point).clone()
				var coincidePoint:Point = geom.getMiddlePoint(arc1Center.x, arc1Center.y, arc2Center.x, arc2Center.y, point).clone()
				if (alpha >= 0 && beta < 0) {
					this.segmentList.add(getArcRouteSegment(B, coincidePoint, arc1Center, true))
					this.segmentList.add(getArcRouteSegment(coincidePoint, E, arc2Center, false))
				} else {
					this.segmentList.add(getArcRouteSegment(B, coincidePoint, arc1Center, false))
					this.segmentList.add(getArcRouteSegment(coincidePoint, E, arc2Center, true))
				}
				
				// :s-shape
			
			}
			
			this.calculateLength()
			
		}
		
		private final function getLineRouteSegment(begin:Point, end:Point):LineRouteSegment {
			var segment:LineRouteSegment
			if (this.lineRouteSegmentBankLength$Used == this.lineRouteSegmentBankLength$Full) {
				this.lineRouteSegmentBank.fixed = false
				segment = new LineRouteSegment()
				this.lineRouteSegmentBank[this.lineRouteSegmentBankLength$Full] = segment
				this.lineRouteSegmentBank.fixed = true
				this.lineRouteSegmentBankLength$Full += 1
			} else {
				segment = this.lineRouteSegmentBank[this.lineRouteSegmentBankLength$Used]
			}
			this.lineRouteSegmentBankLength$Used += 1
			return segment.initLineRouteSegment(begin, end)
		}
		
		private final function getArcRouteSegment(begin:Point, end:Point, center:Point, clockwise:Boolean):ArcRouteSegment {
			var segment:ArcRouteSegment
			if (this.arcRouteSegmentBankLength$Used == this.arcRouteSegmentBankLength$Full) {
				this.arcRouteSegmentBank.fixed = false
				segment = new ArcRouteSegment()
				this.arcRouteSegmentBank[this.arcRouteSegmentBankLength$Full] = segment
				this.arcRouteSegmentBank.fixed = true
				this.arcRouteSegmentBankLength$Full += 1
			} else {
				segment = this.arcRouteSegmentBank[this.arcRouteSegmentBankLength$Used]
			}
			this.arcRouteSegmentBankLength$Used += 1
			return segment.initArcRouteSegment(begin, end, center, clockwise)
		}
		
		/**
		 * Draws the route on a Graphics object.
		 * If some part of the drawing should not be drawn its thickness must be set -1.
		 * @param	g the Graphics to draw on.
		 * @param	pathThickness the thinckness of the route line.
		 * @param	pathColor the color of the route line.
		 * @param	auxiliaryThickness the thickness of the auxiliary lines.
		 * @param	auxiliaryColor the color of the auxiliary lines.
		 * @param	primaryPathThickness the thickness of the primary path.
		 * @param	primaryPathColor the color of the primary path.
		 */
		override public final function draw(g:Graphics,
											pathThickness:Number = 2,
											pathColor:uint = 0,
											auxiliaryThickness:Number = -1,
											auxiliaryColor:uint = 0,
											primaryPathThickness:Number = -1,
											primaryPathColor:int = 0):void
		{
			// draw the primary path
			if (primaryPathThickness!=-1) {
				g.lineStyle(primaryPathThickness, primaryPathColor)
				g.moveTo(this.p.$head.x, this.p.$head.y)
				for ( var rkp:RouteKeyPoint = this.p.$head.$next; rkp; rkp = rkp.$next ) {
					g.lineTo(rkp.x, rkp.y)
				}
			}
			
			// draw the smoothed route
			for ( var segment:RouteSegment = this.segmentList.$head; segment; segment = segment.$next ) {
				segment.draw(g, pathThickness, pathColor, auxiliaryThickness, auxiliaryColor)
			}
			
		}
		
	}

}