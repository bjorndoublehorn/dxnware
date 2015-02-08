package com.darxign.codeware.control {
	import com.darxign.codeware.reflection.Reflection;
	import flash.utils.Dictionary;
	/**
	 * Validator for singleton.
	 * 
	 * VALID USAGE
	 * There are 2 methods to validate on singleton.
	 * Both MUST be invoked only once in the constructor of your class.
	 * If you create your singleton object from static code of the class
	 * (for example: static public instance:Sngl = new Sngl) use method "staticConstructionCheck()".
	 * In other cases use method "dynamicConstructionCheck".
	 * 
	 * On the first valdation it won't throw any errors.
	 * On the further validations SINGLETON_ERROR will be thrown.
	 * 
	 * @author darxign
	 */
	public class Singleton {
		
		static private const SINGLETON_ERROR:String = "this class is a singleton and it was instantiated before"
		
		static private const registry:Dictionary = new Dictionary()
		
		/**
		 * @param	reflection The reflection of the class being validated.
		 */
		static public function dynamicConstructionCheck(reflection:Reflection):void {
			if ( Singleton.registry[reflection] == null ) {
				Singleton.registry[reflection] = true
			} else {
				throw new Error(Singleton.SINGLETON_ERROR)
			}
		}
		
		/**
		 * If the class object is null throws an error.
		 * @param	currentClass
		 */
		static public function staticConstructionCheck(thisClass:Class):void {
			if (thisClass != null) {
				throw new Error(Singleton.SINGLETON_ERROR)
			}
		}
		
	}

}