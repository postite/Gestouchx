//	[Event(name="gestureTrackingBegin", type="org.gestouch.events.GestureTrackingEvent")]
//	[Event(name="gestureTrackingEnd", type="org.gestouch.events.GestureTrackingEvent")]
package org.gestouch.gestures;

import org.gestouch.core.GestureState;
import org.gestouch.core.GesturesManager;
import org.gestouch.core.IGestureDelegate;
import org.gestouch.core.IGesturesManager;
import org.gestouch.core.ITouchesManager;
import org.gestouch.core.Touch;
import org.gestouch.core.TouchesManager;

import org.gestouch.events.GestureStateEvent;
import nme.display.InteractiveObject;
import nme.events.Event;
import nme.events.EventDispatcher;

import org.gestouch.events.GestureEvent;
import nme.events.TouchEvent;
import nme.geom.Point;
import nme.system.Capabilities;


class Gesture extends EventDispatcher {
	public var target(getTarget, setTarget) : InteractiveObject;
	public var enabled(getEnabled, setEnabled) : Bool;
	public var state(getState, never) : Int;
	public var touchesCount(getTouchesCount, never) : Int;
	public var location(getLocation, never) : Point;

	/**
	 * Threshold for screen distance they must move to count as valid input 
	 * (not an accidental offset on touch), 
	 * based on 20 pixels on a 252ppi device.
	 */
	 static public var DEFAULT_SLOP : Int = 0;
	 static public inline var TOUCH_EVENT_CAPTURE_PRIORITY : Int = 10;
	public var delegate : IGestureDelegate;
	var _touchesManager : ITouchesManager;
	var _gesturesManager : IGesturesManager;
	/**
	 * Map (generic object) of tracking touch points, where keys are touch points IDs.
	 */
	var _touchesMap : Dynamic;
	var _centralPoint : Point;
	var _localLocation : Point;
	public function new(target : InteractiveObject = null) {
		DEFAULT_SLOP=Math.round(20 / 252 * nme.system.Capabilities.screenDPI);

		trace("defaultSlop="+DEFAULT_SLOP);
		_touchesManager = TouchesManager.getInstance();
		_gesturesManager = GesturesManager.getInstance();
		_touchesMap = { };
		_centralPoint = new Point();
		_enabled = true;
		_state = GestureState.POSSIBLE;
		_touchesCount = 0;
		_location = new Point();
		 super();
		preinit();
		this.target = target;
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
		if(_target == value) return null;
		uninstallTarget(target);
		_target = value;
		installTarget(target);
		return value;
	}

	/** @private */
	var _enabled : Bool;
	/** 
	 * @default true
	 */
	public function getEnabled() : Bool {
		return _enabled;
	}

	public function setEnabled(value : Bool) : Bool {
		if(_enabled == value) return value;
		 _enabled = value;
		//TODO
		if(!_enabled && touchesCount > 0)  {
			setState(GestureState.CANCELLED);
			reset();
		}
		return value;
	}

	var _state : Int;
	public function getState() : Int {
		return _state;
	}

	var _touchesCount : Int;
	/**
	 * Amount of currently tracked touch points.
	 * 
	 * @see #_touches
	 */
	public function getTouchesCount() : Int {
		return _touchesCount;
	}

