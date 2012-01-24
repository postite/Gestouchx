/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.TransformGestureEvent;

class SwipeGestureEvent extends TransformGestureEvent {

	static public var GESTURE_SWIPE : String = "gestureSwipe";
	public function new(type : String, bubbles : Bool = true, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, scaleX : Float = 1.0, scaleY : Float = 1.0, rotation : Float = 0, offsetX : Float = 0, offsetY : Float = 0, ctrlKey : Bool = false, altKey : Bool = false, shiftKey : Bool = false, commandKey : Bool = false, controlKey : Bool = false) {
		super(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY, rotation, offsetX, offsetY, ctrlKey, altKey, shiftKey);
	}

}

