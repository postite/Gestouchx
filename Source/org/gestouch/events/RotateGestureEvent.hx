/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;
import org.gestouch.events.TransformGestureEvent;

class RotateGestureEvent extends TransformGestureEvent {

	static public var GESTURE_ROTATE : String = "gestureRotate";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, rotation : Float = 0) {
		super(type, bubbles, cancelable, phase, localX, localY, 1, 1, rotation, localX, localY);
	}

	override public function clone() : Event {
		return new RotateGestureEvent(type, bubbles, cancelable, phase, localX, localY, rotation);
	}

	override public function toString() : String {
		
		return StringTools.replace(super.toString(),"TransformGestureEvent", "RotateGestureEvent");
	}

}

