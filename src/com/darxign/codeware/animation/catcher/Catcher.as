package com.darxign.codeware.animation.catcher {
	import com.darxign.codeware.geom.Geom;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	/**
	 * @author darxign
	 */
	public class Catcher {
		
		private const geom:Geom = Geom.ins
		
		private var params:CatcherParams;
		
		private var object:DisplayObject;			// the object that must be moved
		private var objectPrev:Point;
		
		public var target:Point;
		private var targetPrev:Point;
		
		private var timeProcessed:int;
		
		private var currentSpeed:Number;		
		private var xSpeedProjection:Number;
		private var ySpeedProjection:Number;
		
		public var targetDetected:Boolean;
		public var targetDetectionPoint:Point;
		
		private const metaPoint:Point = new Point();				// ancillary point
		
		public function Catcher(params:CatcherParams) {
			
			this.params = params;
			
			this.objectPrev = new Point();
			
			this.targetPrev = new Point();
			
			this.target = new Point();
			
			this.targetDetectionPoint = new Point();
			
		}
		
		public final function init(object:DisplayObject):void {
			
			this.object = object;
			
			this.objectPrev.x = object.x;
			this.objectPrev.y = object.y;
			
			this.targetPrev.x = this.target.x;
			this.targetPrev.y = this.target.y;
			
			this.timeProcessed = 0;
			this.currentSpeed = this.params.speedMin;
			this.correctSpeedProjection();
			
			this.targetDetected = false;
		}
		
		public final function move(duration:int):void {
			
			// full time to proccess
			var fullTime:int = this.timeProcessed + duration;
			
			/*
			 * count of direction changes.
			 * even if this count is 0, the count of time to process is 1. (it's always 1 more)
			 */
			var updateCount:int = fullTime / this.params.correctionInterval;
			
			for (var i:int = 0; i <= updateCount; i++ ) {
				
				var timeToProcess:int;
				if (i < updateCount) { // not latest segment
					timeToProcess = this.params.correctionInterval - this.timeProcessed;
				} else { // latest segment
					timeToProcess = fullTime - this.timeProcessed;
				}
				
				// register target before moving
				//this.targetDetector.register(this.object.x, this.object.y);
				
				// moving the object
				this.object.x += this.xSpeedProjection * timeToProcess;
				this.object.y += this.ySpeedProjection * timeToProcess;
				
				if (geom.getDistance(object.x, object.y, target.x, target.y) < this.params.detectionRadius) {
					// detection in zone
					this.targetDetected = true;
					this.targetDetectionPoint.x = object.x;
					this.targetDetectionPoint.y = object.y;
				} else if (this.object.x != this.objectPrev.x || this.object.y != this.objectPrev.y) {
					// detection in trace intersection
					this.metaPoint.x = this.object.x;
					this.metaPoint.y = this.object.y;
					this.targetDetected = geom.lineIntersectLine(this.objectPrev, this.metaPoint, this.targetPrev, this.target, this.targetDetectionPoint);
				}
				
				this.timeProcessed += timeToProcess;
				
				// cutting the time segment which is already computed...
				if (this.timeProcessed == this.params.correctionInterval) {
					this.timeProcessed = 0;
					fullTime -= this.params.correctionInterval;
				}
				// ...done
				
				// correction...
				if (this.timeProcessed == 0) {
					this.correctRotation();
					this.correctSpeed();
					this.correctSpeedProjection();
				}
				// ...done
				
				this.objectPrev.x = this.object.x;
				this.objectPrev.y = this.object.y;
				
			}
			
			this.targetPrev.x = this.target.x;
			this.targetPrev.y = this.target.y;
			
		}
		
		/*
		 * Updates rotation
		 */
		private final function correctRotation():void {
			var neededAngle:Number = geom.getAngleBetween(this.object.x, this.object.y, this.target.x, this.target.y);
			if (!isNaN(neededAngle)) {
				var angleDiff:Number = geom.getAngleAbreast(this.object.rotation, neededAngle);
				if (Math.abs(angleDiff) > this.params.rotationSeed) {
					if (angleDiff > 0) {
						this.object.rotation += this.params.rotationSeed;
					} else if (angleDiff < 0) {
						this.object.rotation -= this.params.rotationSeed;
					}
				} else {
					this.object.rotation = neededAngle;
				}
			}
		}
		
		/*
		 * Computes new speed
		 */
		private final function correctSpeed():void {
			if (this.currentSpeed != this.params.speedMax) {
				this.currentSpeed += this.params.acceleration;
				if (this.currentSpeed > this.params.speedMax) {
					this.currentSpeed > this.params.speedMax;
				}
			}
		}
		
		/*
		 * Computes new X and Y speed projections
		 */
		private final function correctSpeedProjection():void {
			var radians:Number = (this.object.rotation * Math.PI) / 180;
			this.xSpeedProjection = Math.sin(radians) * this.currentSpeed;
			this.ySpeedProjection = -Math.cos(radians) * this.currentSpeed;
		}
		
	}

}