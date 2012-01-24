/**
 * TODO: check failing conditions (iDevice)
 * 
 * @author Pavel fljot
 */
package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.Touch;
import org.gestouch.events.TapGestureEvent;
import flash.display.InteractiveObject;


#if flash
import flash.events.GesturePhase;

#end
#if (cpp || neko)
import org.gestouch.events.GesturePhase;
#end

import flash.events.TimerEvent;
import flash.events.TouchEvent;
import flash.utils.Timer;

class TapGesture extends Gesture {

	public var numTouchesRequired : Int;
	public var numTapsRequired : Int;
	public var slop : Float;
	public var maxTapDelay : Int;
	public var maxTapDuration : Int;
	var _timer : Timer;
	var _touchBeginX : Array<Dynamic>;
	var _touchBeginY : Array<Dynamic>;
	var _numTouchesRequiredReached : Bool;
	var _tapCounter : Int;
	public function new(target : InteractiveObject = null) {
		numTouchesRequired = 1;
		numTapsRequired = 1;
		slop = Gesture.DEFAULT_SLOP;
		maxTapDelay = 400;
		maxTapDuration = 1500;
		_touchBeginX = [];
		_touchBeginY = [];
		_tapCounter = 0;
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
		_touchBeginX=[];
		_touchBeginY=[];
		_numTouchesRequiredReached = false;
		_tapCounter = 0;
		_timer.reset();
		super.reset();
	}

	override public function canPreventGesture(preventedGesture : Gesture) : Bool {
		if(Std.is(preventedGesture, TapGesture) && (cast(preventedGesture, TapGesture).numTapsRequired > this.numTapsRequired))  {
			return false;
		}
		return true;
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	override function preinit() : Void {
		super.preinit();
		_timer = new Timer(maxTapDelay, 1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
	}

	override function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
		if(touchesCount > numTouchesRequired)  {
			// We put more fingers then required at the same time,
			// so treat that as failed
			setState(GestureState.FAILED);
			return;
		}
		_touchBeginX[touch.id] = touch.x;
		_touchBeginY[touch.id] = touch.y;
		if(touchesCount == 1)  {
			_timer.reset();
			_timer.delay = maxTapDuration;
			_timer.start();
		}
		if(touchesCount == numTouchesRequired)  {
			_numTouchesRequiredReached = true;
		}
	}

	override function onTouchMove(touch : Touch, event : TouchEvent) : Void {
		if(slop >= 0)  {
			// Fail if touch overcome slop distance
			var dx : Float = Std.parseFloat(_touchBeginX[touch.id]) /* WARNING check type */ - touch.x;
			var dy : Float = Std.parseFloat(_touchBeginY[touch.id]) /* WARNING check type */ - touch.y;
			if(Math.sqrt(dx * dx + dy * dy) > slop)  {
				setState(GestureState.FAILED);
			}
		}
	}

	override function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
		if(!_numTouchesRequiredReached)  {
			//TODO: check this condition on iDevice
			setState(GestureState.FAILED);
		}

		else if(touchesCount == 0)  {
			// reset flag for the next "full press" cycle
			_numTouchesRequiredReached = false;
			_tapCounter++;
			_timer.reset();
			if(_tapCounter == numTapsRequired)  {
				updateLocation();
				if(setState(GestureState.RECOGNIZED) && hasEventListener(TapGestureEvent.GESTURE_TAP))  {
					dispatchEvent(new TapGestureEvent( TapGestureEvent.GESTURE_TAP, false, false, cast GesturePhase.ALL, _localLocation.x, _localLocation.y));
				}
			}

			else  {
				_timer.delay = maxTapDelay;
				_timer.start();
			}

		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function timer_timerCompleteHandler(event : TimerEvent) : Void {
		if(state == GestureState.POSSIBLE)  {
			setState(GestureState.FAILED);
		}
	}

}

