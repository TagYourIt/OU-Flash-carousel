/**
 * @version 12/29/09
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	/**
	 * Class with static methods for Date/Time manipulation.
	 */
	public class DateUtil
	{
		
		/**
		 * Month names.
		 */
		public static var MONTH_NAMES:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		
		/**
		 * Day names.
		 */
		public static var DAY_NAMES:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		
		public function DateUtil()
		{
			throw new Error("DateUtil is a class with static methods, it doesn't need instantiation.");
		}
		
		/**
		 * Returns month short name.
		 * @param	monthIdx 	A number between 0(January) to 11(December)
		 * @param	len			Number o chars in month short name.
		 * @return				Month short name string.
		 */
		public static function shortMonthName(monthIdx:uint, len:uint = 3):String 
		{
			return MONTH_NAMES[monthIdx].substr(0, len);
		}
		
		/**
		 * Returns day short name.
		 * @param	dayIdx 		A number between 0(Sunday) to 6(Saturday)
		 * @param	len			Number o chars in day short name.
		 * @return				Day short name string.
		 */
		public static function shortDayName(dayIdx:uint, len:uint = 3):String
		{
			return DAY_NAMES[dayIdx].substr(0, len);
		}
		
		/**
		 * Get number of days in a month.
		 * @param	monthIdx	A number between 0(January) to 11(December)
		 * @param	isLeapYear	Specify if year is leap year or not.
		 * @return				The number of days.
		 */
		public static function monthNumDays(monthIdx:uint, isLeapYear:Boolean = false):uint
		{
			switch(monthIdx + 1) {
				case 1:	
				case 3: 
				case 5: 
				case 7: 
				case 8: 
				case 10: 
				case 12: return 31; break;
				
				case 4: 
				case 6: 
				case 9: 
				case 11: return 30; break;
				
				case 2:	return isLeapYear ? 29 : 28; break;
			}
			return 0;
		}
		
		/**
		 * Check if year is leap year.
		 * @param	year	Year.
		 * @return			True if year is leap year, false otherwise.
		 */
		public static function isLeapYear(year:uint):Boolean
		{
			return (year % 4 == 0 && year % 100 != 0) || year % 100 == 0;
		}
		
		/**
		 * Convert value to milliseconds.
		 * @param	value	A number.
		 * @param	from	Value kind: 0: seconds, 1: minutes, 2: hours, 3: days(default), 4: weeks, 5: months, 6: years.
		 * @return			The number of milliseconds.
		 */
		public static function convertToMs(value:Number, from:uint = 3):Number
		{		
			switch(from) {
				case 0: 	return value * 1000; 					break;
				case 1: 	return convertToMs(value, 0) * 60; 		break;
				case 2: 	return convertToMs(value, 1) * 60; 		break;
				case 3: 	return convertToMs(value, 2) * 24; 		break;
				case 4: 	return convertToMs(value, 3) * 7; 		break;
				case 5: 	return convertToMs(value, 4) * 4.35; 	break;
				case 6: 	return convertToMs(value, 5) * 12; 		break;
				default: 	return convertToMs(value, 3); 			break;
			}
		}
	}
}