package org.gestouch.gestures;

import org.gestouch.core.GesturesManager;
import org.gestouch.core.IGesture;
import org.gestouch.core.TouchPoint;
import org.gestouch.core.Gestouch_internal;
import org.gestouch.events.GestureTrackingEvent;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;
import flash.events.GestureEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.system.Capabilities;

@:meta(Event(name="gestureTrackingBegin",type="org.gestouch.events.GestureTrackingEvent"))
@:meta(Event(name="gestureTrackingEnd",type="org.gestouch.events.GestureTrackingEvent"))
class Gesture extends EventDispatcher, implements IGesture {
	public var minTouchPointsCount(getMinTouchPointsCount, setMinTouchPointsCount) : Int;
	public var maxTouchPointsCount(getMaxTouchPointsCount, setMaxTouchPointsCount) : Int;
	public var target(getTarget, setTarget) : InteractiveObject;
	public var trackingPoints(getTrackingPoints, never) : Array<TouchPoint>;
	public var trackingPointsCount(getTrackingPointsCount, never) : Int;
	public var centralPoint(getCentralPoint, never) : TouchPoint;

	/**
	 * Threshold for screen distance they must move to count as valid input 
	 * (not an accidental offset on touch), 
	 * based on 20 pixels on a 252ppi device.
	 */
	static public var DEFAULT_SLOP : Int = Math.round(20 / 252 * flash.system.Capabilities.screenDPI);
	/**
	 * Array of configuration properties (Strings).
	 */
	var _propertyNames : Array<Dynamic>;
	/**
	 * Map (generic object) of tracking touch points, where keys are touch points IDs.
	 */
	var _trackingPointsMap : Dynamic;
	var _trackingPointsCount : Int;
	var _firstTouchPoint : TouchPoint;
	var _lastLocalCentralPoint : Point;
	public function new(target : InteractiveObject = null, settings : Dynamic = null) {
		super();
		_propertyNames = ["minTouchPointsCount", "maxTouchPointsCount"];
		_trackingPointsMap = { };
		_trackingPointsCount = 0;
		_minTouchPointsCount = 1;
		_maxTouchPointsCount = 1;
		_trackingPoints = new Array<TouchPoint>();
		// Check if gesture reflects it's class properly
		reflect();
		_preinit();
		GesturesManager.addGesture(this);
		this.target = target;
		if(settings != null)  {
			_parseSettings(settings);
		}
	}

	/** @private */
	var _minTouchPointsCount : Int;
	/**
	 * Minimum amount of touch points required for gesture.
	 * 
	 * @default 1
	 */
	public function getMinTouchPointsCount() : Int {
		return _minTouchPointsCount;
	}

	public function setMinTouchPointsCount(value : Int) : Int {
		if(_minTouchPointsCount == value) return null;
		_minTouchPointsCount = value;
		if(maxTouchPointsCount < minTouchPointsCount)  {
			maxTouchPointsCount = minTouchPointsCount;
		}
		return value;
	}

	/** @private */
	var _maxTouchPointsCount : Int;
	/**
	 * Maximum amount of touch points required for gesture.
	 * 
	 * @default 1
	 */
	public function getMaxTouchPointsCount() : Int {
		return _maxTouchPointsCount;
	}

	public function setMaxTouchPointsCount(value : Int) : Int {
		if(value < minTouchPointsCount)  {
			throw new IllegalOperationError("maxTouchPointsCount can not be less then minTouchPointsCount");
		}
		if(_maxTouchPointsCount == value) return null;
		_maxTouchPointsCount = value;
		return value;
	}

	/** @private */
	var _target : InteractiveObject;
	/**
	 * InteractiveObject (DisplayObject) which this gesture is tracking the actual gesture motion on.
	 * 
	 * <p>Could be some image, component (like map) or the larger view like Stage.</p>
	 * 
	 * <p>You can change the target in the runtime, e.g. you have a gallery
	 * where only one item is visible at the moment, so use one gesture instance
	 * and change the target to the currently visible item.</p>
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
	 */
	public function getTarget() : InteractiveObject {
		return _target;
	}

