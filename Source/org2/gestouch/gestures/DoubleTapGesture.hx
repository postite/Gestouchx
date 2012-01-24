package org.gestouch.gestures;

import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.DoubleTapGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

@:meta(Event(name="gestureDoubleTap",type="org.gestouch.events.DoubleTapGestureEvent"))
class DoubleTapGesture extends Gesture {

	/**
	 * Time in milliseconds between touchBegin and touchEnd events for gesture to be detected.
	 * 
	 * <p>For multitouch usage this is a bit more complex then "first touchBeing and second touchEnd":
	 * Taps are counted once <code>minTouchPointsCount</code> of touch points are down and then fully released.
	 * So it's time in milliseconds between full press and full release events for gesture to be detected.</p>
	 * 
	 * @default 400
	 */
	public var timeThreshold : Int;
	/**
	 * Maximum allowed distance between two taps for gesture to be detected.
	 * 
	 * @default Gesture.DEFAULT_SLOP &#42; 3
	 * 
	 * @see org.gestouch.gestures.Gesture#DEFAULT_SLOP
	 */
	public var moveThreshold : Float;
	/**
	 * Timer used to track time between taps.
	 */
	var _thresholdTimer : Timer;
	/**
	 * Count taps (where tap is an action of changing _touchPointsCount from 0 to minTouchPointsCount
	 * and back to 0. For single touch gesture it would be common tap, for 2-touch gesture it would be
	 * both fingers down, then both fingers up, etc...)
	 */
	var _tapCounter : Int;
	/**
	 * Flag to detect "complex tap".
	 */
	var _minTouchPointsCountReached : Bool;
	/**
	 * Used to check moveThreshold.
	 */
	var _prevCentralPoint : Point;
	/**
	 * Used to check moveThreshold.
	 */
	var _lastCentralPoint : Point;
	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		timeThreshold = 400;
		moveThreshold = Gesture.DEFAULT_SLOP * 3;
		_tapCounter = 0;
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject, settings : Dynamic = null) : DoubleTapGesture {
		return new DoubleTapGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : DoubleTapGesture {
		return try cast(GesturesManager.gestouch_internal::removeGestureByTarget(DoubleTapGesture, target), DoubleTapGesture) catch(e) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return DoubleTapGesture;
	}

	override public function onTouchBegin(touchPoint : TouchPoint) : Void {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return;
		}
		_trackPoint(touchPoint);
		if(_trackingPointsCount == minTouchPointsCount)  {
			if(!_thresholdTimer.running)  {
				// first touchBegin combo (all the required fingers are on the screen)
				_tapCounter = 0;
				_thresholdTimer.reset();
				_thresholdTimer.delay = timeThreshold;
				_thresholdTimer.start();
				_updateCentralPoint();
			}
			_minTouchPointsCountReached = true;
			if(moveThreshold > 0)  {
				// calculate central point for future moveThreshold comparsion
				_updateCentralPoint();
				// save points for later comparsion with moveThreshold
				_prevCentralPoint = _lastCentralPoint;
				_lastCentralPoint = _centralPoint.clone();
			}
		}
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// nothing to do here
	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		// As we a here, this means timer hasn't fired yet (and therefore hasn't cancelled this gesture)
		_forgetPoint(touchPoint);
		// if last finger released
		if(_trackingPointsCount == 0)  {
			if(_minTouchPointsCountReached)  {
				_tapCounter++;
				// reset for next "all fingers down"
				_minTouchPointsCountReached = false;
			}
			if(_tapCounter >= 2)  {
				// double tap combo recognized
				if((moveThreshold > 0 && _lastCentralPoint.subtract(_prevCentralPoint).length < moveThreshold) || Math.isNaN(moveThreshold) || moveThreshold <= 0)  {
					_reset();
					_dispatch(new DoubleTapGestureEvent(DoubleTapGestureEvent.GESTURE_DOUBLE_TAP, true, false, GesturePhase.ALL, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
				}
			}
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
		_thresholdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _thresholdTimer_timerCompleteHandler);
		_propertyNames.push("timeThreshold", "moveThreshold");
	}

	override function _reset() : Void {
		super._reset();
		_tapCounter = 0;
		_minTouchPointsCountReached = false;
		_thresholdTimer.reset();
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	function _thresholdTimer_timerCompleteHandler(event : TimerEvent) : Void {
		cancel();
	}

}

