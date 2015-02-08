package com.darxign.codeware.animation.route {
	/**
	 * @author darxign
	 */
	public class RouteKeyPointList {
		
		public var $length:int
		
		// the first element in the chain
		public var $head:RouteKeyPoint
		
		// the final element in the chain
		public var $tail:RouteKeyPoint
		
		public final function add(rkp:RouteKeyPoint):void {
			rkp.$prev = this.$tail
			if (this.$tail) {
				this.$tail.$next = rkp
			} else {
				this.$head = rkp
			}
			this.$tail = rkp
			rkp.$next = null
			this.$length += 1
		}
		
		public final function remove(rkp:RouteKeyPoint):void {
			if (rkp == this.$head) {
				this.$head = rkp.$next
			} else {
				rkp.$prev.$next = rkp.$next
			}
			if (rkp == this.$tail) {
				this.$tail = rkp.$prev
			} else {
				rkp.$next.$prev = rkp.$prev
			}
			this.$length -= 1
		}
		
		public final function clear():void {
			this.$head = null
			this.$tail = null
			this.$length = 0
		}
		
	}
	
}