/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.Event;

import org.gestouch.events.TransformGestureEvent;

class SwipeGestureEvent extends TransformGestureEvent {

	static public var GESTURE_SWIPE : String = "gestureSwipe";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, offsetX : Float = 0, offsetY : Float = 0) {
		super(type, bubbles, cancelable, phase, localX, localY, 1, 1, 0, offsetX, offsetY);
	}

	override public function clone() : Event {
		return new SwipeGestureEvent(type, bubbles, cancelable, phase, localX, localY, offsetX, offsetY);
	}

	override public function toString() : String {
		
		return StringTools.replace(super.toString(),"TransformGestureEvent", "SwipeGestureEvent");
	}

}

