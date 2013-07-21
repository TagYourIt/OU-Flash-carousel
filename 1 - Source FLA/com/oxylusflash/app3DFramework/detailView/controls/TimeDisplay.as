package com.oxylusflash.app3DFramework.detailView.controls 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.framework.util.StringUtil;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class TimeDisplay extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var currentTxt:TextField;
		public var totalTxt:TextField;
		
		private var _currentTime:Number;
		private var _totalTime:Number;
		
		/* Time display */
		public function TimeDisplay() 
		{
			currentTxt.multiline = false;
			currentTxt.wordWrap = false;
			currentTxt.autoSize = TextFieldAutoSize.LEFT;
			
			totalTxt.multiline = false;
			totalTxt.wordWrap = false;
			totalTxt.autoSize = TextFieldAutoSize.LEFT;
			
			this.currentTime = 0;
			this.totalTime = 0;
		}
		
		/* Current time */
		public function get currentTime():Number { return _currentTime; }		
		public function set currentTime(value:Number):void 
		{
			value = Math.round(value);
			if (_currentTime != value)
			{
				_currentTime = value;
				currentTxt.text = StringUtil.toTimeString(_currentTime);
			}
		}
		
		/* Total time */
		public function get totalTime():Number { return _totalTime; }		
		public function set totalTime(value:Number):void 
		{
			value = Math.round(value);
			if (_totalTime != value)
			{
				_totalTime = value;
				totalTxt.text = StringUtil.toTimeString(_totalTime);
			}
		}
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }		
		override public function set height(value:Number):void { }
		
	}

}