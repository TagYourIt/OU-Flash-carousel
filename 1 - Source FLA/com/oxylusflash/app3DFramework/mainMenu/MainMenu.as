package com.oxylusflash.app3DFramework.mainMenu
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.IDestroyable;
	import com.oxylusflash.app3DFramework.LabelButton;
	import com.oxylusflash.app3DFramework.SimpleButton;
	import com.oxylusflash.app3DFramework.SoundsController;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.StageReference;
	import com.oxylusflash.utils.StringUtil;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MainMenu extends DestroyableSprite
	{
		private var EDGE_TOL:Number = 50;
		
		private var mainHolder:DestroyableSprite = new DestroyableSprite;
		private const mainGroup:String = "MAIN_" + StringUtil.uniqueStr();
		
		private var mainW:Number = 0;
		private var mainX:Number = 0;
		private var bounds:Rectangle = new Rectangle;
		
		private var settings:Object;
		private var mouseSlide:Boolean = false;

		private var subMenu:SubMenu;
		public static const DATA_OUT:String = "dataOut";
		
		public function MainMenu()
		{
			this.addChild(mainHolder);
		}
		
		/**
		 * Populate menu.
		 * @param	xmlData		XML data.
		 * @param	pSettings	Settings object.
		 */
		public function populate(xmlData:XML, pSettings:Object):void
		{
			settings = pSettings;
			
			var offsetX:Number = settings.mainMenu.marginX;
			var mainButton:LabelButton;
			var initButton:LabelButton;
			
			for each(var catXML:XML in xmlData.category)
			{
				mainButton = mainHolder.addChild(new LibMainButton) as LabelButton;
				mainButton.group = mainGroup;
				mainButton.data = catXML;
				mainButton.x = offsetX;
				mainButton.height = settings.mainButton.height;
				mainButton.redrawMask(settings.mainButton.corners_tl, settings.mainButton.corners_tr, settings.mainButton.corners_bl, settings.mainButton.corners_br);
				
				offsetX = mainButton.x + mainButton.width + settings.mainMenu.btnSpacing;
				if (initButton == null || catXML.@selected == "true") initButton = mainButton;
				
				mainButton.addEventListener(SimpleButton.PRESS, mainButton_pressHandler, false, 0, true);
			}
			
			bounds.height = mainButton.height;
			mainW = mainButton.x + mainButton.width + settings.mainMenu.marginX;
			
			if (initButton) initButton.simulatePress();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
		}
		
		/**
		 * Check if out of bounds.
		 */
		private function outOfBoundsCheck():void
		{
			if (bounds.width < mainW)
			{
				mainHolderSlideTo(mainX, true);
				mouseSlide = true;
			}
			else
			{
				mouseSlide = false;
				switch(settings.mainMenu.alignX)
				{
					case "left":
						mainHolderSlideTo(0, true)
						break;
						
					case "center":
					case "middle":
						mainHolderSlideTo(int((bounds.width - mainW) * 0.5), true);
						break;
						
					case "right":
						mainHolderSlideTo(bounds.width - mainW, true);
						break;
				}
			}
		}
		
		/**
		 * Mouse move handler for sliding.
		 */
		private function mouseMoveHandler(e:MouseEvent):void
		{
			if (mouseSlide && bounds.contains(mouseX, mouseY))
			{
				var xm:Number = Math.max(EDGE_TOL, Math.min(bounds.width - EDGE_TOL, mouseX)) - EDGE_TOL;
				mainHolderSlideTo(xm * (bounds.width - mainW) / (bounds.width - 2 * EDGE_TOL));
			}
		}
		
		/**
		 * Slide main holder.
		 * @param	xPos		To x position.
		 * @param	instant		Instant or animated.
		 */
		private function mainHolderSlideTo(xPos:int, instant:Boolean = false):void
		{
			if (mainW > bounds.width) xPos = Math.min(0, Math.max(bounds.width - mainW, xPos));
			
			if (mainX != xPos)
			{
				mainX = xPos;
				Tweener.addTween(mainHolder, { x: mainX, time: instant ? 0 : .3, transition: "easeoutquad" } );
			}
		}
		
		/**
		 * Main button click handler (show sub menu or display items).
		 */
		private function mainButton_pressHandler(e:ParamEvent):void
		{
			var xmlData:XML = e.params.data;
			var hadSubMenu:Boolean = false;
			
			if (subMenu)
			{
				hadSubMenu = true;
				subMenu.removeEventListener(SubMenu.BUTTON_PRESS, subMenu_buttonPressHandler);
				subMenu.slideOut();
				subMenu = null;
			}
			
			if (xmlData.subCategory.length())
			{
				var actualW:Number = mainW - 2 * settings.mainMenu.marginX;
				
				subMenu = mainHolder.addChildAt(new LibSubMenu, 0) as SubMenu;
				subMenu.addEventListener(SubMenu.BUTTON_PRESS, subMenu_buttonPressHandler, false, 0, true);
				subMenu.populate(xmlData, settings, actualW);
				
				subMenu.x = settings.mainMenu.marginX;
				subMenu.y = 0;
				
				var m:Number = 20; // arrow tip margin
				var clickedBtn:LabelButton = LabelButton(e.currentTarget);
				var btnMidX:Number = clickedBtn.x + clickedBtn.width * 0.5 - settings.mainMenu.marginX;
				var subWidth:Number = subMenu.width - 2 * m;
				
				if (subMenu.width > actualW || btnMidX - subWidth > 0 && btnMidX + subWidth < actualW) { subMenu.x += int((actualW - subMenu.width) * 0.5); }
				else if (btnMidX - subWidth > 0) { subMenu.x += actualW - subMenu.width; }
				
				subMenu.arrowMc.x = subMenu.globalToLocal(clickedBtn.localToGlobal(new Point(clickedBtn.width * 0.5, 0))).x;
				subMenu.forceMaskRedraw();
				subMenu.slideIn();
			}
			else
			{
				this.dispatchEvent(new ParamEvent(DATA_OUT, { data: xmlData } ));
			}
		}
		
		/**
		 * Sub button press handler.
		 */
		private function subMenu_buttonPressHandler(e:ParamEvent):void
		{
			this.dispatchEvent(new ParamEvent(DATA_OUT, { data: e.params.data } ));
		}
		
		/**
		 * Destroy method.
		 */
		override public function destroy():void
		{
			Tweener.removeTweens(mainHolder);
			
			settings = null;
			bounds = null;
			
			var i:int = mainHolder.numChildren;
			while (i--) IDestroyable(mainHolder.getChildAt(i)).destroy();
			
			mainHolder.destroy();
			mainHolder = null;
			
			SimpleButton.removeGroup(mainGroup);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			super.destroy();
		}
		
		/**
		 * Overrides.
		 */
		override public function get width():Number { return bounds.width; }
		override public function set width(value:Number):void
		{
			bounds.width = value;
			outOfBoundsCheck();
		}
		
		override public function get height():Number { return bounds.height; }
		override public function set height(value:Number):void { }
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}
