package com.oxylusflash.app3DFramework.detailView 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.scrollBar.ScrollBar;
	import flash.display.Sprite;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ScrollBarHolder extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var scrollBar:ScrollBar = new LibVertScrollBar2;
		private var padding:Number = 0;
		
		public function ScrollBarHolder() 
		{
			this.addChild(scrollBar);
		}
		
		/**
		 * Init 
		 * @param	p Padding
		 */
		public function init(p:Number):void
		{
			padding = p;
			scrollBar.y = padding;
			bgMc.width = scrollBar.width + padding;
			this.y = -this.width;
		}
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }		
		override public function set height(value:Number):void
		{
			if (value > 2 * padding)
			{
				this.visible = true;
				bgMc.height = value;
				scrollBar.height = bgMc.height - 2 * padding;
			}
			else
			{
				this.visible = false;
			}
		}
		
		override public function destroy():void 
		{
			scrollBar.destroy();
			scrollBar = null;
			super.destroy();
		}
	}

}