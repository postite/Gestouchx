/**
 * @author Pavel fljot
 */
package org.gestouch.core;

import flash.display.Stage;

interface ITouchesManager {
	var activeTouchesCount(getActiveTouchesCount, never) : Int;

	function getActiveTouchesCount() : Int;
	function init(stage : Stage) : Void;
	function getTouch(touchPointID : Int) : Touch;
}

