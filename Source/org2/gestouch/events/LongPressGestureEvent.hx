/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.GestureEvent;

class LongPressGestureEvent extends GestureEvent {

	static public var GESTURE_LONG_PRESS : String = "gestureLongPress";
	//TODO: default
	public function new(type : String, bubbles : Bool = true, cancelable : Bool = false, phase : String = "begin", localX : Float = 0, localY : Float = 0, ctrlKey : Bool = false, altKey : Bool = false, shiftKey : Bool = false) {
		super(type, bubbles, cancelable, phase, localX, localY, ctrlKey, altKey, shiftKey);
	}

}