	public function setTarget(value : InteractiveObject) : InteractiveObject {
		if(target == value) return null;
		GesturesManager.updateGestureTarget(this, target, value);
		// if GesturesManager hasn't thrown any error we can safely continue
		_uninstallTarget(target);
		_target = value;
		_installTarget(target);
		return value;
	}

	/**
	 * Storage for the trackingPoints property.
	 */
	var _trackingPoints : Array<TouchPoint>;
	/**
	 * Vector of tracking touch points — touch points this gesture is interested in.
	 * 
	 * <p>For the most gestures these points are which on top of the target.</p>
	 * 
	 * @see #isTracking()
	 * @see #shouldTrackPoint()
	 */
	public function getTrackingPoints() : Array<TouchPoint> {
		return _trackingPoints.concat(null);
	}

	/**
	 * Amount of currently tracked touch points. Cached value of trackingPoints.length
	 * 
	 * @see #trackingPoints
	 */
	public function getTrackingPointsCount() : Int {
		return _trackingPointsCount;
	}

	/**
	 * Storage for centralPoint property.
	 */
	var _centralPoint : TouchPoint;
	/**
	 * Virtual central touch point among all tracking touch points (geometrical center).
	 * 
	 * <p>Designed for multitouch gestures, where center could be used for
	 * approximation or anchor. Use _adjustCentralPoint() method for updating centralPoint.</p>
	 * 
	 * @see #_adjustCentralPoint()
	 */
	public function getCentralPoint() : TouchPoint {
		return _centralPoint;
	}

	//--------------------------------------------------------------------------
	//
	//  Public methods
	//
	//--------------------------------------------------------------------------
	/**
	 * Reflects gesture class (for better perfomance).
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 * 
	 * @see performance optimization tips
	 */
	public function reflect() : Class<Dynamic> {
		throw cast(("reflect() is abstract method and must be overridden."));
		return null;
	}

	/**
	 * Used by GesturesManager to check wether this gesture is interested in
	 * tracking this touch point upon this event (of type TouchEvent.TOUCH_BEGIN).
	 * 
	 * <p>Most of the gestures check, if event.target is target or target contains event.target.</p>
	 * 
	 * <p>No need to use it directly.</p>
	 * 
	 * @see org.gestouch.core.GesturesManager
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/TouchEvent.html
	 */
	public function shouldTrackPoint(event : TouchEvent, tp : TouchPoint) : Bool {
		// No need to track more points than we need
		if(_trackingPointsCount == maxTouchPointsCount)  {
			return false;
		}
		var touchTarget : InteractiveObject = try cast(event.target, InteractiveObject) catch(e:String) null;


		if (touchTarget != target && !(Std.is(target, DisplayObjectContainer )&& cast (target,DisplayObjectContainer).contains(touchTarget)))
			{
				return false;
			}
		// if(touchTarget != target && !(Std.is(target, DisplayObjectContainer && (try cast(target, DisplayObjectContainer) catch(e:String) null).contains(touchTarget))))  {
		// 	return false;
		// }
		return true;
	}

	/**
	 * Used by GesturesManager to check wether this gesture is tracking this touch point.
	 * (Not to invoke onTouchBegin, onTouchMove and onTouchEnd methods with no need)
	 * 
	 * @see org.gestouch.core.GesturesManager
	 */
	public function isTracking(touchPointID : Int) : Bool {
		return (_trackingPointsMap[touchPointID] == true);
	}

	/**
	 * Cancels current tracking (interaction) cycle.
	 * 
	 * <p>Could be useful to "stop" gesture for the current interaction cycle.</p>
	 */
	public function cancel() : Void {
		GesturesManager.cancelGesture(this);
	}

	/**
	 * TODO: write description, decide wethere this API is good.
	 */
	public function pickAndContinue(gesture : IGesture) : Void {
		GesturesManager.addCurrentGesture(this);
		for( tp  in gesture.trackingPoints) {
			onTouchBegin(tp);
		}

	}

