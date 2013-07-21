package com.oxylusflash.app3DFramework.toolTip 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Body extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var textField:TextField;
		private var maskMc:Sprite = new Sprite;
		private var _label:String;
		
		/**
		 * Tooltip body.
		 */
		public function Body() 
		{
			this.addChild(maskMc);
			this.mask = maskMc;
			
			bgMc.cacheAsBitmap = true;
			
			textField.multiline = true;
			textField.wordWrap = false;
			textField.condenseWhite = true;
			textField.autoSize = TextFieldAutoSize.LEFT;
		}
		
		/**
		 * Tooltip text.
		 */
		public function get label():String { return _label; }
		public function set label(value:String):void
		{
			if (_label != value)
			{
				_label = value;
				textField.htmlText = "<span class='leading2'>" + _label + "</span>";
				if (textField.numLines <= 1) textField.htmlText = "<span class='leading0'>" + _label + "</span>";
				
				bgMc.width = Math.round(textField.width + 2 * textField.x);
				bgMc.height = Math.round(textField.height + 2 * textField.y);
			}
		}
		
		/**
		 * Update body mask so the tip won't overlap with the body.
		 * @param	cropW		Crop width.
		 * @param	cropH		Crop height.
		 * @param	position	Position x.
		 */
		public function updateMask(cropW:Number, cropH:Number, position:int):void
		{
			var topH:Number = position == ToolTipInfo.BELLOW ? cropH : 0;
			var btmH:Number = position == ToolTipInfo.ABOVE ? cropH : 0;
			var cropX:Number = Math.abs(this.x) - Math.round(cropW * 0.5);
			var gfx:Graphics = maskMc.graphics;
			
			var p:Number = 10;
			
			gfx.clear();
			gfx.beginFill(0);
			gfx.moveTo(-p, -p);
			gfx.lineTo(cropX, -p);
			gfx.lineTo(cropX, topH);
			gfx.lineTo(cropX + cropW, topH);
			gfx.lineTo(cropX + cropW, -p);
			gfx.lineTo(this.width + p, -p);
			gfx.lineTo(this.width + p, this.height + p);
			gfx.lineTo(cropX + cropW, this.height + p);
			gfx.lineTo(cropX + cropW, this.height - btmH);
			gfx.lineTo(cropX, this.height - btmH);
			gfx.lineTo(cropX, this.height + p);
			gfx.lineTo(-p, this.height + p);
			gfx.lineTo(-p, -p);
			gfx.endFill();	
		}
		
		/**
		 * Overrides.
		 */
		override public function destroy():void 
		{
			this.mask = null;
			maskMc.graphics.clear();
			super.destroy();
		}
		
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }		
		override public function set height(value:Number):void { }
		
	}

}