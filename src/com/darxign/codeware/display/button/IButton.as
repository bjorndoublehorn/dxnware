package com.darxign.codeware.display.button {
	/**
	 * Interface for buttons
	 * @author darxign
	 */
	public interface IButton {
		
		function enable(on:Boolean):IButton
		function press(on:Boolean):IButton
		function highlight(on:Boolean):IButton
		
		function isEnabled():Boolean
		function isPressed():Boolean
		function isHighlighted():Boolean
		
	}
	
}