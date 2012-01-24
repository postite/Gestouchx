/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;
import org.gestouch.events.TransformGestureEvent;

class PanGestureEvent extends TransformGestureEvent {

	static public var GESTURE_PAN : String = "gesturePan";



	// public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, scaleX : Float = 1, scaleY : Float = 1) {
	// 	super(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY);
	// }
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, phase : String = null, localX : Float = 0, localY : Float = 0, offsetX : Float = 0, offsetY : Float = 0) {
		trace("check offsetX"+offsetX);
		super(type, bubbles, cancelable, phase, localX, localY, 0,0,0,offsetX, offsetY);
	}

	override public function clone() : Event {
		return new PanGestureEvent(type, bubbles, cancelable, phase, localX, localY, offsetX, offsetY);
	}

	override public function toString() : String {
		//return super.toString().replace("TransformGestureEvent", "PanGestureEvent");
		return StringTools.replace(super.toString(),"TransformGestureEvent", "PanGestureEvent");
	}

}

