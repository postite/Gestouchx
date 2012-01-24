/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;

import org.gestouch.events.GestureEvent;

class LongPressGestureEvent extends GestureEvent {

	static public inline var GESTURE_LONG_PRESS : String = "gestureLongPress";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0) {
		super(type, bubbles, cancelable, phase, localX, localY);
	}

	override public function clone() : Event {
		return new LongPressGestureEvent(type, bubbles, cancelable, phase, localX, localY);
	}

	override public function toString() : String {
		//return super.toString().replace("GestureEvent", "LongPressGestureEvent");
		return StringTools.replace(super.toString(),"GestureEvent", "LongPressGestureEvent");
	}

}

