package org.gestouch.gestures;

import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.LongPressGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.events.TimerEvent;
import flash.utils.Timer;

@:meta(Event(name="gestureLongPress",type="org.gestouch.events.LongPressGestureEvent"))
class LongPressGesture extends Gesture {

	/**
	 * Default value 1000ms
	 */
	public var timeThreshold : Int;
	/**
	 * Deafult value is Gesture.DEFAULT_SLOP
	 * @see org.gestouchers.core.Gesture#DEFAULT_SLOP
	 */
	public var slop : Float;
	var _thresholdTimer : Timer;
	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		timeThreshold = 500;
		slop = Gesture.DEFAULT_SLOP;
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject, settings : Dynamic = null) : LongPressGesture {
		return new LongPressGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : LongPressGesture {
		return try cast(GesturesManager.removeGestureByTarget(LongPressGesture, target), LongPressGesture) catch(e:String) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return LongPressGesture;
	}

	override public function onTouchBegin(touchPoint : TouchPoint) : Void {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return;
		}
		_trackPoint(touchPoint);
		if(_trackingPointsCount == minTouchPointsCount)  {
			_thresholdTimer.reset();
			_thresholdTimer.delay = timeThreshold;
			_thresholdTimer.start();
		}
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// faster isNaN
		if(_thresholdTimer.currentCount == 0 && slop == slop)  {
			if(touchPoint.moveOffset.length > slop)  {
				cancel();
			}
		}
	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		_forgetPoint(touchPoint);
		var held : Bool = (_thresholdTimer.currentCount > 0);
		_thresholdTimer.reset();
		if(held)  {
			_updateCentralPoint();
			_reset();
			_dispatch(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, true, false, cast GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Protected methods
	//
	//--------------------------------------------------------------------------
	override function _preinit() : Void {
		super._preinit();
		_thresholdTimer = new Timer(timeThreshold, 1);
		_thresholdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onThresholdTimerComplete);
		_propertyNames.push("timeThreshold");
		_propertyNames.push("slop");
	}

	override function _reset() : Void {
		super._reset();
		_thresholdTimer.reset();
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function _onThresholdTimerComplete(event : TimerEvent) : Void {
		_updateCentralPoint();
		_dispatch(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, true, false, cast GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
	}

}

