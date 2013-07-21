package com.oxylusflash.app3DFramework.detailView.textBox 
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.scrollBar.ScrollBar;
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.utils.NumberUtil;
	import com.oxylusflash.utils.StageReference;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class TextBox extends DestroyableSprite
	{
		public var bgMc:Sprite;
		public var textSprite:TextSprite;
		public var fadeMsk:FadeMask;
		public var scrollBar:ScrollBar;

		public var maxHeight:Number = 0;
		private var rect:Rectangle = new Rectangle;
		private var textSpriteY:Number = 0;
		
		/* Text box */
		public function TextBox() 
		{
			bgMc.cacheAsBitmap = true;
			textSprite.cacheAsBitmap = true;
			textSprite.mask = fadeMsk;
			this.width = bgMc.width;
			this.height = 0;
		}
		
		/**
		 * Init
		 * @param	pMaxHeight 		Maximum height
		 */
		public function init(pMaxHeight:Number, pScrollBar:ScrollBar):void
		{
			maxHeight = pMaxHeight;
			scrollBar = pScrollBar;
			scrollBar.stepPercentage = 0.1;
			scrollBar.addEventListener(ScrollBar.SCROLL, scrollBar_scrollHandler, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler, false, 0, true);
		}
		
		/* Handle mouse wheel */
		private function stage_mouseWheelHandler(e:MouseEvent):void 
		{
			if (rect.contains(this.mouseX, this.mouseY) && scrollBar.scrollBtnMc.visible)
			{
				scrollBar.stepScroll(-NumberUtil.sign(e.delta));
			}
		}
		
		/* Update scrollbar proportion */
		private function updateScrollBarProportion():void
		{
			if (scrollBar) 
			{
				scrollBar.proportion = this.height / textSprite.height;
			}
		}
		
		/* Update scrollbar percentage */
		private function updateScrollBarPercentage():void
		{
			if (scrollBar) 
			{
				scrollBar.percentage = textSpriteY / (this.height - textSprite.height);
			}
		}
		
		/* Check text sprite y */
		private function checkTextSpriteY():void
		{
			updateTextSpriteY(Math.min(0, Math.max(this.height - textSprite.height, textSpriteY)), true);
		}
		
		/* Scroll handler */
		private function scrollBar_scrollHandler(e:Event = null):void 
		{
			updateTextSpriteY((this.height - textSprite.height) * scrollBar.percentage);
			
		}
		
		/* Update text sprite y */
		private function updateTextSpriteY(targetY:Number, instant:Boolean = false):void
		{
			if (textSprite.y != targetY)
			{
				textSpriteY = targetY;
				Tweener.addTween(textSprite, { y: textSpriteY, time: instant? 0 : 0.2, transition: "easeoutquad" } );
			}
		}
		
		/* Text */
		public function get text():String { return textSprite.text; }
		public function set text(value:String):void
		{
			scrollBar.percentage = 0;
			updateTextSpriteY(0, true);			
			textSprite.text = value;
			updateScrollBarProportion();
		}
		
		/* Style sheet */
		public function get styleSheet():StyleSheet { return textSprite.textField.styleSheet; }
		public function set styleSheet(value:StyleSheet):void 
		{ 
			textSprite.textField.styleSheet = value;
		}
		
		/* Is empty */
		public function get isBlank():Boolean { return StringUtil.isBlank(textSprite.text); }
		
		/* Overrides */
		override public function get width():Number { return rect.width; }		
		override public function set width(value:Number):void 
		{			
			if (rect.width != value)
			{
				rect.width = value;
				bgMc.width = rect.width;
				fadeMsk.width = rect.width;
				textSprite.width = rect.width;
				
				updateScrollBarProportion();
				checkTextSpriteY();
				updateScrollBarPercentage();
				
				this.scrollRect = rect;
			}
		}
		
		override public function get height():Number { return rect.height; }		
		override public function set height(value:Number):void 
		{
			if (rect.height != value)
			{
				rect.height = value;
				bgMc.height = rect.height;
				fadeMsk.height = rect.height;
				
				updateScrollBarProportion();
				checkTextSpriteY();	
				updateScrollBarPercentage();
				
				this.scrollRect = rect;
			}
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}