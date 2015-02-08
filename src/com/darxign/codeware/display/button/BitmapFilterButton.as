package com.darxign.codeware.display.button {
	import com.darxign.codeware.Common;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.ui.Mouse;
	/**
	 * An implementation of IButton.
	 * 
	 * The state of BitmapFilterButton is controlled by the next behavior:
	 * One image is used in all possible trigger combinations.
	 * When the button is disabled filtersDisabled are applied.
	 * When the button is enabled the pressed and highlighted triggers take participation:
	 * 		NotPressed+NotHighlighted	is formed by	filtersNotPressed
	 * 		NotPressed+Highlighted		is formed by	filtersNotPressedHl
	 * 		Pressed+NotHighlighted		is formed by	filtersPressed
	 * 		Pressed+Highlighted			is formed by	filtersPressedHl
	 * 
	 * In addition BitmapFilterButton may have constant background and/or upground images which aren't changed when the state changes.
	 * 
	 * It also provides the standard IButton mouse cursor behavior:
	 * When the button is disabled the mouse cursor is a pointer.
	 * When the button is enabled the mouse cursor is a hand.
	 * The use of the hand cursor in the enabled state may be prevented with method handCursorSupport(on:Boolean).
	 * 
	 * @author darxign
	 */
	public class BitmapFilterButton extends Sprite implements IButton {
		
		private var image:DisplayObject
		
		private var filtersDisabled:Array
		private var filtersNotPressed:Array
		private var filtersNotPressedHl:Array
		private var filtersPressed:Array
		private var filtersPressedHl:Array
		
		// triggers
		private var enabled:Boolean
		private var pressed:Boolean
		private var highlighted:Boolean
		
		private var cursorOnDisabled:Boolean
		private var cursorOnNotPressed:Boolean
		private var cursorOnNotPressedHl:Boolean
		private var cursorOnPressed:Boolean
		private var cursorOnPressedHl:Boolean
		
		private var data:*
		
		public function BitmapFilterButton(	background:DisplayObject,
											upground:DisplayObject,
											image:DisplayObject,
											filtersDisabled:Array,
											filtersNotPressed:Array,
											filtersNotPressedHl:Array,
											filtersPressed:Array,
											filtersPressedHl:Array) {
			
			if (filtersDisabled && !Common.oneClassOnly(BitmapFilter, filtersDisabled)) throw new Error("not a BitmapFilter object found in filtersDisabled")
			if (filtersNotPressed && !Common.oneClassOnly(BitmapFilter, filtersNotPressed)) throw new Error("not a BitmapFilter object found in filtersNotPressed")
			if (filtersNotPressedHl && !Common.oneClassOnly(BitmapFilter, filtersNotPressedHl)) throw new Error("not a BitmapFilter object found in filtersNotPressedHl")
			if (filtersPressed && !Common.oneClassOnly(BitmapFilter, filtersPressed)) throw new Error("not a BitmapFilter object found in filtersPressed")
			if (filtersPressedHl && !Common.oneClassOnly(BitmapFilter, filtersPressedHl)) throw new Error("not a BitmapFilter object found in filtersPressedHl")
										
			this.image = image
			this.filtersDisabled = filtersDisabled
			this.filtersNotPressed = filtersNotPressed
			this.filtersNotPressedHl = filtersNotPressedHl
			this.filtersPressed = filtersPressed
			this.filtersPressedHl = filtersPressedHl
			
			if (background) this.addChild(background)
			if (image) this.addChild(image)
			if (upground) this.addChild(upground)
			
			this.enabled = false
			this.pressed = false
			this.highlighted = false
			
			this.buttonMode = true
			this.cursorOnDisabled		= true
			this.cursorOnNotPressed		= true
			this.cursorOnNotPressedHl	= true
			this.cursorOnPressed		= true
			this.cursorOnPressedHl		= true			
			
			this.refresh()
		}
		
		public final function enable(on:Boolean):IButton {
			this.enabled = on
			this.refresh()
			return this
		}
		
		public final function press(on:Boolean):IButton {
			this.pressed = on
			this.refresh()
			return this
		}
		
		public final function highlight(on:Boolean):IButton {
			this.highlighted = on
			this.refresh()
			return this
		}
		
		public final function setHandCursorSupport(onDisabled:Boolean, onNotPressed:Boolean, onNotPressedHl:Boolean, onPressed:Boolean, onPressedHl:Boolean):IButton {
			this.cursorOnDisabled		= onDisabled
			this.cursorOnNotPressed		= onNotPressed
			this.cursorOnNotPressedHl	= onNotPressedHl
			this.cursorOnPressed		= onPressed
			this.cursorOnPressedHl		= onPressedHl
			this.refresh()
			return this
		}
		
		public final function setData(data:*):IButton {
			this.data = data
			return this
		}
		
		public final function isEnabled():Boolean {
			return this.enabled
		}
		
		public final function isPressed():Boolean {
			return this.pressed
		}
		
		public final function isHighlighted():Boolean {
			return this.highlighted
		}
		
		public final function getData():* {
			return this
		}
		
		protected final function refresh():void {
			if (this.image) {
				Common.removeAllFilters(this.image)
				if (this.enabled) {
					if (!this.pressed && !this.highlighted) {
						this.applyFilters(this.filtersNotPressed)
					} else if (!this.pressed && this.highlighted) {
						this.applyFilters(this.filtersNotPressedHl)
					} else if (this.pressed && !this.highlighted) {
						this.applyFilters(this.filtersPressed)
					} else {
						this.applyFilters(this.filtersPressedHl)
					}
				} else {
					this.applyFilters(this.filtersDisabled)
				}
			}
			
			if (this.enabled) {
				if (this.pressed) {
					if (this.highlighted) {
						if (this.cursorOnPressedHl) {
							this.useHandCursor = true
						} else {
							this.useHandCursor = false
						}
					} else {
						if (this.cursorOnPressed) {
							this.useHandCursor = true
						} else {
							this.useHandCursor = false
						}
					}
				} else {
					if (this.highlighted) {
						if (this.cursorOnNotPressedHl) {
							this.useHandCursor = true
						} else {
							this.useHandCursor = false
						}
					} else {
						if (this.cursorOnNotPressed) {
							this.useHandCursor = true
						} else {
							this.useHandCursor = false
						}
					}
				}
			} else {
				if (this.cursorOnDisabled) {
					this.useHandCursor = true
				} else {
					this.useHandCursor = false
				}
			}
			Mouse.show()
		}
		
		private final function applyFilters(filters:Array):void {
			if (filters) {
				for (var i:int = 0; i < filters.length; i++) {
					Common.addFilter(this.image, filters[i])
				}
			}
		}
		
	}

}