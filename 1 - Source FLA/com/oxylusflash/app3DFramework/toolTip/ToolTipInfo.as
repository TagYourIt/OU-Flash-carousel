package com.oxylusflash.app3DFramework.toolTip 
{
	import flash.display.Sprite;
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ToolTipInfo
	{
		public static const ABOVE:int = 1;
		public static const BELLOW:int = 0;
		
		public var mouseFollow:Boolean = true;
		public var offsetX:Number = 0;
		public var offsetY:Number = 10;
		public var position:int = ABOVE;
		public var showDelay:Number = 0.4;
		public var stayFor:Number = 5;
		public var tipString:String = "";
		public var item:Sprite;
		
		/**
		 * Tooltip info object.
		 * @param	xmlData		XML data to be parsed.
		 */
		public function ToolTipInfo(xmlData:XML) 
		{
			mouseFollow = String(xmlData.@mouseFollow).toLowerCase() == "true";
			offsetX = Number(xmlData.@offsetX);
			offsetY = Number(xmlData.@offsetY);
			position = String(xmlData.@position).toLowerCase() == "above" ? ABOVE : BELLOW;
			showDelay = Number(xmlData.@showDelay);
			stayFor = Number(xmlData.@stayFor);
			tipString = String(xmlData.text());
		}
		
		/**
		 * Destroy object
		 */
		public function destroy():void
		{
			tipString = null;
			item = null;
		}
		
	}

}