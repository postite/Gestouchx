/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;

import org.gestouch.events.TransformGestureEvent;

class ZoomGestureEvent extends TransformGestureEvent {

	static public var GESTURE_ZOOM : String = "gestureZoom";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, scaleX : Float = 1, scaleY : Float = 1) {
		super(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY);
	}

	override public function clone() : Event {
		return new ZoomGestureEvent(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY);
	}

	override public function toString() : String {
		//return super.toString().replace("TransformGestureEvent", "ZoomGestureEvent");
		return StringTools.replace(super.toString(),"TransformGestureEvent", "ZoomGestureEvent");
	}

}

