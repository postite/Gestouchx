/**
 * Set of constants.
 * 
 * @author Pavel fljot
 */
package org.gestouch.utils;

import nme.system.Capabilities;

class GestureUtils {

	/**
	 * Precalculated coefficient used to convert 'inches per second' value to 'pixels per millisecond' value.
	 */
	 static public var IPS_TO_PPMS(getIPS,null): Float ;
	/**
	 * Precalculated coefficient used to convert radians to degress.
	 */
	static public inline var RADIANS_TO_DEGREES(getDegrees,null):Float ;
	/**
	 * Precalculated coefficient used to convert degress to radians.
	 */
	static public inline var DEGREES_TO_RADIANS(getRadians,null) : Float;
	/**
	 * Precalculated coefficient Math.PI * 2
	 */
	static public inline var PI_DOUBLE(getPi2,null) : Float;


	static inline function getIPS():Float 
	{
	return  Capabilities.screenDPI * 0.001;	
	}
	static inline function getDegrees():Float 
	{
		return  180 / Math.PI;
	}
	static inline function getRadians():Float 
	{
		return Math.PI / 180;
	}
	static inline function getPi2():Float
	{
		return Math.PI * 2;
	}
}

