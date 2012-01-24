/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import flash.display.InteractiveObject;
import flash.display.Stage;

interface IGesturesManager {

	function init(stage : Stage) : Void;
	function _addGesture(gesture : IGesture) : IGesture;
	function _removeGesture(gesture : IGesture) : IGesture;
	function _removeGestureByTarget(gestureType : Class<Dynamic>, target : InteractiveObject) : IGesture;
	function _getGestureByTarget(gestureType : Class<Dynamic>, target : InteractiveObject) : IGesture;
	function _cancelGesture(gesture : IGesture) : Void;
	function _addCurrentGesture(gesture : IGesture) : Void;
	function _updateGestureTarget(gesture : IGesture, oldTarget : InteractiveObject, newTarget : InteractiveObject) : Void;
	function _getTouchPoint(touchPointID : Int) : TouchPoint;
}

