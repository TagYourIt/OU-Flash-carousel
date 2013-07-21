/**
 * @version 02/17/10
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	/**
	 * Class with static methods for XML manipulation.
	 */
	public class XMLUtil
	{
		
		public function XMLUtil()
		{
			throw new Error("XMLUtil is a class with static methods, it doesn't need instantiation.");
		}
		
		/**
		 * Get parameters object from a xml node.
		 * @param	xmlBlock 	The XML block to parse. 
		 * @param	asString	If true, the string won't be parsed to Number or Boolean
		 * @param	compactStr	Set it to true to make strings that can't be parsed, lowercase and with no extra white spaces
		 * @return				An object with the propeties coresponding to the xml nodes and attributes.
		 * @example	<settings>
		 * 				<param attrib1="string" attrib2="false"> 2 </param>
		 * 			</settings>
		 * 
		 * 			will parse to 
		 * 
		 * 			{ param: 2, param_attrib1: "string", param_attrib2: false }
		 */
		public static function getParams(xmlBlock:XML, asString:Boolean = false, compactStr:Boolean = false):Object 
		{
			var params:Object = { };
			
			var doc:XMLDocument = new XMLDocument();
			doc.ignoreWhite = true;
			doc.parseXML(xmlBlock.toString());
			
			var value:String;
			
			for (var p:XMLNode = doc.firstChild.firstChild; p != null; p = p.nextSibling)
			{
				var nodeName:String = p.nodeName;

				if (p.hasChildNodes())
				{
					value = p.firstChild.nodeValue;
					params[nodeName] = asString ? (compactStr ? StringUtil.squeeze(value) : value) : StringUtil.parse(value, compactStr);
				}				
				
				for (var attrName:String in p.attributes)
				{
					value = p.attributes[attrName];
					params[nodeName + "_" + attrName] = asString ? (compactStr ? StringUtil.squeeze(value) : value) : StringUtil.parse(value, compactStr);
				}
			}
			
			return params;
		}
	}
}