package com.darxign.codeware.graphics {
	import flash.display.Graphics;
	
	/**
	 * @author darxign
	 * Remember to specify lineStyle, beginFill and endFill in the client code.
	 */
	public class VectorMaster {
		
		/**
		 * Draws an arc on your shape
		 * @param	shape The 
		 * @param	x The X of the arc center
		 * @param	y The Y of the arc center
		 * @param	r The inner radius
		 * @param	R The outer radius
		 * @param	angle The whole angle of the arc
		 * @param	startAngle The start andgle
		 */
		static public function drawSector(
		graphics:Graphics,
		x:Number,
		y:Number,
		r:Number,
		R:Number,
		wholeAngle:Number,
		startAngle:Number):Graphics {
			
			startAngle -= 90
			if (Math.abs(wholeAngle) > 360) {
				wholeAngle = 360
			}
			var n:Number = Math.ceil(Math.abs(wholeAngle) / 45)
			var angleA:Number = wholeAngle / n
			angleA = angleA * Math.PI / 180
			startAngle = startAngle * Math.PI / 180
			var startB:Number = startAngle
			//start edge
			graphics.moveTo(x + r * Math.cos(startAngle), y + r * Math.sin(startAngle))
			if (wholeAngle != 360) {
				graphics.lineTo(x + R * Math.cos(startAngle), y + R * Math.sin(startAngle))
			} else {
				graphics.moveTo(x + R * Math.cos(startAngle), y + R * Math.sin(startAngle))
			}
			//outer arc
			for (var i:int = 1; i <= n; i++) {
				startAngle += angleA
				var angleMid1:Number = startAngle - angleA / 2
				var bx:Number = x + R / Math.cos(angleA / 2) * Math.cos(angleMid1)
				var by:Number = y + R / Math.cos(angleA / 2) * Math.sin(angleMid1)
				var cx:Number = x + R * Math.cos(startAngle)
				var cy:Number = y + R * Math.sin(startAngle)
				graphics.curveTo(bx, by, cx, cy)
			}
			// start position of inner arc
			if (wholeAngle != 360) {
				graphics.lineTo(x + r * Math.cos(startAngle), y + r * Math.sin(startAngle))
			} else {
				graphics.moveTo(x + r * Math.cos(startAngle), y + r * Math.sin(startAngle))
			}
			//inner arc
			for (var j:int = n; j >= 1; j--) {
				startAngle -= angleA
				var angleMid2:Number = startAngle + angleA / 2
				var bx2:Number = x + r / Math.cos(angleA / 2) * Math.cos(angleMid2)
				var by2:Number = y + r / Math.cos(angleA / 2) * Math.sin(angleMid2)
				var cx2:Number = x + r * Math.cos(startAngle)
				var cy2:Number = y + r * Math.sin(startAngle)
				graphics.curveTo(bx2, by2, cx2, cy2)
			}
			// end position of inner arc.
			if (wholeAngle != 360) {
				graphics.lineTo(x + r * Math.cos(startB), y + r * Math.sin(startB))
			} else {
				graphics.moveTo(x + r * Math.cos(startB), y + r * Math.sin(startB))
			}
			
			return graphics
		}
		
		static public function drawArc(
		graphics:Graphics,
		x:Number,
		y:Number,
		R:Number,
		angle:Number,
		startAngle:Number):Graphics {
			
			startAngle -= 90
			if (Math.abs(angle) > 360) {
				angle = 360
			}
			var n:Number = Math.ceil(Math.abs(angle) / 45)
			var angleA:Number = angle / n
			angleA = angleA * Math.PI / 180
			startAngle = startAngle * Math.PI / 180
			var startB:Number = startAngle
			//start edge
			graphics.moveTo(x + R * Math.cos(startAngle), y + R * Math.sin(startAngle))
			//arc
			for (var i:int = 1; i <= n; i++) {
				startAngle += angleA
				var angleMid1:Number = startAngle - angleA / 2
				var bx:Number = x + R / Math.cos(angleA / 2) * Math.cos(angleMid1)
				var by:Number = y + R / Math.cos(angleA / 2) * Math.sin(angleMid1)
				var cx:Number = x + R * Math.cos(startAngle)
				var cy:Number = y + R * Math.sin(startAngle)
				graphics.curveTo(bx, by, cx, cy)
			}
			
			return graphics
		}
		
		static public function drawDashedArc(
		graphics:Graphics,
		x:Number,
		y:Number,
		R:Number,
		angle:Number,
		startAngle:Number,
		dashLength:Number,
		gapLength:Number,
		autoSpace:Boolean):Graphics {

			if (autoSpace==true) {

				var circumference:Number = 2 * Math.PI * R;

				var howMany:int = circumference / (dashLength+gapLength);
				var leftOverDivided:Number = (circumference % (dashLength+gapLength)) / howMany;

				gapLength=leftOverDivided/2+gapLength;
				dashLength=leftOverDivided/2+dashLength;

			}

			var dashArcLength:Number = (360 * dashLength) / (2 * Math.PI * R)
			var gapArcLength:Number = (360 * gapLength) / (2 * Math.PI * R)

			for (var i:Number=-dashArcLength / 2; i<360-dashArcLength/2; i=i+dashArcLength+gapArcLength) {

				var sx:Number = R * Math.cos( (i)*(Math.PI/180) )
				var sy:Number = R * Math.sin( (i)*(Math.PI/180) )
				
				VectorMaster.drawArc(graphics, x, y, R, dashArcLength, i)

			}
			
			return graphics
		}
	
	}

}