package com.oxylusflash.app3DFramework.mainMenu
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.IDestroyable;
	import com.oxylusflash.app3DFramework.LabelButton;
	import com.oxylusflash.app3DFramework.RoundedItem;
	import com.oxylusflash.app3DFramework.SimpleButton;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.StageReference;
	import com.oxylusflash.utils.StringUtil;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SubMenu extends RoundedItem
	{
		private var EDGE_TOL:Number = 50;
		public var bgMc:Sprite;
		public var arrowMc:Sprite;
		
		private var initButton:LabelButton;
		
		private var subHolder:DestroyableSprite = new DestroyableSprite;
		private const subGroup:String = "SUB_" + StringUtil.uniqueStr();
		
		private var subW:Number = 0;
		private var subX:Number = 0;
		private var bounds:Rectangle = new Rectangle;
		
		private var settings:Object;
		private var mouseSlide:Boolean = false;
		
		private var MAX_BLUR_X:Number = 0;
		private var MAX_BLUR_Y:Number = 16;
		private var blurFilter:BlurFilter = new BlurFilter(0, 0, BitmapFilterQuality.HIGH);
		
		public static const BUTTON_PRESS:String = "press";

		public function SubMenu()
		{
			this.addChild(subHolder);
			this.alpha = 0;
			
			bgMc.cacheAsBitmap = true;
			arrowMc.cacheAsBitmap = true;
		}
		
		/**
		 * Populate sub menu.
		 * @param	xmlData		XML data.
		 * @param	pSettings	Settings object.
		 * @param	mainWidth	Main menu width.
		 * @param	arrowX		Arrow x position.
		 */
		public function populate(xmlData:XML, pSettings:Object, mainWidth:Number):void
		{
			settings = pSettings;
			
			bgMc.height = settings.subMenu.height;
			
			var offsetX:Number = settings.subMenu.marginX;
			var subButton:LabelButton;
			
			for each(var subCatXML:XML in xmlData.subCategory)
			{
				subButton = subHolder.addChild(new LibSubButton) as LabelButton;
				subButton.fireInstantly = false;
				subButton.group = subGroup;
				subButton.data = subCatXML;
				subButton.x = offsetX;
				subButton.y = int((settings.subMenu.height - settings.subButton.height) * 0.5);
				subButton.height = settings.subButton.height;
				subButton.redrawMask(settings.subButton.corners_tl, settings.subButton.corners_tr, settings.subButton.corners_bl, settings.subButton.corners_br);
				
				offsetX = subButton.x + subButton.width + settings.subMenu.btnSpacing;
				if (!initButton || subCatXML.@selected == "true")  initButton = subButton;
				
				subButton.addEventListener(SimpleButton.PRESS, subButton_pressHandler, false, 0, true);
			}
			bounds.height = subButton.height;
			subW = subButton.x + subButton.width + settings.subMenu.marginX;
			
			if (settings.subMenu.size is Number)
			{
				bgMc.width = settings.subMenu.size;
			}
			else
			{
				switch(settings.subMenu.size)
				{
					case "autoSize": 			bgMc.width = subW; break;
					case "sameAsMain": 			bgMc.width = mainWidth; break;
					case "notBiggerThanMain": 	bgMc.width = Math.min(mainWidth, subW); break;
					case "notSmallerThanMain": 	bgMc.width = Math.max(mainWidth, subW); break;
				}
			}
			bounds.width = bgMc.width;
			redrawMask(settings.subMenu.corners_tl, settings.subMenu.corners_tr, settings.subMenu.corners_bl, settings.subMenu.corners_br);
			
			if (settings.mainMenu.alignY == "bottom")
			{
				arrowMc.scaleY = -1;
				arrowMc.y = this.height;
			}
			else
			{
				arrowMc.scaleY = 1;
				arrowMc.y = 0;
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
			outOfBoundsCheck();
		}
		
		/**
		 * Check if mouse sliding needed.
		 */
		private function outOfBoundsCheck():void
		{
			if (bounds.width < subW)
			{
				subHolderSlideTo(subX, true);
				mouseSlide = true;
			}
			else
			{
				mouseSlide = false;
				switch(settings.subMenu.alignX)
				{
					case "left":
						subHolderSlideTo(0, true)
						break;
						
					case "center":
					case "middle":
						subHolderSlideTo(int((bounds.width - subW) * 0.5), true);
						break;
						
					case "right":
						subHolderSlideTo(bounds.width - subW, true);
						break;
				}
			}
		}
		
		/**
		 * Mouse move handler fr sliding.
		 */
		private function mouseMoveHandler(e:MouseEvent):void
		{
			if (mouseSlide && bounds.contains(mouseX, mouseY))
			{
				var xm:Number = Math.max(EDGE_TOL, Math.min(bounds.width - EDGE_TOL, mouseX)) - EDGE_TOL;
				subHolderSlideTo(xm * (bounds.width - subW) / (bounds.width - 2 * EDGE_TOL));
			}
		}
		
		/**
		 * Slide sub items.
		 * @param	xPos		To x position.
		 * @param	instant		Instant or animated.
		 */
		private function subHolderSlideTo(xPos:int, instant:Boolean = false):void
		{
			if (subW > bounds.width) xPos = Math.min(0, Math.max(bounds.width - subW, xPos));
			
			if (subX != xPos)
			{
				subX = xPos;
				Tweener.addTween(subHolder, { x: subX, time: instant ? 0 : .3, transition: "easeoutquad" } );
			}
		}
		/**
		 * Slide in/out.
		 */
		public function slideIn():void
		{
			var yPos:Number = settings.mainMenu.alignY != "bottom" ? settings.mainButton.height + settings.subMenu.spacingY : -settings.subMenu.spacingY - this.height;
			Tweener.addTween(this, { alpha: 1, y: yPos, time: .25, transition: "easeoutquad", onComplete: slideIn_completHandler } );
		}
		private function slideIn_completHandler():void
		{
			if (initButton)
			{
				initButton.simulatePress();
				initButton = null;
			}
		}
		public function slideOut():void
		{
			if (parent) this.parent.setChildIndex(this, 0);
			Tweener.addTween(this, { alpha: 0, y: 0, time: .15, transition: "easeinquad", onComplete: destroy } );
		}
		
		/**
		 * Sub button click handler.
		 */
		private function subButton_pressHandler(e:ParamEvent):void
		{
			this.dispatchEvent(new ParamEvent(BUTTON_PRESS, { data: e.params.data } ));
		}
		
		/**
		 * Force mask redraw
		 */
		public function forceMaskRedraw():void
		{
			redrawMask(-1, -1, -1, -1, true);
		}
		
		/**
		 * Overrides.
		 */
		override protected function extraDrawing():void
		{
			// put mask over arrow as well
			shapeMask.graphics.drawRect(arrowMc.x - arrowMc.width, arrowMc.y - (arrowMc.scaleY > 0 ? arrowMc.height : 0), 2 * arrowMc.width, arrowMc.height);
		}
		
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			Tweener.removeTweens(subHolder);
			
			settings = null;
			bounds = null;
			
			var i:int = subHolder.numChildren;
			while (i--) IDestroyable(subHolder.getChildAt(i)).destroy();
			
			subHolder.destroy();
			subHolder = null;
			
			this.filters = null;
			blurFilter = null;
			
			SimpleButton.removeGroup(subGroup);
			
			initButton = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			super.destroy();
		}
		
		override public function get width():Number { return bgMc.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }
		override public function set height(value:Number):void { }
		
		override public function get alpha():Number { return super.alpha; }
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			this.visible = value > 0;
			
			blurFilter.blurX = (1 - value) * MAX_BLUR_X;
			blurFilter.blurY = (1 - value) * MAX_BLUR_Y;
			this.filters = value < 1 ? [blurFilter] : null;
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}
