package com.darxign.codeware.animation.catcher {
	
	public class CatcherParams {
		
		public var correctionInterval:int		// (c-interval) segment of time after which correction occurs
		
		public var acceleration:Number			// speed of speed increasing (pixels/c-interval)
		public var speedMin:Number				// minimal speed (pixels/c-interval)
		public var speedMax:Number				// maximal speed (pixels/c-interval)
		
		public var detectionRadius:Number		// zone of target detection
		
		public var rotationSeed:Number			// how many angles the object must rotate after every correction (angles/c-interval)
		
	}

}