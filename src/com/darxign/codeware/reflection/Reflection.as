package com.darxign.codeware.reflection {
	import com.darxign.codeware.Common;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	/**
	 * Wrapper for AS3 reflection.
	 * Every Reflection Object (RO) represents a type of the flash environment or the application.
	 * Opposed to the standard library methods "flash.utils.getQualifiedClassName" and "flash.utils.getQualifiedSuperClassName"
	 * this class considers instances of the class Class as they really are, not as instances of the classes that they describe.
	 * @author darxign
	 */
	public final class Reflection {
		
		// the key for the constructor's protection
		static private const key:Object = new Object()
		
		// Reflection Objects by corresponding class objects
		static private const classCache:Dictionary = new Dictionary()
		// Reflection Objects by corresponding class objects
		static private const classNameCache:Dictionary = new Dictionary()
		// Reflection Objects by corresponding instances
		static private const instanceCache:Dictionary = new Dictionary(true)
		
		/**
		 * @param	classObject A given class object
		 * @return	The Reflection Object of the type that the given class object desribes.
		 */
		static public function forClass(classObject:Class):Reflection {
			
			if (classObject == null) return null
			
			// search in classCache
			var result:Reflection = Reflection.classCache[classObject]
			if (result != null) return result
			
			// search in classNameCache
			var describedClassName:String = getQualifiedClassName(classObject)
			result = Reflection.classNameCache[describedClassName]
			if (result != null) {
				Reflection.classCache[classObject] = result
				return result
			}
			
			// fill classNameCache with all the reflection chain
			var classNameChain:Array = [describedClassName]
			var classNameChainXML:XMLList = describeType(classObject).factory.extendsClass
			for (var i:int = 0, length:int = classNameChainXML.length(); i < length; i++ ) {
				classNameChain.push(classNameChainXML[i].@type.toString())
			}

			// create reflection and its predecessors
			result = Reflection.constructReflectionChain(classNameChain)
			Reflection.instanceCache[classObject] = result
			return result
		}
		
		/**
		 * @param	instance A given instance to be reflected.
		 * @return	The Reflection Object of the type that is defining for the given instance.
		 */
		static public function forInstance(instance:Object):Reflection {
			
			if (instance == null) return null
			
			// search in instanceCache
			var result:Reflection = Reflection.instanceCache[instance]
			if (result != null) return result
			
			// search in classNameCache
			var definingClassName:String = instance is Class ? "Class" : getQualifiedClassName(instance)
			result = Reflection.classNameCache[definingClassName]
			if (result != null) {
				Reflection.instanceCache[instance] = result
				return result
			}
			
			// fill classNameCache with all the reflection chain
			var classNameChain:Array = [definingClassName]
			var classNameChainXML:XMLList = describeType(instance).extendsClass
			for (var i:int = instance is Class ? 1 : 0, length:int = classNameChainXML.length(); i < length; i++ ) {
				classNameChain.push(classNameChainXML[i].@type.toString())
			}
			
			// create reflection and its predecessors
			result = Reflection.constructReflectionChain(classNameChain)
			Reflection.instanceCache[instance] = result
			return result
		}
		
		/**
		 * Fills the classNameCache with the Reflection Objects that are referred to by class names in the given array "classNameChain".
		 * @param	classNameChain	An array with class names where the first element is the farthest descendant
		 * 							and the last element is the farthest predecessor.
		 * @return	The Reflection Object that is referred by the first element in the classNames array.
		 */		
		static private function constructReflectionChain(classNameChain:Array):Reflection {
			var reflectionParent:Reflection = null
			var reflection:Reflection = null
			for (var i:int = classNameChain.length - 1; i >= 0; i--) {
				reflection = Reflection.classNameCache[classNameChain[i]]
				if (reflection == null) {
					reflection = new Reflection(classNameChain[i], reflectionParent, Reflection.key)
					Reflection.classNameCache[classNameChain[i]] = reflection
				}
				reflectionParent = reflection
			}
			return reflection
		}
		
		// the Reflection Object of the type that is the supertype to this Reflection Object's type.
		private var parent:Reflection
		// the full className of this Reflection Object's type.
		private var className:String
		/**
		 * Creates a Reflection Object.
		 * @param key The constructor's protection.
		 * @param parent The Reflection Object of the type that is the supertype to this Reflection Object's type.
		 */
		public function Reflection(className:String, parent:Reflection, key:Object) {
			Common.checkKeys(Reflection.key, key)
			this.className = className
			this.parent = parent
		}
		
		public function toString():String {
			return this.className
		}
		
		/**
		 * @return The Reflection Object of the type that is the supertype to this Reflection Object's type.
		 * If this Reflection Object describes the type "Object" then null is returned.
		 */
		public final function getParent():Reflection {
			return this.parent
		}
		
		/**
		 * Finds out whether this Reflection Object's type is a descendant to the type of another Reflection Object.
		 * @param	reflection Another Reflection Object that is supposed to be a predecessor to this Reflection Object.
		 * @return	True - if this RO's type is a descendant (i.e. any subtype) to the given RO's type, False - otherwise.
		 */
		public final function isDescendantOf(reflection:Reflection):Boolean {
			if (this == reflection) return false
			var cursorReflection:Reflection = this
			var suspectedReflection:Reflection = null
			while (cursorReflection != null) {
				suspectedReflection = cursorReflection.getParent()
				if (suspectedReflection == reflection) return true
				cursorReflection = suspectedReflection
			}
			return false
		}
		
	}
}