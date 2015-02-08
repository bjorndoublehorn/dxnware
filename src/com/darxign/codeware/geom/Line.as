package com.darxign.codeware.geom {
	import com.darxign.codeware.Common;
	import com.darxign.codeware.control.identification.Id;
	import flash.geom.Point;
	/**
	 * Intended to contain data about a line.
	 * The line is defined with 2 points.
	 * Pay attantion that if the points coincide the line is treated as vertical.
	 * The line can be of 3 type: SEGMENT, ENDLESS and RAY.
	 * If it's ray, its begin is the first point (x1, y1)
	 * WARNING: Intersection point is only of precision .001
	 * @author darxign
	 */
	public final class Line {
		
		static public const SEGMENT:Id = Id.xtr(1)
		static public const ENDLESS:Id = Id.xtr(2)
		static public const RAY:Id = Id.xtr(3)
		
		private var x1:Number
		private var y1:Number
		private var x2:Number
		private var y2:Number
		
		private var length:Number
		
		private var type:Id
		
		private var isVertical:Boolean
		private var k:Number
		private var b:Number
		
		public function Line(x1:Number, y1:Number, x2:Number, y2:Number, type:Id) {
			this.update(x1, y1, x2, y2, type)
		}
		
		/**
		 * Calculates the coefficients of the linear function
		 * or marks it as a vertical.
		 * @param	x1 the x of the first point of the line
		 * @param	y1 the y of the first point of the line
		 * @param	x2 the x of the second point of the line
		 * @param	y2 the y of the second point of the line
		 * @param	type type of the line
		 */
		public function update(x1:Number, y1:Number, x2:Number, y2:Number, type:Id):void {
			this.x1 = x1
			this.y1 = y1
			this.x2 = x2
			this.y2 = y2
			this.type = type
			
			this.isVertical = x1 == x2 ? true : false
			if (this.isVertical) {
				this.k = 0
				this.b = 0
			} else {
				this.k = (y2 - y1) / (x2 - x1)
				this.b = y1 - this.k * x1
			}
			
			var dX:Number = this.x2 - this.x1
			var dY:Number = this.y2 - this.y1
			this.length = Math.sqrt(dX * dX + dY * dY)
		}
		
		/**
		 * Copies all parameters from another line
		 * @param	line
		 */
		public function copyFrom(line:Line):void {
			this.update(line.x1, line.y1, line.x2, line.y2, line.type)
		}
		
		/**
		 * Tries to determine the coordinates of the intersection of the current line and the inbound line.
		 * The lines are considered to intersect if (and only if) they are neither
		 * parallel nor superimposed.
		 * @param	line the line to intersect with the current line
		 * @return	true if they intersect and false otherwise
		 */
		public function intersect(line:Line, $ip:Point):Boolean {
			if (!this.isVertical && !line.isVertical) {
				if (this.k == line.k) return false
				$ip.x = (line.b - this.b) / (this.k - line.k)
				$ip.y = this.k * $ip.x + this.b
			} else if (this.isVertical && !line.isVertical) {
				$ip.x = this.x1
				$ip.y = line.k * $ip.x + line.b
			} else if (!this.isVertical && line.isVertical) {
				$ip.x = line.x1
				$ip.y = this.k * $ip.x + this.b
			} else {
				return false
			}
			
			/*$ip.x = Common.toFixed($ip.x, 1000)
			$ip.y = Common.toFixed($ip.y, 1000)*/
			
			// check this line for including the $ip point
			var inclusion:Boolean = false
			if (this.type == Line.ENDLESS) {
				inclusion = true
			} else if (this.type == Line.SEGMENT) {
				inclusion = Math.min(this.x1, this.x2) <= $ip.x &&
							$ip.x <= Math.max(this.x1, this.x2) &&
							Math.min(this.y1, this.y2) <= $ip.y &&
							$ip.y <= Math.max(this.y1, this.y2)
			} else if (this.type == Line.RAY) {
				inclusion = this.x1 < this.x2 ? this.x1 <= $ip.x : $ip.x <= this.x1
				if (inclusion) inclusion = this.y1 < this.y2 ? this.y1 <= $ip.y : $ip.y <= this.y1
			}
			if (!inclusion) return false
			
			// check the incoming line for including the $ip point
			inclusion = false
			if (line.type == Line.ENDLESS) {
				inclusion = true
			} else if (line.type == Line.SEGMENT) {
				inclusion = Math.min(line.x1, line.x2) <= $ip.x &&
							$ip.x <= Math.max(line.x1, line.x2) &&
							Math.min(line.y1, line.y2) <= $ip.y &&
							$ip.y <= Math.max(line.y1, line.y2)
			} else if (line.type == Line.RAY) {
				inclusion = line.x1 < line.x2 ? line.x1 <= $ip.x : $ip.x <= line.x1
				if (inclusion) inclusion = line.y1 < line.y2 ? line.y1 <= $ip.y : $ip.y <= line.y1
			}
			
			return inclusion
		}
		
		/**
		 * Populates the $ip point with coordinates that are calculated by adding a distance proportion to the beginning point of the line
		 */
		public final function getPointByDistanceFactor(distanceFactor:Number, $ip:Point):void {
			$ip.x = this.x1 + (this.x2 - this.x1) * distanceFactor
			$ip.y = this.y1 + (this.y2 - this.y1) * distanceFactor
		}
		
		/**
		 * Populates the $ip point with coordinates that are calculated by adding a distance to the beginning point of the line
		 */
		public final function getPointByDistance(distance:Number, $ip:Point):void {
			this.getPointByDistanceFactor(distance / this.length, $ip)
		}
		
		public final function getLength():Number {
			return this.length
		}
		
		public final function getX1():Number {
			return this.x1
		}
		
		public final function getX2():Number {
			return this.x2
		}
		
		public final function getY1():Number {
			return this.y1
		}
		
		public final function getY2():Number {
			return this.y2
		}
		
	}

}