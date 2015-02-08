package com.darxign.codeware.animation.tracechain {
	import flash.display.DisplayObject;

	public class TraceChain {
		
		protected var traceObjectArray:Array;
		protected var traceParamsArray:Array;
		
		public function TraceChain(leadObject:DisplayObject) {
			this.traceObjectArray = new Array();
			this.traceParamsArray = new Array();
			this.setObject(0, leadObject);
		}
		
		public function setObject(number:int, object:DisplayObject):void {
			if (object == null) {
				throw new Error("Trace object cannot be null");
			}
			if (this.traceObjectArray.length < number + 1) {
				this.traceObjectArray.length = number + 1;
				this.traceParamsArray.length = number + 1;
			}
			this.traceObjectArray[number] = object;
		}
		
		public function step():void {
			
			var leadObject:DisplayObject = traceObjectArray[0];
			var leadParams:TraceParams = traceParamsArray[0];
			if (leadParams == null) {
				leadParams = new TraceParams();
				traceParamsArray[0] = leadParams;
			}
			leadParams.x = leadObject.x;
			leadParams.y = leadObject.y;
			leadParams.rotation = leadObject.rotation;
			leadParams.alpha = leadObject.alpha;
			
			// move the last params to the first place
			traceParamsArray.splice(0, 0, traceParamsArray.pop());
			
			var prevObject:DisplayObject = this.traceObjectArray[0];
			for (var i:int = 1; i < this.traceObjectArray.length; i++) {
				if (this.traceObjectArray[i] != null) {
					if (this.traceParamsArray[i] == null) {
						this.traceObjectArray[i].visible = false;
					} else {
						var object:DisplayObject = this.traceObjectArray[i] as DisplayObject
						var params:TraceParams = this.traceParamsArray[i] as TraceParams
						object.visible = true;
						object.x = params.x;
						object.y = params.y;
						object.rotation = params.rotation;
						object.alpha = prevObject.alpha * 0.8;
						prevObject = object;
					}
				}
			}
		}
		
		public function clearTail():void {
			for (var i:int = 0; i < this.traceObjectArray.length; i++) {
				if (i != 0 && this.traceObjectArray[i] != null) {
					this.traceObjectArray[i].visible = false;
				}
				this.traceParamsArray[i] = null;
			}
		}
		
	}

}