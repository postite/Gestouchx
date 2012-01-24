/**
 * TODO: -location
 * - check on iOS (Obj-C) what happens when numTouchesRequired=2, two finger down, then quickly release one.
 * 
 * @author Pavel fljot
 */
package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.LongPressGestureEvent;
import nme.display.InteractiveObject;
// #if flash
// import flash.events.GesturePhase;
// #end
// #if (cpp || neko)
import org.gestouch.events.GesturePhase;
//#end
import nme.events.TimerEvent;
import nme.events.TouchEvent;
import nme.utils.Timer;

class LongPressGestureWithoutHash extends Gesture {

	public var numTouchesRequired : Int;
		/**
	 * The minimum time interval in millisecond fingers must press on the target for the gesture to be recognized.
	 * 
         * @default 500
         */

	public var minPressDuration : Int;
	public var slop : Float;
	var _timer : Timer;
	var _touchBeginX : Array<Dynamic>;
	var _touchBeginY : Array<Dynamic>;
	var _numTouchesRequiredReached : Bool;
	
	public function new(target : InteractiveObject = null) {
		trace("new longPressure");
		numTouchesRequired = 1;
		minPressDuration = 500;
		slop = Gesture.DEFAULT_SLOP;
		_touchBeginX = [];
		_touchBeginY = [];
		super(target);
	}

	// --------------------------------------------------------------------------
	//
	// Public methods
	//
	// --------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return TapGesture;
	}

	override public function reset() : Void {
		super.reset();
		_touchBeginX = [];
		_touchBeginY = [];
		_numTouchesRequiredReached = false;
		_timer.reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function preinit() : Void {
		super.preinit();
		_timer = new Timer(minPressDuration, 1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
	}

	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		trace("touchbegin");
		if(touchesCount > numTouchesRequired)  {
			if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
				ignoreTouch(touch, event);
			}

			else {
				setState(GestureState.FAILED);
			}

			return;
		}
		_touchBeginX[touch.id] = touch.x;
		_touchBeginY[touch.id] = touch.y;
		if(touchesCount == numTouchesRequired)  {
			_numTouchesRequiredReached = true;
			_timer.reset();
			_timer.delay = minPressDuration;
			if(minPressDuration > 0)  {
				_timer.start();
			}

			else  {

				timer_timerCompleteHandler();
			}

		}
	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		if(state == GestureState.POSSIBLE && slop > 0)  {
			// Fail if touch overcome slop distance
			var dx : Float = Std.parseFloat(_touchBeginX[touch.id]) /* WARNING check type */ - touch.x;
			var dy : Float = Std.parseFloat(_touchBeginY[touch.id]) /* WARNING check type */ - touch.y;
			if(Math.sqrt(dx * dx + dy * dy) > slop)  {
				setState(GestureState.FAILED);
				return;
			}
		}

		else if(state == GestureState.BEGAN || state == GestureState.CHANGED)  {
			updateLocation();
			if(setState(GestureState.CHANGED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))  {
				dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, cast GesturePhase.UPDATE, _localLocation.x, _localLocation.y));
			}
		}
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		//TODO: check proper condition (behavior) on iOS native
		if(_numTouchesRequiredReached)  {
			if(((GestureState.BEGAN | GestureState.CHANGED) & state) > 0)  {
				updateLocation();
				if(setState(GestureState.ENDED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))  {
					dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, cast GesturePhase.END, _localLocation.x, _localLocation.y));
				}
			}

			else  {
				setState(GestureState.FAILED);
			}

		}

		else  {
			setState(GestureState.FAILED);
		}

	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function timer_timerCompleteHandler(event : TimerEvent = null) : Void {
		trace(this+"timerComplete"+state);
		if(state == GestureState.POSSIBLE)  {
			trace("possible");
			updateLocation();
			trace(hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS));
			if(setState(GestureState.BEGAN) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))  {
				trace("dispatch");

				dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, cast GesturePhase.BEGIN, _localLocation.x, _localLocation.y));
			}
		}
	}

}

