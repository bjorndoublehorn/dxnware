package com.darxign.codeware.control.hub.impl {
	/**
	 * Implies that an object which is locked by a Locker may hold the reference to the locker.
	 * Class Locker automatically checks if a newly prepared entity is Lockerized and if it is
	 * then method ofLocker() is invoked.
	 * It's mostly used for self-unlocking.
	 * @author darxign
	 */
	public interface Lockerized {
		
		/**
		 * Generally this method must presave the locker in the object
		 */
		function setLocker(locker:Locker):void
		
	}
	
}