/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import flash.events.IEventDispatcher;
import flash.display.InteractiveObject;
import flash.events.TouchEvent;

interface IGesture implements IEventDispatcher {
	var target(getTarget, never) : InteractiveObject;
	var trackingPoints(getTrackingPoints, never) : Array<TouchPoint>;
	var trackingPointsCount(getTrackingPointsCount, never) : Int;

	function getTarget() : InteractiveObject;
	function getTrackingPoints() : Array<TouchPoint>;
	function getTrackingPointsCount() : Int;
	function shouldTrackPoint(event : TouchEvent, tp : TouchPoint) : Bool;
	function isTracking(touchPointID : Int) : Bool;
	function cancel() : Void;
	function pickAndContinue(gesture : IGesture) : Void;
	function reflect() : Class<Dynamic>;
	function dispose() : Void;
	function onTouchBegin(touchPoint : TouchPoint) : Void;
	function onTouchMove(touchPoint : TouchPoint) : Void;
	function onTouchEnd(touchPoint : TouchPoint) : Void;
	function onCancel() : Void;
}

