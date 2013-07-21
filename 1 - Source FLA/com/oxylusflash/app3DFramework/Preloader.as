package com.oxylusflash.app3DFramework
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Preloader extends DestroyableSprite
	{
		private static const SPIN_STEP:Number = 15;
		public static const UPDATE:String = "update";
		
		public var spinnerMc:Sprite;
		public var maskMc:Sprite;
		
		/**
		 * Spinning preloader.
		 */
		public function Preloader()
		{
			spinnerMc.mask = maskMc;
			this.visible = false;
			this.alpha = 1;
		}
		
		/**
		 * Spin.
		 */
		private function enterFrameHandler(e:Event):void
		{
			spinnerMc.rotation += SPIN_STEP;
			dispatchEvent(new Event(UPDATE));
		}
		
		/**
		 * Overrides.
		 */
		override public function destroy():void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			super.destroy();
		}
		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			if (!destroyed)
			{
				var vis:Boolean = value > 0;
				if (this.visible != vis)
				{
					this.visible = vis;
					if (vis) this.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
					else this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				}
			}
		}
		
	}

}