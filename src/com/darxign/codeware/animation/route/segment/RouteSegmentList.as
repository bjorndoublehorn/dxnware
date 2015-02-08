package com.darxign.codeware.animation.route.segment {
	/**
	 * @author darxign
	 */
	public class RouteSegmentList {
		
		public var $length:int
		
		// the first element in the chain
		public var $head:RouteSegment
		
		// the final element in the chain
		public var $tail:RouteSegment
		
		public final function add(rs:RouteSegment):void {
			rs.$prev = this.$tail
			if (this.$tail) {
				this.$tail.$next = rs
			} else {
				this.$head = rs
			}
			this.$tail = rs
			rs.$next = null
			rs.$index = this.$length
			this.$length += 1
		}
		
		public final function remove(rs:RouteSegment):void {
			if (rs == this.$head) {
				this.$head = rs.$next
			} else {
				rs.$prev.$next = rs.$next
			}
			if (rs == this.$tail) {
				this.$tail = rs.$prev
			} else {
				rs.$next.$prev = rs.$prev
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