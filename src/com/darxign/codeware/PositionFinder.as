package com.darxign.codeware {
	/**
	 * Finds the positions of an object in an array
	 * @author ZePrgorams
	 */
	public class PositionFinder {
		
		static protected const positions:Array = new Array()
		
		/**
		 * Search the position of an object in an array.
		 * The main point of the function is its possibility to search in a multidimensional array.
		 * @param	object the object to search.
		 * @param	array the array to search in.
		 * @param	$result the array to set the result info to.
		 * @return	whether the object is found. Only first found position is returned.
		 */
		static public function findPositions(object:Object, array:Array, $result:Array):Boolean {
			
			if (object == null) throw new Error("object is null")
			if (array == null) throw new Error("array is null")
			if ($result == null) throw new Error("$result is null")
			
			PositionFinder.preparePosition(0, 0, array)
			var currentDepth:int = 0
			var currentArray:Array = PositionFinder.positions[currentDepth][1] as Array
			
			while (true) {
				var rollback:Boolean = true
				for (var i:int = PositionFinder.positions[currentDepth][0] as int, length:int = currentArray.length; i < length; i++) {
					if (currentArray[i] != null) {
						if (currentArray[i] === object) {
							// create result
							$result.length = currentDepth + 1
							for (var n:int = 0; n < currentDepth;  n++) {
								$result[n] = PositionFinder.positions[n][0]
							}
							$result[currentDepth] = i
							return true
						} else if (currentArray[i] is Array) {
							PositionFinder.preparePosition(currentDepth, i, currentArray)
							currentDepth++
							currentArray = currentArray[i] as Array
							PositionFinder.preparePosition(currentDepth, 0, currentArray)
							rollback = false
							break
						}
					}
				}
				if (rollback) {
					currentDepth--
					PositionFinder.positions[currentDepth][0] = PositionFinder.positions[currentDepth][0] + 1
					currentArray = PositionFinder.positions[currentDepth][1]
				}
			}
			
			// the object not found
			return false
			
		}
		
		static private function preparePosition(depth:int, entryIndex:int, array:Array):void {
			if (PositionFinder.positions[depth] == null) PositionFinder.positions[depth] = new Array()
			PositionFinder.positions[depth][0] = entryIndex
			PositionFinder.positions[depth][1] = array
		}
		
	}

}