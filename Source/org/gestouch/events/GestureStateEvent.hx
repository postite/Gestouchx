/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import nme.events.Event;

class GestureStateEvent extends Event {

	static public inline var STATE_CHANGE : String = "stateChange";
	public var newState : Int;
	public var oldState : Int;
	public function new(type : String, newState : Int, oldState : Int) {
		super(type, false, false);
		this.newState = newState;
		this.oldState = oldState;
	}

	override public function clone() : Event {
		return new GestureStateEvent(type, newState, oldState);
	}

	override public function toString() : String {

		//PORTODO
		//return formatToString("GestureStateEvent", newState, oldState);
		return "TODO";
	}

}

