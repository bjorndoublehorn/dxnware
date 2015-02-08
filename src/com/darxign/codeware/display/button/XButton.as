package com.darxign.codeware.display.button {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.ui.Mouse;
	/**
	 * An implementation of IButton.
	 * 
	 * The state of XButton is controlled by the next behavior:
	 * When it's disabled it has only one possible representation provided by imgDisabled.
	 * When it's enabled it may have 4 possible representations.
	 * 
	 * There are 2 approaches (called modes) to construct the representation of the enabled state: Replace and Combine.
	 * 
	 * The Replace Mode:
	 * Each of the 4 possible trigger combinations has its own image:
	 * 		NotPressed+NotHighlighted	is formed by	imgNotPressed
	 * 		NotPressed+Highlighted		is formed by	imgNotPressedHl
	 * 		Pressed+NotHighlighted		is formed by	imgPressed
	 * 		Pressed+Highlighted			is formed by	imgPressedHl
	 * 
	 * The Combine Mode:
	 * Highlighted states are formed by highlighted images overlapping basic image:
	 * 		NotPressed+NotHighlighted	is formed by	imgNotPressed
	 * 		NotPressed+Highlighted		is formed by	imgNotPressedHl over imgNotPressed
	 * 		Pressed+NotHighlighted		is formed by	imgPressed
	 * 		Pressed+Highlighted			is formed by	imgPressedHl over imgPressed
	 * 
	 * In addition XButton may have constant background and/or upground images which aren't changed when the state changes.
	 * 
	 * It also provides the standard IButton mouse cursor behavior:
	 * When the button is disabled the mouse cursor is a pointer.
	 * When the button is enabled the mouse cursor is a hand.
	 * The use of the hand cursor in the enabled state may be prevented with method handCursorSupport(on:Boolean).
	 * 
	 * @author darxign
	 */
	public class XButton extends Sprite implements IButton {
		
		static public const REPLACE_MODE:int = 1	// each state has its own image
		static public const COMBINE_MODE:int = 2	// each state is a combination of basic and highlight image
		
		private var mode:int
		
		private var imgBackground:DisplayObject
		private var imgUpground:DisplayObject
		
		private var imgDisabled:DisplayObject
		private var imgNotPressed:DisplayObject
		private var imgNotPressedHl:DisplayObject
		private var imgPressed:DisplayObject
		private var imgPressedHl:DisplayObject
		
		// triggers
		private var enabled:Boolean
		private var pressed:Boolean
		private var highlighted:Boolean
		
		private var cursorOnDisabled:Boolean
		private var cursorOnNotPressed:Boolean
		private var cursorOnNotPressedHl:Boolean
		private var cursorOnPressed:Boolean
		private var cursorOnPressedHl:Boolean
		
		public function XButton(imgBackground:DisplayObject,
								imgUpground:DisplayObject,
								imgDisabled:DisplayObject,
								imgNotPressed:DisplayObject,
								imgNotPressedHl:DisplayObject,
								imgPressed:DisplayObject,
								imgPressedHl:DisplayObject,
								mode:int)
		{
			if (mode != XButton.REPLACE_MODE && mode != XButton.COMBINE_MODE) {
				throw new Error("Incorrect button mode")
			}
			this.imgBackground = imgBackground
			this.imgUpground = imgUpground
			this.imgDisabled = imgDisabled
			this.imgNotPressed = imgNotPressed
			this.imgNotPressedHl = imgNotPressedHl
			this.imgPressed = imgPressed
			this.imgPressedHl = imgPressedHl
			this.mode = mode
			
			this.enabled = false
			this.pressed = false
			this.highlighted = false
			
			this.buttonMode = true
			this.cursorOnDisabled		= true
			this.cursorOnNotPressed		= true
			this.cursorOnNotPressedHl	= true
			this.cursorOnPressed		= true
			this.cursorOnPressedHl		= true
			
			if (this.imgBackground) {
				this.addChild(this.imgBackground)
			}
			if (this.imgUpground) {
				this.addChild(this.imgUpground)
			}
			
			this.refresh()
		}
		
		public function enable(on:Boolean):IButton {
			this.enabled = on
			this.refresh()
			return this
		}
		
		public function press(on:Boolean):IButton {
			this.pressed = on
			this.refresh()
			return this
		}
		
		public function highlight(on:Boolean):IButton {
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
		
		public final function isEnabled():Boolean {
			return this.enabled
		}
		
		public final function isPressed():Boolean {
			return this.pressed
		}
		
		public final function isHighlighted():Boolean {
			return this.highlighted
		}
		
		public final function getImgBackground():DisplayObject {
			return this.imgBackground
		}
		
		public final function getImgUpground():DisplayObject {
			return this.imgUpground
		}
		
		public final function getImgDisabled():DisplayObject {
			return this.imgDisabled
		}
		
		public final function getImgNotPressed():DisplayObject {
			return this.imgNotPressed
		}
		
		public final function getImgNotPressedHl():DisplayObject {
			return this.imgNotPressedHl
		}
		
		public final function getImgPressed():DisplayObject {
			return this.imgPressed
		}
		
		public final function getImgPressedHl():DisplayObject {
			return this.imgPressedHl
		}
		
		private final function refresh():void {
			var i:int = this.imgBackground ? 1 : 0
			if (this.enabled) {
				if (mode == XButton.REPLACE_MODE) {
					if (!this.pressed && !this.highlighted) {
						if (this.imgNotPressed) {
							if (this.contains(this.imgNotPressed)) {
								this.setChildIndex(this.imgNotPressed, i)
							} else {
								this.addChildAt(this.imgNotPressed, i)
							}
							i += 1
						}
					} else if (!this.pressed && this.highlighted) {
						if (this.imgNotPressedHl) {
							if (this.contains(this.imgNotPressedHl)) {
								this.setChildIndex(this.imgNotPressedHl, i)
							} else {
								this.addChildAt(this.imgNotPressedHl, i)
							}
							i += 1
						}
					} else if (this.pressed && !this.highlighted) {
						if (this.imgPressed) {
							if (this.contains(this.imgPressed)) {
								this.setChildIndex(this.imgPressed, i)
							} else {
								this.addChildAt(this.imgPressed, i)
							}
							i += 1
						}
					} else {
						if (this.imgPressedHl) {
							if (this.contains(this.imgPressedHl)) {
								this.setChildIndex(this.imgPressedHl, i)
							} else {
								this.addChildAt(this.imgPressedHl, i)
							}
							i += 1
						}
					}
				} else {
					if (!this.pressed) {
						if (this.imgNotPressed) {
							if (this.contains(this.imgNotPressed)) {
								this.setChildIndex(this.imgNotPressed, i)
							} else {
								this.addChildAt(this.imgNotPressed, i)
							}
							i += 1
						}
					} else {
						if (this.imgPressed) {
							if (this.contains(this.imgPressed)) {
								this.setChildIndex(this.imgPressed, i)
							} else {
								this.addChildAt(this.imgPressed, i)
							}
							i += 1
						}
					}
					if (this.highlighted) {
						if (!this.pressed) {
							if (this.imgNotPressedHl) {
								if (this.contains(this.imgNotPressedHl)) {
									this.setChildIndex(this.imgNotPressedHl, i)
								} else {
									this.addChildAt(this.imgNotPressedHl, i)
								}
								i += 1								
							}
						} else {
							if (this.imgPressedHl) {
								if (this.contains(this.imgPressedHl)) {
									this.setChildIndex(this.imgPressedHl, i)
								} else {
									this.addChildAt(this.imgPressedHl, i)
								}
								i += 1								
							}
						}
					}
				}
			} else {
				if (this.imgDisabled) {
					if (this.contains(this.imgDisabled)) {
						this.setChildIndex(this.imgDisabled, i)
					} else {
						this.addChildAt(this.imgDisabled, i)
					}
					i += 1
				}
			}
			var j:int = this.imgUpground ? this.numChildren - 1: this.numChildren
			while (i < j) {
				this.removeChildAt(i)
				j -= 1
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
		
	}

}