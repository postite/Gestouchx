/**
 * @author Pavel fljot
 */
package org.gestouch.events;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;

class MouseTouchEvent extends TouchEvent {

	public function new(type : String, event : MouseEvent) {
		super(type, event.bubbles, event.cancelable, 0, true, event.localX, event.localY, null, null, null, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey);
		_target = event.target;
		_stageX = event.stageX;
		_stageY = event.stageY;
	}

	var _target : Dynamic;
	@:getter(target)
	 public function getTarget() : Dynamic {
		return _target;
	}

	var _stageX : Float;
	@:getter(stageX)
	 public function getStageX() : Float {
		return _stageX;
	}

	var _stageY : Float;
	@:getter(stageY)
	 public function getStageY() : Float {
		return _stageY;
	}

	override public function clone() : Event {
		return super.clone();
	}

	override public function toString() : String {
		return super.toString() + " *faked";
	}

}

