/**
 * @version 12/29/09
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	/**
	 * Class with static methods for Number manipulation.
	 */
	public class NumberUtil
	{
		
		public function NumberUtil()
		{
			throw new Error("NumberUtil is a class with static methods, it doesn't need instantiation.");
		}
		
		/**
		 * Returns a pseudo random number between the two limits.
		 * @param	lowerLim 	Lower limit.
		 * @param	upperLim	Upper limit.
		 * @return				Random number.
		 */
		public static function random(lowerLim:Number, upperLim:Number):Number
		{
			lowerLim = Math.min(lowerLim, upperLim);
			upperLim = Math.max(lowerLim, upperLim);
			
			return lowerLim + Math.floor(Math.random() * (upperLim - lowerLim + 1));;
		}
		
		/**
		 * Get number sign.
		 * @param	num		Number to get sign from.
		 * @return			-1 (if num < 0), 0 (if num = 0) or 1 (if num > 0)
		 */
		public static function sign(num:Number):int
		{
			return num == 0 ? 0 : (num < 0 ? -1 : 1);
		}
		
		/**
		 * Limit number value.
		 * @param	num			Number to limit.
		 * @param	lowerLim	Upper limit.
		 * @param	upperLim	Lower limit.
		 * @return				New number.
		 */
		public static function limit(num:Number, lowerLim:Number, upperLim:Number):Number
		{
			lowerLim = Math.min(lowerLim, upperLim);
			upperLim = Math.max(lowerLim, upperLim);
			
			return num < lowerLim ? lowerLim : (num > upperLim ? upperLim : num);
		}
		
		/**
		 * Check if string is a number.
		 * @param	str	String to check.
		 * @return	True if string is a number, false otherwise.
		 */
		public static function isNumber(str:String):Boolean
		{
			return String(Number(str)) != "NaN";
		}
	}
}