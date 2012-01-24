/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.Event;

class GestureTrackingEvent extends Event {

	static public var GESTURE_TRACKING_BEGIN : String = "gestureTrackingBegin";
	static public var GESTURE_TRACKING_END : String = "gestureTrackingEnd";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false) {
		super(type, bubbles, cancelable);
	}

	override public function clone() : Event {
		return new GestureTrackingEvent(type, bubbles, cancelable);
	}

	override public function toString() : String {
		return formatToString("GestureTrackingEvent", "type", "bubbles", "cancelable", "eventPhase");
	}

}

