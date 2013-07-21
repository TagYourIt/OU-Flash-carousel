package com.oxylusflash.app3DFramework.environment3D 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SolidColorSource extends MaterialSource
	{
		private var fillMc:Sprite;
		private var maxW:Number;
		private var maxH:Number;
		
		/**
		 * Solid color material source.
		 * @param	color		Color.
		 * @param	maxWidth	Maximum width.
		 * @param	maxHeight	Maximum height.
		 */
		public function SolidColorSource(color:uint = 0xFFFFFF, maxWidth:Number = 230, maxHeight:Number = 160) 
		{
			super(maxWidth, maxHeight);
			
			maxW = maxWidth;
			maxH = maxHeight;
			
			fillMc = this.addChild(new Sprite) as Sprite;
			fillMc.graphics.beginFill(color);
			fillMc.graphics.drawRect(0, 0, maxW, maxH);
			fillMc.graphics.endFill();
			
			update();
		}
		
		/**
		 * Destroy material source.
		 */
		override public function destroy():void 
		{
			this.removeChild(fillMc);
			fillMc = null;
			super.destroy();
		}
		
		/**
		 * Overrides.
		 */
		override public function get width():Number { return fillMc.width; }		
		override public function set width(value:Number):void 
		{
			fillMc.width = value;
			fillMc.x = int((maxW - fillMc.width) * 0.5);
		}
		
		override public function get height():Number { return fillMc.height; }		
		override public function set height(value:Number):void 
		{
			fillMc.height = value;
			fillMc.y = int((maxH - fillMc.height) * 0.5);
		}
		
	}

}