	/**
	 * Remove gesture and prepare it for GC.
	 * 
	 * <p>The gesture is not able to use after calling this method.</p>
	 */
	public function dispose() : Void {
		_reset();
		target = null;
		try {
			GesturesManager.removeGesture(this);
		}
		catch(err : String) {
			// do nothing
			// GesturesManager may throw Error if this gesture is already removed:
			// in case dispose() is called by GesturesManager upon GestureClass.remove(target)
			// this part smells a bit, eh?
		}

	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	public function onTouchBegin(touchPoint : TouchPoint) : Void {
	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	public function onTouchMove(touchPoint : TouchPoint) : Void {
	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	public function onTouchEnd(touchPoint : TouchPoint) : Void {
	}

	/**
	 * Internal method, used by GesturesManager. Called upon gesture is cancelled.
	 * 
	 * @see #cancel()
	 */
	public function onCancel() : Void {
		_reset();
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	/**
	 * First method, called in constructor.
	 * 
	 * <p>Good place to put gesture configuration related code. For example (abstract):</p>
	 * <listing version="3.0">
minTouchPointsCount = 2;
_propertyNames.push("timeThreshold", "moveThreshold");
	 * </listing>
	 */
	function _preinit() : Void {
	}

	/**
	 * Called internally when changing the target.
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
	 */
	function _installTarget(target : InteractiveObject) : Void {
	}

	/**
	 * Called internally when changing the target.
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
	 */
	function _uninstallTarget(target : InteractiveObject) : Void {
	}

	/**
	 * Dispatches gesture event on gesture and on target.
	 * 
	 * <p>Why dispatching event on gesture? Because it make sense to dispatch event from
	 * detector object (gesture) and we can add [Event] metatag for better autocompletion.</p>
	 * 
	 * <p>Why dispatching event on target? Becase it supposed to be like this in
	 * comparsion to native way, and it also make sense as similar to mouse and touch events.</p>
	 * 
	 * @param event GestureEvent to be dispatched
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/GestureEvent.html
	 */
	function _dispatch(event : GestureEvent) : Void {
		if(hasEventListener(event.type))  {
			dispatchEvent(event);
		}
		target.dispatchEvent(event);
	}

	/**
	 * Parses settings and configures the gesture.
	 * 
	 * @param settings Generic object with configuration properties
	 */
	function _parseSettings(settings : Dynamic) : Void {
		for(propertyName  in _propertyNames) {
			if (Reflect.hasField(settings,propertyName))
				{
					
					Reflect.setField(this,propertyName,Reflect.field(settings,propertyName));
				}
		}

	}

	/**
	 * Saves touchPoint for tracking for the current gesture cycle.
	 * 
	 * <p>If this is the first touch point, it updates _firstTouchPoint and _centralPoint.</p>
	 * 
	 * @see #_firstTouchPoint
	 * @see #centralPoint
	 * @see #trackingPointsCount
	 */
	function _trackPoint(touchPoint : TouchPoint) : Void {
		_trackingPointsMap[touchPoint.id] = true;
		var index : Int = _trackingPoints.push(touchPoint);
		_trackingPointsCount++;
		if(index == 1)  {
			_firstTouchPoint = touchPoint;
			_centralPoint = try cast(touchPoint.clone(), TouchPoint) catch(e:String) null;
		}

		else if(_trackingPointsCount == minTouchPointsCount)  {
			_updateCentralPoint();
			_centralPoint.touchBeginPos.x = _centralPoint.x;
			_centralPoint.touchBeginPos.y = _centralPoint.y;
			_centralPoint.moveOffset.x = 0;
			_centralPoint.moveOffset.y = 0;
			_centralPoint.lastMove.x = 0;
			_centralPoint.lastMove.y = 0;
		}

		else if(_trackingPointsCount > minTouchPointsCount)  {
			_adjustCentralPoint();
		}
		if(_trackingPointsCount == minTouchPointsCount)  {
			if(hasEventListener(GestureTrackingEvent.GESTURE_TRACKING_BEGIN))  {
				dispatchEvent(new GestureTrackingEvent(GestureTrackingEvent.GESTURE_TRACKING_BEGIN));
			}
		}
	}

	/**
	 * Removes touchPoint from the list of tracking points.
	 * 
	 * <p>If this is the first touch point, it updates _firstTouchPoint and _centralPoint.</p>
	 * 
	 * @see #trackingPoints
	 * @see #_trackingPointsMap
	 * @see #trackingPointsCount
	 */
	function _forgetPoint(touchPoint : TouchPoint) : Void {
		
		//delete _trackingPointsMap[touchPoint.id]; PORTODO

		_trackingPointsMap[touchPoint.id];
		_trackingPoints.splice(Lambda.indexOf(_trackingPoints,touchPoint), 1);
		_trackingPointsCount--;
		_adjustCentralPoint();
		if(_trackingPointsCount == minTouchPointsCount + 1)  {
			if(hasEventListener(GestureTrackingEvent.GESTURE_TRACKING_END))  {
				dispatchEvent(new GestureTrackingEvent(GestureTrackingEvent.GESTURE_TRACKING_END));
			}
		}
	}

	/**
	 * Updates _centralPoint and all it's properties
	 * (such as positions, offsets, velocity, etc...).
	 * Also updates _lastLocalCentralPoint (used for dispatching events).
	 * 
	 * @see #centralPoint
	 * @see #_lastLocalCentralPoint
	 * @see #trackingPoints
	 */
	function _updateCentralPoint() : Void {
		var x : Float = 0;
		var y : Float = 0;
		var velX : Float = 0;
		var velY : Float = 0;
		for( tp  in _trackingPoints) {
			x += tp.x;
			y += tp.y;
			velX += tp.velocity.x;
			velY += tp.velocity.y;
		}

		x /= _trackingPointsCount;
		y /= _trackingPointsCount;
		var lastMoveX : Float = x - _centralPoint.x;
		var lastMoveY : Float = y - _centralPoint.y;
		velX /= _trackingPointsCount;
		velY /= _trackingPointsCount;
		_centralPoint.x = x;
		_centralPoint.y = y;
		_centralPoint.lastMove.x = lastMoveX;
		_centralPoint.lastMove.y = lastMoveY;
		_centralPoint.velocity.x = velX;
		_centralPoint.velocity.y = velY;
		// tp.moveOffset = tp.subtract(tp.touchBeginPos);
		_centralPoint.moveOffset.x = x - _centralPoint.touchBeginPos.x;
		_centralPoint.moveOffset.y = y - _centralPoint.touchBeginPos.y;
		_lastLocalCentralPoint = target.globalToLocal(_centralPoint);
	}

	function _adjustCentralPoint() : Void {
		var oldCentralPoint : TouchPoint = try cast(_centralPoint.clone(), TouchPoint) catch(e:String) null;
		_updateCentralPoint();
		var centralPointChange : Point = _centralPoint.subtract(oldCentralPoint);
		_centralPoint.touchBeginPos = _centralPoint.touchBeginPos.add(centralPointChange);
		// fix moveOffset according to fixed touchBeginPos
		_centralPoint.moveOffset.x = _centralPoint.x - _centralPoint.touchBeginPos.x;
		_centralPoint.moveOffset.y = _centralPoint.y - _centralPoint.touchBeginPos.y;
		// restore original lastMove
		_centralPoint.lastMove.x = oldCentralPoint.lastMove.x;
		_centralPoint.lastMove.y = oldCentralPoint.lastMove.y;
	}

	/**
	 * Reset data for the current tracking (interaction) cycle.
	 * 
	 * <p>Clears up _trackingPointsMap, _trackingPoints, _trackingPointsCount
	 * and other custom gestures-specific things.</p>
	 * 
	 * <p>Generally invoked in onCancel method and when certain conditions of gesture
	 * have been failed and gesture doesn't need to continue processsing
	 * (e.g. timer has completed in DoubleTapGesture)</p>
	 * 
	 * @see #trackingPoints
	 * @see #trackingPointsCount
	 * @see #onCancel()
	 */
	function _reset() : Void {
		// forget all touch points
		

			_trackingPointsMap = {};
			_trackingPoints=[];
			_trackingPointsCount = 0;
	}

}

