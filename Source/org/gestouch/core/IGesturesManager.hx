/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import org.gestouch.gestures.Gesture;

interface IGesturesManager {

	function addGesture(gesture : Gesture) : Void;
	function removeGesture(gesture : Gesture) : Void;
	function scheduleGestureStateReset(gesture : Gesture) : Void;
	function onGestureRecognized(gesture : Gesture) : Void;
}

