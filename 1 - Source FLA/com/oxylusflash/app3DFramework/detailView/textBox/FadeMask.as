package com.oxylusflash.app3DFramework.detailView.textBox 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class FadeMask extends DestroyableSprite
	{
		public var topMc:Sprite;
		public var midMc:Sprite;
		public var btmMc:Sprite;
		
		public function FadeMask() 
		{
			this.cacheAsBitmap = true;
			this.blendMode = BlendMode.LAYER;
		}
		
		/* Overrides */
		override public function get width():Number { return btmMc.width; }		
		override public function set width(value:Number):void 
		{
			topMc.width = midMc.width = btmMc.width = value;
		}
		
		override public function get height():Number { return btmMc.y; }		
		override public function set height(value:Number):void 
		{
			midMc.height = value - topMc.height - btmMc.height;
			btmMc.y = value;
		}
		
	}

}