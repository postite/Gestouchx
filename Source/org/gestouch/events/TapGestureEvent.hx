/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.Event;
#if flash
import flash.events.GestureEvent;

#end
#if (cpp || neko)
import org.gestouch.events.GestureEvent;
#end

class TapGestureEvent extends GestureEvent {

	static public var GESTURE_TAP : String = "gestureTap";
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0) {
		super(type, bubbles, cancelable, phase, localX, localY);
	}

	override public function clone() : Event {
		return new TapGestureEvent(type, bubbles, cancelable, phase, localX, localY);
	}

	override public function toString() : String {
		//return super.toString().replace("GestureEvent", "TapGestureEvent");
		return StringTools.replace(super.toString(),"GestureEvent", "TapGestureEvent");
	}

}

