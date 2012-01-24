/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import org.gestouch.gestures.Gesture;

interface IGestureDelegate {

	function gestureShouldReceiveTouch(gesture : Gesture, touch : Touch) : Bool;
	function gestureShouldBegin(gesture : Gesture) : Bool;
	function gesturesShouldRecognizeSimultaneously(gesture : Gesture, otherGesture : Gesture) : Bool;
}

