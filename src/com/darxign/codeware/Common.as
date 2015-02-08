package com.darxign.codeware {
	import com.darxign.codeware.reflection.Reflection;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.BitmapFilter;
	/**
	 * Helper class for common tasks.
	 * @author darxign
	 */
	public class Common {
		
		/**
		 * If 2 keys are null or not equal it throws an exception.
		 */
		static public function checkKeys(key1:Object, key2:Object):void {
			if (key1 == null) throw new Error("key1 is null")
			if (key2 == null) throw new Error("key2 is null")
			if (key1 != key2) throw new Error("the keys arent equal")
		}
		
		/**
		 * @return The index of a maximal Number in an array.
		 */
		static public function indexOfMax(numberArray:Array):int {
			var length:uint = numberArray.length
			if (length == 0) throw new Error("no elements in numberArray")
			var index:uint = 0
			var number:Number = numberArray[index]
			for (var i:uint = 1; i < length; i++) {
				var newNumber:Number = numberArray[i]
				if (newNumber > number) {
					number = newNumber
					index = i
				}
			}
			return index
		}
		
		/**
		 * Checks whether an array contains elements of a necessary class or its subclasses.
		 * @param	array The array with elements.
		 * @param	classObject The class to coinside with.
		 * @param	nullElementsEligible Whether null elements should be treated as correct coincidence.
		 * @return	True - if the array contains elements of only the necessary class or its subclasses or the array is empty; False - otherwise.
		 * @throws	An exception if the array is null.
		 */
		static public function oneClassOnly(classObject:Class, array:Array, nullElementsEligible:Boolean = false):Boolean {
			if (!array) throw new Error("array is null")
			if (array.length == 0) return true
			var object:Object
			if (classObject) {
				for each (object in array) {
					if (object != null) {
						if (!(object is classObject)) {
							return false
						}
					} else {
						return false
					}
				}
			} else {
				if (!nullElementsEligible) {
					throw new Error("classObject is null however null elements aren't allowed")
				}
				for each (object in array) {
					if (object != null) return false
				}
			}
			return true
		}
		
		/**
		 * Checks whether an array contains elements of one and only class.
		 * This method returns false if an element is of a subclass of the necessary type.
		 * To consider subclasses eligible use the method Common.oneClassOnly(...)
		 * @param	array The array with elements.
		 * @param	classObject The class to coinside with.
		 * @return	True - if the array contains elements of only the necessary class or the array is empty, False - otherwise.
		 * @throws	An exception if the array is null.
		 */
		static public function oneExactClassOnly(classObject:Class, array:Array, nullElementsEligible:Boolean = false):Boolean {
			if (!array) throw new Error("array is null")
			if (array.length == 0) return true
			var object:Object
			if (classObject) {
				var reflection:Reflection = Reflection.forClass(classObject)
				for each (object in array) {
					if (object != null) {
						if (Reflection.forInstance(object) != reflection) {
							return false
						}
					} else {
						return false
					}
				}
			} else {
				if (!nullElementsEligible) {
					throw new Error("classObject is null however null elements aren't allowed")
				}
				for each (object in array) {
					if (object != null) return false
				}
			}
			return true
		}
		
		/**
		 * @return If the Reflection of an object equals the Reflection of a class.
		 */
		static public function equalByReflection(instance:Object, classObject:Class):Boolean {
			return Reflection.forInstance(instance) == Reflection.forClass(classObject)
		}
		
		/**
		 * @return A random integer from low to high including.
		 */
		static public function random(low:int, high:int):int {
			return Math.floor(Math.random() * ((high + 0.49) - (low - 0.49))) + low;
		}
		
		/**
		 * @return True or False randomly
		 */
		static public function either():Boolean {
			return Common.random(0, 1) == 0
		}
		
		/**
		 * Rounds a fractional number.
		 * @param	number The number to round.
		 * @param	factor How many symbols after the comma you want to have.
		 * @return	Rounded number
		 */
		static public function toFixed(number:Number, factor:int):Number {
			return Math.round(number * factor)/factor
		}
		
		/**
		 * @return A random value from an array.
		 */
		static public function anyInArray(a:Array):* {
			return a[Common.random(0, a.length - 1)]
		}
		
		/**
		 * Removes a child DisplayObject from its parent DisplayObjectContainer if possible
		 */
		static public function detach(child:DisplayObject):void {
			if (child != null) {
				var parent:DisplayObjectContainer = child.parent
				if (parent != null) {
					parent.removeChild(child)
				}
			}
		}
		
		/**
		 * Adds a child DisplayObject to a parent DisplayObjectContainer if possible.
		 */
		static public function attach(parent:DisplayObjectContainer, child:DisplayObject, index:int = -1):void {
			if (parent != null && child != null && !parent.contains(child)) {
				if (index == -1) {
					parent.addChild(child)
				} else {
					parent.addChildAt(child, index)
				}
			}
		}
		
		/**
		 * Traverse an object if it's a DisplayObjectContainer.
		 * If an object in the tree is a bitmap, than its bitmapData is disposed() and removed.
		 * @return null for more convinient writing of nullifying in 1 line: obj = Common.dispose(obj)
		 */
		static public function destroy(object:DisplayObject):* {
			if (object is DisplayObjectContainer) {
				var doc:DisplayObjectContainer = object as DisplayObjectContainer
				while (doc.numChildren > 0) {
					Common.destroy(doc.removeChildAt(0))
				}
			} else if (object is Bitmap) {
				var bitmap:Bitmap = object as Bitmap
				bitmap.bitmapData.dispose()
				bitmap.bitmapData = null
				trace("d")
			}
			return null
		}
		
		/**
		 * Adds a new filter to an object.
		 * If the filter or the object are null the method does nothing.
		 * @param	object The target object that should be given a filter.
		 * @param	filter A filter to add to the target object.
		 * @param	times How many times the filter must be added (1 by default)
		 */
		static public function addFilter(object:DisplayObject, filter:BitmapFilter, times:uint = 1):DisplayObject {
			if (object == null || filter == null) return object
			var filters:Array = object.filters;
			// first time
			if (filters == null) {
				filters = [filter]
			} else {
				filters.push(filter)
			}
			// the rest
			for (var i:int = 1; i < times; i++) {
				filters.push(filter)
			}
			// apply
			object.filters = filters
			return object
		}
		
		/**
		 * Replaces the object's filters with the given filter.
		 * This method differs from the method addFilter() so that the object loses the filters 
		 * that are of the given filter's class before the new filter is added.
		 * @param	object The target object to be given a new filter.
		 * @param	filter A filter to add to the target object.
		 */
		static public function replaceEqualFilters(object:DisplayObject, filter:BitmapFilter):void {
			if (object == null || filter == null) return
			var filters:Array = object.filters
			if (filters == null) {
				filters = [filter]
			} else {
				var filterReflection:Reflection = Reflection.forInstance(filter)
				for (var i:int = 0, length:int = filters.length; i < length; i++) {
					if (Reflection.forInstance(filters[i]) == filterReflection) {
						filters.splice(i, 1)
						length--
						i--
					}
				}
				filters.push(filter)
			}
			object.filters = filters
		}
		
		/**
		 * Removes the filters (which are of the given Reflection Object's type) from the given target object.
		 * @param	object The target object with filters.
		 * @param	filterReflection The Reflection Object that describes the type of the filters to be removed.
		 */
		static public function removeFiltersByReflection(object:DisplayObject, filterReflection:Reflection):void {
			if (object == null || object.filters == null || filterReflection == null) return
			var filters:Array = object.filters
			for (var i:int = 0, length:int = filters.length; i < length; i++) {
				if (Reflection.forInstance(filters[i]) == filterReflection) {
					filters.splice(i, 1)
					length--
					i--
				}
			}
			object.filters = filters
		}
		
		/**
		 * Removes all the filters of the given object
		 * @param	object An object with filters
		 */
		static public function removeAllFilters(object:DisplayObject):void {
			if (object == null || object.filters == null) return
			var filters:Array = object.filters;
			filters.length = 0;
			object.filters = filters;
		}
		
		/**
		 * Calculates roots of a square equation and fills in the $results array with them.
		 * @param	$results The array for square roots
		 * @return	The array with result
		 */
		static public function getQuadraticRoots(a:Number, b:Number, c:Number, $results:Array):Array {
			var sqt:Number = Math.sqrt(Math.pow(b, 2) - 4*a*c)
			var root1:Number = (b+sqt)/(2*a)
			var root2:Number = (b - sqt) / (2 * a)
			$results.length = 0
			if (!isNaN(root1)) {
				$results[0] = root1
			}
			if (!isNaN(root2)) {
				$results[1] = root2
			}
			return $results
		}
		
		static public function setMouseEnableRecursively(parent:DisplayObjectContainer, on:Boolean):void {
			parent.mouseEnabled = on
			for (var i:int = 0, l:int = parent.numChildren; i < l; i += 1) {
				var ch:DisplayObjectContainer = parent.getChildAt(i) as DisplayObjectContainer
				if (ch) {
					setMouseEnableRecursively(ch, on)
				}
			}
		}
		
	}

}