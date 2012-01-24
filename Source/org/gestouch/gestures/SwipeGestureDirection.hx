/**
 * @author Pavel fljot
 */
package org.gestouch.gestures;

class SwipeGestureDirection {

	static public var RIGHT : Int = 1 << 0;
	static public var LEFT : Int = 1 << 1;
	static public var UP : Int = 1 << 2;
	static public var DOWN : Int = 1 << 3;
	static public var NO_DIRECTION : Int = 0;
	static public var HORIZONTAL : Int = RIGHT | LEFT;
	static public var VERTICAL : Int = UP | DOWN;
	static public var ORTHOGONAL : Int = RIGHT | LEFT | UP | DOWN;
}