	var _location : Point;
	/**
	 * Virtual central touch point among all tracking touch points (geometrical center).
	 */
	public function getLocation() : Point {
		//TODO: to clone or not clone? performance & convention or ...
		return _location.clone();
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

	public function isTrackingTouch(touchID : Int) : Bool {
		return (Reflect.field(_touchesMap,Std.string(touchID))!=null);
		
}
	/**
	 * Cancels current tracking (interaction) cycle.
	 * 
	 * <p>Could be useful to "stop" gesture for the current interaction cycle.</p>
	 */
	public function reset() : Void {
		//TODO
		trace("reset");
		_location.x = 0;
		_location.y = 0;
		_touchesMap = { };
		_touchesCount = 0;
		setState(GestureState.POSSIBLE);
	}

	/**
	 * Remove gesture and prepare it for GC.
	 * 
	 * <p>The gesture is not able to use after calling this method.</p>
	 */
	public function dispose() : Void {
		//TODO
		reset();
		target = null;
	}

	public function canBePreventedByGesture(preventingGesture : Gesture) : Bool {
		return true;
	}

	public function canPreventGesture(preventedGesture : Gesture) : Bool {
		return true;
	}

	public function requireGestureToFail(gesture : Gesture) : Void {
		//TODO
	}

	// --------------------------------------------------------------------------
	//
	// Protected methods
	//
	// --------------------------------------------------------------------------
	/**
	 * First method, called in constructor.
	 */
	function preinit() : Void {
	}

	/**
	 * Called internally when changing the target.
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
	 */
	function installTarget(target : InteractiveObject) : Void {
		if(target!=null)  {
			_gesturesManager.addGesture(this);
		}
	}

	/**
	 * Called internally when changing the target.
	 * 
	 * <p>You should remove all listeners from target here.</p>
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
	 */
	function uninstallTarget(target : InteractiveObject) : Void {
		if(target!=null)  {
			_gesturesManager.removeGesture(this);
		}
	}

	/**
	 * TODO: clarify usage. For now it's supported to call this method in onTouchBegin with return.
	 */
	function ignoreTouch(touch : Touch, event : TouchEvent) : Void {
		trace("ignoretouch");
		if(_touchesMap.hasOwnProperty(touch.id))  {
			trace("beforeTouchCoount="+_touchesCount);
			Reflect.deleteField(_touchesMap,Std.string(touch.id));
			
			_touchesCount--;
			trace("afterTouchCoount="+_touchesCount);
		}
	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchBegin(touch : Touch, event : TouchEvent) : Void {
	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchMove(touch : Touch, event : TouchEvent) : Void {
	}

	/**
	 * Internal method, used by GesturesManager.
	 * 
	 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
	 */
	function onTouchEnd(touch : Touch, event : TouchEvent) : Void {
	}

	function setState(newState : Int) : Bool {
		trace("setState"+newState);
		if(_state == newState && _state == GestureState.CHANGED) {
			return true;
		}
		if(newState == GestureState.BEGAN || newState == GestureState.RECOGNIZED)  {
			if(delegate!=null && !delegate.gestureShouldBegin(this))  {
				setState(GestureState.FAILED);
				return false;
			}
		}
		var oldState : Int = _state;
		_state = newState;
		if(((GestureState.CANCELLED | GestureState.RECOGNIZED | GestureState.ENDED | GestureState.FAILED) & _state) > 0)  {
			_gesturesManager.scheduleGestureStateReset(this);
		}
		if(hasEventListener(GestureStateEvent.STATE_CHANGE))  {
			dispatchEvent(new GestureStateEvent(GestureStateEvent.STATE_CHANGE, _state, oldState));
		}
		if(_state == GestureState.BEGAN || _state == GestureState.RECOGNIZED)  {
			_gesturesManager.onGestureRecognized(this);
		}
		return true;
	}

	public function setState_internal(state : Int) : Void {
		setState(state);
	}

	function updateCentralPoint() : Void {
		trace("up");
		var touch : Touch=null;
		var x : Float = 0;
		var y : Float = 0;
		for(touchID  in Reflect.fields(_touchesMap)) {
			trace("tid="+touchID);
			touch = cast(Reflect.field(_touchesMap,Std.string(touchID) ), Touch) ;
			x += touch.x;
			y += touch.y;
		}

		_centralPoint.x = x / _touchesCount;
		_centralPoint.y = y / _touchesCount;
	}

	function updateLocation() : Void {
		trace("uploc");
		updateCentralPoint();
		_location.x = _centralPoint.x;
		_location.y = _centralPoint.y;
		_localLocation = target.globalToLocal(_location);
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	public function touchBeginHandler(touch : Touch, event : TouchEvent) : Void {
		
		Reflect.setField(_touchesMap,Std.string(touch.id),touch);
		_touchesCount++;
		onTouchBegin(touch, event);
	}

	public function touchMoveHandler(touch : Touch, event : TouchEvent) : Void {
		Reflect.setField(_touchesMap,Std.string(touch.id),touch );
		onTouchMove(touch, event);
	}

	public function touchEndHandler(touch : Touch, event : TouchEvent) : Void {
		trace("beforeTouchCoount="+_touchesCount);
		Reflect.deleteField(_touchesMap,Std.string(touch.id));

		_touchesCount--;
		trace("afterTouchCoount="+_touchesCount);
		onTouchEnd(touch, event);
	}

}

