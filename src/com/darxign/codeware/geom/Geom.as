package com.darxign.codeware.geom {
	import flash.display.DisplayObject;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	/**
	 * Contains different useful methods for work with geometry.
	 * @author darxign
	 */
	public class Geom {
		
		static public const ins:Geom = new Geom()
		
		/**
		 * Translates degrees of an angle to radians
		 * @param	degrees degrees of the angle
		 * @return	radians of the angle
		 */
		public final function toRadians(degrees:Number):Number {
			return degrees * Math.PI / 180
		}
		
		/**
		 * Translates radians of an angle to degrees
		 * @param	radians radians of the angle
		 * @return	radians of the angle
		 */
		public final function fromRadians(radians:Number):Number {
			return radians * 180 / Math.PI
		}

		
		/**
		 * Calculates the rotation of the vector (x1, y1, x2, y2)
		 * The rotation is the angle between the vertical line through point (x1,y1) and the line ((x1,y1),(x2,y2).
		 * @param	x1 the X of the begin of the vector
		 * @param	y1 the Y of the begin of the vector
		 * @param	x2 the X of the end of the vector
		 * @param	y2 the Y of the end of the vector
		 * @return If it is one and the same point 0 is returned.
		 * Returned angle is in scope (-180, +180]
		 */
		public final function getAngleBetween(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var	dX:Number = x1 - x2
			var	dY:Number = y1 - y2
			if (dX == 0 && dY == 0) return 0
			var angle:Number
			if (x1 == x2 && y1 > y2) {
				angle = 0
			} else if (x1 == x2 && y1 < y2) {
				angle = 180
			} else if (y1 == y2 && x1 < x2) {
				angle = 90
			} else if (y2 == y1 && x2 < x1) {
				angle = -90
			} else {
				angle = -(Math.atan(dX / dY) * 180) / Math.PI
				if (x2 > x1 && y2 > y1) {
					angle += 180;
				} else if (x2 < x1 && y2 > y1) {
					angle -= 180
				}
			}
			return angle
		}
		
		
		/**
		 * Returns the rotation needed for first object to come abreast with second object.
		 * The direction of the rotation (CLOCKWISE / COUNTERCLOCKWISE) is chosen to be nearest.
		 * WARNING: the input rotations must be in the scope (-180, +180].
		 * It's not checked inside the function for the benefit of performance.
		 * @param	r1 the rotation of the first object
		 * @param	r2 the rotation of the second object
		 * @return	a number in the scope [0, +360)
		 */
		public final function getAngleAbreast(r1:Number, r2:Number):Number {
			var abreast:Number = r2 - r1;
			if (abreast <= -180) {
				return abreast + 360;
			} else if (abreast > 180) {
				return abreast - 360;
			}
			return abreast;
		}

		
		/**
		 * Returns the rotation needed for the first object to come abreast with the second object
		 * when the rotation is CLOCKWISE.
		 * WARNING: the input rotations must be in the scope (-180, +180].
		 * It's not checked inside the function for the benefit of performance.
		 * @param	r1 the rotation of the first object
		 * @param	r2 the rotation of the second object
		 * @return	a number in the scope [0, +360)
		 */
		public final function getAngleAbreastClockwise(r1:Number, r2:Number):Number {
			var abreast:Number = r2 - r1
			if (abreast < 0) abreast += 360
			return abreast
		}
		
		/**
		 * Returns the rotation needed for the first object to come abreast with the second object
		 * when the rotation is COUNTERCLOCKWISE.
		 * WARNING: the input rotations must be in the scope (-180, +180].
		 * It's not checked inside the function for the benefit of performance.
		 * @param	r1 the rotation of the first object
		 * @param	r2 the rotation of the second object
		 * @return	a number in the scope (-360, 0]
		 */
		public final function getAngleAbreastCounterclockwise(r1:Number, r2:Number):Number {
			var abreast:Number = r2 - r1
			if (abreast > 0) abreast -= 360
			return abreast
		}
		
		/**
		 * Adapt an angle to be in the scope (-180, +180]
		 * @param	degrees the degrees of the angle
		 * @return	degrees in the scope (-180, +180]
		 */
		public final function toNormalScope(degrees:Number):Number {
			while (degrees <= -180) {degrees += 360}
			while (degrees > 180) {degrees -= 360}
			return degrees
		}
		
		/**
		 * Checks for intersection of endness segments if as_seg is true.
		 * Checks for intersection of endless lines if as_seg is false.
		 * @param	a the first point of the first line.
		 * @param	b the second point of the first line.
		 * @param	c the first point of the second line.
		 * @param	d the second point of the second line.
		 * @param	$ip the point of the intersection.
		 * @param	as_seg how to treat the lines (as a endness or not).
		 * @return	whether there are intersection.
		 */
		public final function lineIntersectLine(a:Point, b:Point, c:Point, d:Point, $ip:Point, as_seg:Boolean = true):Boolean {
			
			var ba_y:Number = b.y-a.y;
			var dc_y:Number = d.y-c.y;
			var ab_x:Number = a.x-b.x;
			var cd_x:Number = c.x-d.x;
			var c1:Number = b.x*a.y - a.x*b.y;
			var c2:Number = d.x*c.y - c.x*d.y;
			
			var denom:Number=ba_y*cd_x - dc_y*ab_x;
			if (denom == 0) {
				return false;
			}
			
			$ip.x=(ab_x*c2 - cd_x*c1)/denom;
			$ip.y=(dc_y*c1 - ba_y*c2)/denom;
			
			//---------------------------------------------------
			//Do checks to see if intersection to endpoints
			//distance is longer than actual Segments.
			//Return null if it is with any.
			//---------------------------------------------------
			if(as_seg){
				if(Math.pow($ip.x - b.x, 2) + Math.pow($ip.y - b.y, 2) > Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2)) {
					return false;
				}
				if(Math.pow($ip.x - a.x, 2) + Math.pow($ip.y - a.y, 2) > Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2)) {
					return false;
				}
				
				if(Math.pow($ip.x - d.x, 2) + Math.pow($ip.y - d.y, 2) > Math.pow(c.x - d.x, 2) + Math.pow(c.y - d.y, 2)) {
					return false;
				}
				if(Math.pow($ip.x - c.x, 2) + Math.pow($ip.y - c.y, 2) > Math.pow(c.x - d.x, 2) + Math.pow(c.y - d.y, 2)) {
					return false;
				}
			}
			
			
			/*   SPEED UP - NEED TO CHECK
			  if ( as_seg ) {
				var n0:Number
				var n1:Number
				var n2:Number
				var n3:Number
				var n4:Number
				var n5:Number
				var n6:Number
				var n7:Number
				var v0:Number
				var v1:Number
				var vr0:Number
				var vr1:Number;
				n0 = ip.x – p_a1.x;
				n1 = ip.y – p_a1.y;
				v0 = p_a0.y – p_a1.y;
				vr0 = b1 * b1 + v0 * v0;
				if ( n0 * n0 + n1 * n1 > vr0 ) return null;
				n2 = ip.x – p_a0.x;
				n3 = ip.y – p_a0.y;
				if ( n2 * n2 + n3 * n3 > vr0 ) return null;
				n4 = ip.x – p_b1.x;
				n5 = ip.y – p_b1.y;
				v1 = p_b0.y – p_b1.y;
				vr1 = b2 * b2 + v1 * v1;
				if ( n4 * n4 + n5 * n5 > vr1 ) return null;
				n6 = ip.x – p_b0.x;
				n7 = ip.y – p_b0.y;
				if ( n6 * n6 + n7 * n7 > vr1 ) return null;
			}*/
			
			return true;
		}
		
		/**
		 * Returns the distance from (x1,y1) to (x2,y2).
		 * @param	x1 the X of the first point.
		 * @param	y1 the Y of the first point.
		 * @param	x2 the X of the second point.
		 * @param	y2 the Y of the second point.
		 * @return	the distance from (x1,y1) to (x2,y2).
		 */
		public final function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var dX:Number = x1 - x2;
			var dY:Number = y1 - y2;
			return Math.sqrt(dX * dX + dY * dY);
		}
		
		/**
		 * Finds the middle point of the line (x1, y1, x2, y2)
		 * @param	x1 the X of the first line point
		 * @param	y1 the Y of the first line point
		 * @param	x2 the X of the second line point
		 * @param	y2 the Y of the second line point
		 */
		public final function getMiddlePoint(x1:Number, y1:Number, x2:Number, y2:Number, $point:Point):Point {
			$point.x = (x1 + x2) / 2
			$point.y = (y1 + y2) / 2
			return $point
		}
		
		/**
		 * Forms the end point of a ray.
		 * The point (startX, startY) is the start point.
		 * @param	startX the X of the start point.
		 * @param	startY the Y of the start point.
		 * @param	length the length of the ray.
		 * @param	rotation the rotation of the ray.
		 */
		public final function getEndPoint(startX:Number, startY:Number, length:Number, rotation:Number, $endPoint:Point):Point {
			var radians:Number;
			
			radians = (rotation * Math.PI) / 180;
			var dx:Number = Math.sin(radians) * length;
				
			radians = ((180 - rotation) * Math.PI) / 180;
			var dy:Number = Math.cos(radians) * length;
			
			$endPoint.x = startX + dx;
			$endPoint.y = startY + dy;
			
			return $endPoint
		}
		
		/**
		 * Fills the $commands and $data vectors with necessary info about an arc drawing.
		 * These vars may be used when Graphics.drawPath(...) is invoked.
		 * @param	x the X of the arc centre.
		 * @param	y the Y of the arc centre.
		 * @param	radius the radius of the arc.
		 * @param	angle the angle of the arc. Use positive for clockwise and negative for counterclockwise.
		 * @param	startAngle the angle to start building the arc.
		 * @param	$commands the vector for commands of the class GraphicsPathCommand.
		 * @param	$data the vector for coordinates.
		 */
		public final function buildArc(x:Number,
										y:Number,
										radius:Number,
										angle:Number,
										startAngle:Number,
										$commands:Vector.<int>,
										$data:Vector.<Number>):void
		{
			
			$commands.length = 0
			$data.length = 0
			
			var n:Number = Math.ceil(Math.abs(angle) / 45)
			var angleA:Number = (angle / n) * Math.PI / 180
			var halfAngleA:Number = angleA / 2
			var cosHalfAngleA:Number = Math.cos(halfAngleA)
			
			startAngle = startAngle * Math.PI / 180
			
			var startB:Number = startAngle
			
			//start edge
			$commands.push(GraphicsPathCommand.WIDE_MOVE_TO)
			$data.push(NaN, NaN, x + radius * Math.sin(startAngle), y - radius * Math.cos(startAngle))
			
			//outer arc
			for (var i:int=0; i < n; i++) {
				startAngle += angleA
				
				var angleMid1:Number=startAngle - halfAngleA
				var bx:Number = x + radius / cosHalfAngleA * Math.sin(angleMid1)
				var by:Number = y - radius / cosHalfAngleA * Math.cos(angleMid1)
				var cx:Number = x + radius * Math.sin(startAngle)
				var cy:Number = y - radius * Math.cos(startAngle)
				
				$commands.push(GraphicsPathCommand.CURVE_TO)
				$data.push(bx, by, cx, cy)
			}
			
		}
		
		/**
		 * Sets the coordinates of an object so that the point (x, y) gets to the center of the object.
		 * @param	object the object to centrate.
		 * @param	x the X of the control point.
		 * @param	y the Y of the control point.
		 * @param	round whether the result of the calculations must be fractional.
		 */
		public final function center(object:DisplayObject, x:Number, y:Number, round:Boolean = true):void {
			object.x = x - object.width / 2
			object.y = y - object.height / 2
			if (round) {
				object.x = Math.round(object.x)
				object.y = Math.round(object.y)
			}
		}
		
	}

}