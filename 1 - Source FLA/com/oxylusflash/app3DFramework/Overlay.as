package com.oxylusflash.app3DFramework
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Overlay extends DestroyableSprite
	{
		private var pattern:BitmapData = new LibOverlayPattern(0, 0);
		
		private static const INVISIBLE:int = 0;
		private static const VISIBLE:int = 1;
		private var _state:int = INVISIBLE;
		
		/**
		 * Overlay.
		 */
		public function Overlay()
		{
			this.alpha = 0;
		}
		
		/**
		 * Update overlay
		 */
		public function updateSize(w:Number, h:Number):void
		{
			this.graphics.clear();
			this.graphics.beginBitmapFill(pattern);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
		}
		
		/**
		 * Show overlay
		 */
		public function show():void
		{
			if (_state == INVISIBLE)
			{
				_state = VISIBLE;
				this.alpha = 0.01;
				Tweener.addTween(this, { alpha: 1, time: .3, transition: "easeoutquad" } );
			}
		}
		
		/**
		 * Hide overlay
		 */
		public function hide():void
		{
			if (_state == VISIBLE)
			{
				_state = INVISIBLE;
				Tweener.addTween(this, { alpha: 0, time: .3, transition: "easeoutquad" } );
			}
		}
		
		/**
		 * Overrides
		 */
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			this.visible = value > 0;
		}
		
		override public function set width(value:Number):void { }
		override public function set height(value:Number):void { }
		
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			this.graphics.clear();
			pattern.dispose();
			pattern = null;
			super.destroy();
		}
		
	}

}
