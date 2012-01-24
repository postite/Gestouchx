package org.gestouch.gestures;

import org.gestouch.GestureUtils;
import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.RotateGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.geom.Point;

@:meta(Event(name="gestureRotate",type="org.gestouch.events.RotateGestureEvent"))
class RotateGesture extends Gesture {

	var _currVector : Point;
	var _lastVector : Point;
	public function new(target : InteractiveObject, settings : Dynamic = null) {
		_currVector = new Point();
		_lastVector = new Point();
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject = null, settings : Dynamic = null) : RotateGesture {
		return new RotateGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : RotateGesture {
		return try cast(GesturesManager.gestouch_internal::removeGestureByTarget(RotateGesture, target), RotateGesture) catch(e) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function onCancel() : Void {
		super.onCancel();
	}

	override public function reflect() : Class<Dynamic> {
		return RotateGesture;
	}

	override public function onTouchBegin(touchPoint : TouchPoint) : Void {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return;
		}
		_trackPoint(touchPoint);
		if(_trackingPointsCount == minTouchPointsCount)  {
			_lastVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
			_lastVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
			_updateCentralPoint();
			_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// do calculations only when we track enough points
		if(_trackingPointsCount < minTouchPointsCount)  {
			return;
		}
		_updateCentralPoint();
		_currVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
		_currVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
		var a1 : Float = Math.atan2(_lastVector.y, _lastVector.x);
		var a2 : Float = Math.atan2(_currVector.y, _currVector.x);
		var angle : Float = a2 - a1;
		angle *= GestureUtils.RADIANS_TO_DEGREES;
		_lastVector.x = _currVector.x;
		_lastVector.y = _currVector.y;
		_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, angle));
	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		var ending : Bool = (_trackingPointsCount == minTouchPointsCount);
		_forgetPoint(touchPoint);
		if(ending)  {
			_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}

	override function _preinit() : Void {
		super._preinit();
		minTouchPointsCount = 2;
	}

}

