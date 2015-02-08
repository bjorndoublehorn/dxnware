package com.darxign.codeware.animation.straightmover {
	import com.darxign.codeware.geom.Geom;
	import flash.display.DisplayObject;
	/**
	 * Moves a DisplayObject along a straight path.
	 * @author darxign
	 */
	public class StraightMover {
		
		private const geom:Geom = Geom.ins
		
		private var object:DisplayObject
		
		private var speed:Number
		
		private var startX:Number
		private var startY:Number
		
		private var targetX:Number
		private var targetY:Number
		
		public var $distanceGone:Number
		public var $distanceFull:Number
		
		public var $timeGone:int
		public var $timeFull:int
		
		public var $isTargetDetected:Boolean
		
		/**
		 * Initializes the SM for moving.
		 * @param	object This object will be moved.
		 * @param	targetX The target's coord X
		 * @param	targetY The target's coord Y
		 * @param	speed The speed of movement.
		 * @param	distanceCorrection Adds / Subtracts a value from the calculated path distance.
		 */
		public final function init(object:DisplayObject, targetX:Number, targetY:Number, speed:Number, distanceCorrection:Number = 0):void {
			
			this.object = object
			
			this.speed = speed
			if (this.speed == 0) {
				this.speed = 1
			}
			
			this.$distanceFull = geom.getDistance(object.x, object.y, targetX, targetY)
			
			this.startX = object.x
			this.startY = object.y
			
			var c:Number = (this.$distanceFull + distanceCorrection) / this.$distanceFull
			
			this.targetX = this.startX + (targetX - this.startX) * c
			this.targetY = this.startY + (targetY - this.startY) * c
			
			this.$distanceGone = 0
			this.$distanceFull += distanceCorrection
			if (this.$distanceFull == 0) {
				this.$distanceFull = 1
			}
			
			this.$timeGone = 0
			this.$timeFull = this.$distanceFull / this.speed
			
			this.$isTargetDetected = false
			
			this.object.x = this.startX
			this.object.y = this.startY
		}
		
		/**
		 * Moves the object towards the finish.
		 * @param	duration
		 */
		public final function move(duration:int):void {
			
			this.$timeGone += duration
			
			var c:Number = this.$timeGone / this.$timeFull
			
			this.object.x = this.startX + (this.targetX - this.startX) * c
			this.object.y = this.startY + (this.targetY - this.startY) * c
			
			this.$distanceGone = geom.getDistance(this.startX, this.startY, this.object.x, this.object.y)
			
			if (this.$distanceGone >= this.$distanceFull) {
				this.object.x = this.targetX
				this.object.y = this.targetY
				this.$isTargetDetected = true
			}
			
		}
		
	}
	
}