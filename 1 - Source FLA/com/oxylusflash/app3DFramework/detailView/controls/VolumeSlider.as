package com.oxylusflash.app3DFramework.detailView.controls 
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * Volume slider
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class VolumeSlider extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var slider:Slider;
		
		private var rect:Rectangle = new Rectangle;
		
		private static const INVISIBLE:int = 0;
		private static const VISIBLE:int = 1;
		private var state:int = 0;
		
		public function VolumeSlider() 
		{
			rect.width = bgMc.width + 100;
			rect.height = bgMc.height;
			rect.y = -bgMc.height;
			updateScrollRect();
		}
		
		/* Show */
		public function show():void
		{
			if (state == INVISIBLE)
			{
				state = VISIBLE;
				Tweener.addTween(rect, { y: 0, rounded: true, time: 0.15, transition: "easeoutquad", onUpdate: updateScrollRect } );
			}
		}
		
		/* Hide */
		public function hide(instant:Boolean = false):void
		{
			if (state == VISIBLE)
			{
				state = INVISIBLE;
				Tweener.addTween(rect, { y: -bgMc.height, rounded: true, time: instant ? 0 : 0.15, transition: "easeoutquad", onUpdate: updateScrollRect } );
			}
		}
		
		/* Update scrollRect */
		private function updateScrollRect():void
		{
			this.scrollRect = rect;
		}
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return rect.height; }		
		override public function set height(value:Number):void { }
		
		override public function destroy():void 
		{
			super.destroy();
			updateScrollRect();
		}
		
	}

}