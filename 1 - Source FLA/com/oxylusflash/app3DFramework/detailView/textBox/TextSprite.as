package com.oxylusflash.app3DFramework.detailView.textBox 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.utils.StringUtil;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class TextSprite extends DestroyableSprite
	{
		public var textField:TextField;		
		private var _text:String;
		
		private var marginX:Number;
		private var marginY:Number;

		public function TextSprite() 
		{
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.condenseWhite = true;
			textField.mouseWheelEnabled = false;
			textField.selectable = false;
			
			marginX = textField.x = Math.round(textField.x);
			marginY = textField.y = Math.round(textField.y);	
			
			this.text = "";
		}
		
		/**
		 * Text
		 */
		public function get text():String { return _text; }
		public function set text(value:String):void
		{
			if (_text != value) 
			{
				_text = value;
				textField.htmlText = "<span class='leading2'>" + _text + "</span>";
			}
		}
		
		/**
		 * Area
		 */
		public function getAreaFor(widthValue:Number):Number 
		{ 
			this.width = widthValue;
			return this.width * this.height;
		}
		
		/**
		 * Overrides
		 */
		override public function get width():Number { return textField.width + 2 * marginX; }		
		override public function set width(value:Number):void 
		{
			var tfWidth:Number = value - 2 * marginX;
			if (textField.width != tfWidth) textField.width = tfWidth;
			
			// remove leading if only one line
			if (textField.numLines  <= 1) textField.htmlText = "<span class='leading0'>" + _text + "</span>";
			else textField.htmlText = "<span class='leading2'>" + _text + "</span>";
		}
		
		override public function get height():Number { return textField.height + 2 * marginY; }
		override public function set height(value:Number):void { }		
	}

}