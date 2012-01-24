/**
 * Set of constants.
 * 
 * @author Pavel fljot
 */
package org.gestouch;

import flash.system.Capabilities;

class GestureUtils {

	/**
	 * Precalculated coefficient used to convert 'inches per second' value to 'pixels per millisecond' value.
	 */
	static public var IPS_TO_PPMS : Float = Capabilities.screenDPI * 0.001;
	/**
	 * Precalculated coefficient used to convert radians to degress.
	 */
	static public var RADIANS_TO_DEGREES : Float = 180 / Math.PI;
	/**
	 * Precalculated coefficient used to convert degress to radians.
	 */
	static public var DEGREES_TO_RADIANS : Float = Math.PI / 180;
	/**
	 * Precalculated coefficient Math.PI * 2
	 */
	static public var PI_DOUBLE : Float = Math.PI * 2;
}

