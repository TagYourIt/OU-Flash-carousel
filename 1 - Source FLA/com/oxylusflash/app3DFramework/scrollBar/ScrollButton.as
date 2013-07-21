package com.oxylusflash.app3DFramework.scrollBar
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.utils.StageReference;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ScrollButton extends DestroyableSprite
	{
		public var nStateMc:Sprite;
		public var oStateMc:Sprite;
		public var linesMc:Sprite;
		
		/**
		 * Create scroll button.
		 */
		public function ScrollButton()
		{
			oStateMc.alpha = 0;
			nStateMc.cacheAsBitmap = true;
			oStateMc.cacheAsBitmap = true;
		}
		
		/**
		 * Play over animation.
		 */
		public function playOverAnimation():void
		{
			Tweener.addTween(oStateMc, { alpha: 1, time: .3, transition: "easeoutquad" } );
		}
		
		/**
		 * Play out animation.
		 */
		public function playOutAnimation():void
		{
			Tweener.addTween(oStateMc, { alpha: 0, time: .2, transition: "easeoutquad" } );
		}
		
		/**
		 * Check if button is under mouse cursor.
		 */
		public function get isUnderMouse():Boolean
		{
			return nStateMc.hitTestPoint(stage.mouseX, stage.mouseY, true);
		}
		
		/**
		 * Overrides.
		 */
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
		override public function get width():Number { return nStateMc.width; }
		override public function set width(value:Number):void
		{
			Tweener.removeTweens(oStateMc);
			
			nStateMc.width = value;
			oStateMc.width = nStateMc.width;
			linesMc.x = int(nStateMc.width * 0.5);
		}
		
		override public function get height():Number { return nStateMc.height; }
		override public function set height(value:Number):void
		{
			nStateMc.height = value;
			oStateMc.height = nStateMc.height;
			linesMc.y = int(nStateMc.height * 0.5);
		}
		
		override public function get x():Number { return super.x; }
		override public function set x(value:Number):void
		{
			super.x = int(value);
		}
		
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void
		{
			super.y = int(value);
		}
		
	}

}
