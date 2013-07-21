package com.oxylusflash.app3DFramework
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.utils.StageReference;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class IconButton extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var normalIcon:MovieClip;
		public var overIcon:MovieClip;
		
		public var preventSound:Boolean = false;
		
		/* Button only with icon (no label). */
		public function IconButton()
		{
			bgMc.cacheAsBitmap = true;
			normalIcon.cacheAsBitmap = true;
			overIcon.cacheAsBitmap = true;
			
			this.mouseChildren = false;
			this.buttonMode = true;
			this.hitArea = bgMc;
			overIcon.alpha = 0;
			
			this.addEventListener(MouseEvent.ROLL_OVER, eventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, eventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, eventsHandler, false, 0, true);
		}
		
		/**
		 * Rollover/out events handler.
		 */
		private function eventsHandler(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER: 	rollOverAction(e.buttonDown); break;
				case MouseEvent.ROLL_OUT: 	rollOutAction(e.buttonDown); break;
				case MouseEvent.MOUSE_DOWN: mouseDownAction(); break;
			}
		}
		
		/* Roll over action */
		protected function rollOverAction(buttonDown:Boolean):void
		{
			Tweener.addTween(overIcon, { alpha: 1, time: .3, transition: "easeoutquad", onUpdate: updateNormalIcon } );
			if (preventSound) preventSound = false;
			else
			{
				if (!buttonDown) MainApp3D.soundsController.playSound("over");
			}
		}
		
		/* Roll out action */
		protected function rollOutAction(buttonDown:Boolean):void
		{
			forceRollOut();
		}
		
		/* Mouse down action */
		protected function mouseDownAction():void
		{
			MainApp3D.soundsController.playSound("click");
		}
		
		/* Force button rollout */
		public function forceRollOut():void
		{
			Tweener.addTween(overIcon, { alpha: 0, time: .3, transition: "easeoutquad", onUpdate: updateNormalIcon } );
		}
		
		/**
		 * Update normal state icon.
		 */
		protected function updateNormalIcon():void
		{
			normalIcon.visible = overIcon.alpha < 1;
		}
		
		/**
		 * Button is under the mouse pointer.
		 */
		public function get isUnderMouse():Boolean
		{
			return bgMc.hitTestPoint(stage.mouseX, stage.mouseY, true);
		}
		
		/**
		 * Click simulation.
		 */
		public function simulateClick():void
		{
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		/**
		 * Overrides.
		 */
		override public function get width():Number { return bgMc.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }
		override public function set height(value:Number):void { }
		
		override public function destroy():void
		{
			Tweener.removeTweens(overIcon);
			
			this.removeEventListener(MouseEvent.ROLL_OVER, eventsHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, eventsHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, eventsHandler);
			super.destroy();
		}
		
		override public function get visible():Boolean { return super.visible; }
		override public function set visible(value:Boolean):void
		{
			if (value && isUnderMouse)
			{
				preventSound = true;
				Tweener.removeTweens(overIcon);
				overIcon.alpha = 0.99;
			}
			super.visible = value;
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}
