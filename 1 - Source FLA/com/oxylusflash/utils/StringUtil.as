/**
 * @version 12/28/09
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	/**
	 * Class with static methods for String manipulation.
	 */
	public class StringUtil
	{
		
		public static const TAB:String = String.fromCharCode(9);
		public static const LF:String = String.fromCharCode(10);
		public static const CR:String = String.fromCharCode(11);
		public static const SPACE:String = String.fromCharCode(32);
		
		public function StringUtil()
		{
			throw new Error("StringUtil is a class with static methods, it doesn't need instantiation.");
		}
		
		/**
		 * Remove extra white spaces from a string. 
		 * @param	str 	The string to be squeezed.
		 * @return			String with no extra white spaces.
		 */
		public static function squeeze(str:String):String 
		{
			var temp:String = "";			
			var flag:Boolean = false;
			var n:uint = str.length;
			
			for (var i:uint = 0; i < n; i++)
			{
				var c:String = str.charAt(i);
				if (c == SPACE || c == TAB || c == LF || c == CR)
				{
					if (!flag) flag = true;
				}
				else
				{
					if (flag)
					{
						flag = false;
						if (temp != "") temp += " ";
					}
					
					temp += c;
				}
			}
			
			return temp;
		}
		
		/**
		 * Parse reserved HTML entities. 
		 * @param	str 	HTML string.
		 * @return			String with the parsed entities.
		 */
		public static function parseEntities(str:String):String 
		{
			str = str.replace(/(&#60;|&lt;)/gi, "<");
			str = str.replace(/(&#62;|&gt;)/gi, ">");
			str = str.replace(/(&#62;|&gt;)/gi, ">");
			str = str.replace(/(&#38;|&amp;)/gi, "&");
			str = str.replace(/(&#34;|&quot;)/gi, "\"");
			str = str.replace(/(&#39;|&apos;)/gi, "'");
			
			return str;
		}
		
		/**
		 * Removes HTML tags from a string.
		 * @param	str 	HTML string.
		 * @return			String with no HTML tags.
		 */
		public static function stripHTML(str:String):String 
		{
			return parseEntities(str).replace(/<.*?>/gi, "");
		}
		
		/**
		 * Gets all image paths from a HTML string (works for jpeg, jpg, gif and png).
		 * @param	str 	HTML string containing img tags.
		 * @return			Array with all the image paths.
		 */
		public static function getHTMLImages(str:String):Array
		{
			return parseEntities(str).match(/https?:\/\/(?:[a-z\-]+\.)+[a-z]{2,6}(?:\/[^\/#?]+)+\.(?:jpe?g|gif|png)/gi);
		}
		
		/**
		 * Check if a string is blank.
		 * @param	str 	String to check;
		 * @return			true if the string is blank, false otherwise.
		 */
		public static function isBlank(str:String):Boolean
		{
			var n:uint = str.length;
			for (var i:uint = 0; i < n; i++)
			{
				var c:String = str.charAt(i);
				if (c != SPACE && c != TAB && c != LF && c != CR)
				{
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * Check if string is email address.
		 * @param	str 	Email string to check.
		 * @return			true if the string is a valid email address, false otherwise.
		 */
		public static function isEmail(str:String):Boolean
		{
			var pattern:RegExp = /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/;
			return pattern.test(str);
		}
		
		/**
		 * Get string extension (the substring after the last point)
		 * @param	str 			String from which to extract the extension
		 * @param	preserveCase 	If true it will preserve the extension case, otherwise it will be transformed to lowercase
		 * @return					Extension string or blank if no extension was found.
		 */
		public static function getExtension(str:String, preserveCase:Boolean = false):String 
		{
			var n:uint = str.length;
			var ext:String = "";
			for (var i:uint = n; i > 0; i--)
			{
				var c:String = str.charAt(i - 1);
				if (c == ".")
				{
					return preserveCase ? ext : ext.toLowerCase();
				}
				else
				{
					ext = c + ext;
				}
			}
			return "";
		}
		
		/**
		 * Get unique string.
		 * @return Unique string.
		 */
		public static function uniqueStr():String 
		{
			return String((new Date()).getTime());
		}
		
		/**
		 * Parse string to Number or Bolean if possible.
		 * @param	str			String to parse.
		 * @param	compactStr	If string can't be parsed, return compact form(squeezed and lowercase) if true, or the original string if false. 
		 * @return				Number, Boolean or String value.
		 */
		public static function parse(str:String, compactStr:Boolean = false):* 
		{
			if (isBlank(str)) return "";
			
			var temp:String = squeeze(str).toLowerCase();
			var num:Number = Number(temp);
			
			if (String(num) != "NaN") 
			{
				return num;
			}
			else if(temp == "true")
			{
				return true;
			}
			else if(temp == "false")
			{
				return false;
			}
			else
			{
				return compactStr ? temp : str;
			}
		}
	}
}