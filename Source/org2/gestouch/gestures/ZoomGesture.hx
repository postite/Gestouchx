package org.gestouch.gestures;

import org.gestouch.core.GesturesManager;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.ZoomGestureEvent;
import flash.display.InteractiveObject;
import flash.events.GesturePhase;
import flash.geom.Point;

@:meta(Event(name="gestureZoom",type="org.gestouch.events.ZoomGestureEvent"))
class ZoomGesture extends Gesture {

	public var lockAspectRatio : Bool;
	var _currVector : Point;
	var _lastVector : Point;
	public function new(target : InteractiveObject, settings : Dynamic = null) {
		lockAspectRatio = true;
		_currVector = new Point();
		_lastVector = new Point();
		super(target, settings);
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	static public function add(target : InteractiveObject = null, settings : Dynamic = null) : ZoomGesture {
		return new ZoomGesture(target, settings);
	}

	static public function remove(target : InteractiveObject) : ZoomGesture {
		return try cast(GesturesManager.gestouch_internal::removeGestureByTarget(ZoomGesture, target), ZoomGesture) catch(e) null;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	override public function reflect() : Class<Dynamic> {
		return ZoomGesture;
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
			_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}

	override public function onTouchMove(touchPoint : TouchPoint) : Void {
		// do calculations only when we track enought points
		if(_trackingPointsCount < minTouchPointsCount)  {
			return;
		}
		_updateCentralPoint();
		_currVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
		_currVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
		var scaleX : Float = _currVector.x / _lastVector.x;
		var scaleY : Float = _currVector.y / _lastVector.y;
		if(lockAspectRatio)  {
			scaleX = scaleY = _currVector.length / _lastVector.length;
		}

		else  {
			scaleX = _currVector.x / _lastVector.x;
			scaleY = _currVector.y / _lastVector.y;
		}

		_lastVector.x = _currVector.x;
		_lastVector.y = _currVector.y;
		_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, scaleX, scaleY));
	}

	override public function onTouchEnd(touchPoint : TouchPoint) : Void {
		var ending : Bool = (_trackingPointsCount == minTouchPointsCount);
		_forgetPoint(touchPoint);
		if(ending)  {
			_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}

	override function _preinit() : Void {
		super._preinit();
		minTouchPointsCount = 2;
		_propertyNames.push("lockAspectRatio");
	}

}

