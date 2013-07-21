package com.oxylusflash.app3DFramework
{
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.TextShortcuts;
	import com.oxylusflash.events.ParamEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class LabelButton extends SimpleButton
	{
		// Label colors
		private var nColor:uint;
		private var oColor:uint;
		private var sColor:uint;
		
		// Label states
		public var normalLbl:TextField;
		public var overLbl:TextField;
		public var selectedLbl:TextField;
		
		// XML data
		private var _data:XML;
		
		// Constructor
		public function LabelButton()
		{
			TextShortcuts.init();
			
			// Setup labels
			nColor = normalLbl.textColor;
			oColor = overLbl.textColor;
			sColor = selectedLbl ? selectedLbl.textColor : oColor;
			
			this.removeChild(overLbl); overLbl = null;
			if (selectedLbl) { this.removeChild(selectedLbl); selectedLbl = null; }
			
			normalLbl.autoSize = TextFieldAutoSize.LEFT;
			normalLbl.multiline = false;
			normalLbl.wordWrap = false;
			normalLbl.condenseWhite = true;
			
			// Init label
			this.label = "Label not set";
		}
		
		/**
		 * Fire press event.
		 */
		override protected function firePressEvent():void
		{
			if (_data) this.dispatchEvent(new ParamEvent(PRESS, { data: _data.content[0] } ));
			else super.firePressEvent();
		}
		
		/**
		 * Tab state
		 */
		override protected function extraTweens():void
		{
			var normalLblColor:uint = _state == NORMAL_STATE ? nColor : (_state == OVER_STATE ? oColor : sColor);
			Tweener.addTween(normalLbl, { _text_color: normalLblColor, time: .3, transition: "easeOutQuad" } );
		}
		
		/**
		 * Tab label as html text
		 */
		public function get label():String { return normalLbl.text; }
		public function set label(value:String):void
		{
			normalLbl.htmlText = value;
			normalBg.width = overBg.width = Math.round(normalLbl.width);
			if (selectedBg) selectedBg.width = normalBg.width;
			redrawMask();
		}
		
		/**
		 * XML data
		 */
		public function get data():XML { return _data; }
		public function set data(value:XML):void
		{
			_data = value;
			this.label = _data.title[0].text();
		}
		
		/**
		 * Destroy.
		 */
		override public function destroy():void
		{
			Tweener.removeTweens(normalLbl);
			_data = null;
			super.destroy();
		}
		
		/**
		 * Overrides
		 */
		override public function set height(value:Number):void
		{
			normalBg.height = overBg.height = value;
			if (selectedBg) selectedBg.height = value;
			normalLbl.y = int((value - normalLbl.height) * 0.5);
			redrawMask();
		}
		
		override public function get mouseEnabled():Boolean { return super.mouseEnabled; }
		override public function set mouseEnabled(value:Boolean):void
		{
			super.mouseEnabled = value;
			Tweener.addTween(normalLbl, { alpha: value ? 1 : 0.3, time: .3, transition: "easeOutQuad" } );
		}
		
	}

}
