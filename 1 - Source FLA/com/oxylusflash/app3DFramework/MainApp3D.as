package com.oxylusflash.app3DFramework
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.detailView.DetailView;
	import com.oxylusflash.app3DFramework.environment3D.Environment3D;
	import com.oxylusflash.app3DFramework.mainMenu.MainMenu;
	import com.oxylusflash.app3DFramework.scrollBar.ScrollBar;
	import com.oxylusflash.app3DFramework.toolTip.ToolTip;
	import com.oxylusflash.app3DFramework.toolTip.ToolTipInfo;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.events.StageLayoutEvent;
	import com.oxylusflash.utils.NumberUtil;
	import com.oxylusflash.utils.StageLayout;
	import com.oxylusflash.utils.StageReference;
	import com.oxylusflash.utils.XMLUtil;
	import com.oxylusflash.wall3D.Wall3DEnvironment;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.utils.Timer;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MainApp3D extends DestroyableSprite
	{
		public static const AUTO_PLAY_USER_INPUT:String = "autoPlayUserInput";
		
		public var bgMc:Sprite;
		public var mainMenu:MainMenu;
		
		public var toolBarMc:DestroyableSprite;
		public var playBtn:IconButton;
		public var pauseBtn:IconButton;
		public var fullScreenBtn:IconButton;
		public var normalScreenBtn:IconButton;
		
		public var scrollBar:ScrollBar;
		public var env3D:Wall3DEnvironment;
		
		private var xmlLoader:URLLoader;
		private var xml:XML;
		private var xmlOnce:Boolean = false;
		
		public var styleSheet:StyleSheet;
		
		public var settings:Object = { };
		public var layout:StageLayout;
		
		public var tooltip:ToolTip;
		public var toolTips:Object = { };
		
		public var autoPlayTimer:Timer;
		public var autoPlayDir:int;
		
		private var wallXMLLoader:URLLoader = new URLLoader;
		
		public static var soundsController:SoundsController;
		
		public var overlay:Overlay;
		public var detailView:DetailView;
		
		private var rect:Rectangle = new Rectangle;
		
		/**
		 * Main 3D application.
		 */
		public function MainApp3D()
		{
			this.visible = false;
			this.scrollRect = rect;
			
			bgMc.cacheAsBitmap = true;
			bgMc.x = bgMc.y = 0;
			
			if (stage) initAfterStage();
			else this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
		}
		
		/**
		 * When added to stage.
		 */
		private function addedToStageHandler(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			initAfterStage();
		}
		
		/**
		 * Init after added to stage.
		 */
		private function initAfterStage():void
		{
			StageReference.init(stage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, stage_fullScreenHandler, false, 0, true);
			
			loadMainXML(stage.loaderInfo.parameters.xmlFile);
		}
		
		/**
		 * Load main xml file (only once)
		 * @param	xmlPath	XML file path.
		 */
		public function loadMainXML(xmlPath:String):void
		{
			if (xmlOnce)
			{
				throw new Error("Main XML can be loaded only once !");
			}
			else
			{
				xmlOnce = true;
				xmlLoader = new URLLoader;
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoader_eventsHandler, false, 0, true);
				xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoader_eventsHandler, false, 0, true);
				xmlLoader.addEventListener(Event.COMPLETE, xmlLoader_eventsHandler, false, 0, true);
				xmlLoader.load(new URLRequest(xmlPath || "main.xml"));
			}
		}
		
		/**
		 * XML load events handler.
		 */
		private function xmlLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					trace(ErrorEvent(e).text);
					break;
				
				case Event.COMPLETE:
					xml = new XML(xmlLoader.data);
					initAfterXMLLoad();
					break;
			}
			
			destroyXMLLoader();
		}
		
		/**
		 * Init after XML load.
		 */
		private function initAfterXMLLoad():void
		{
			var styleSheetStr:String = String(xml.styleSheet[0].text());
			styleSheetStr += ".leading0 { leading: 0; }"; // for one line text
			styleSheetStr += ".leading2 { leading: 2; }"; // for text on more than one line
			styleSheet = new StyleSheet;
			styleSheet.parseCSS(styleSheetStr);
			
			populateSettings();
			populateToolTips();
			
			addSounds();
			addEnvironment3D();
			addScrollBar();
			addToolBar();
			addMainMenu();
			addOverlay();
			addDetailView();
			addToolTip(); // must be the last, to be on top
			
			initAutoPlay();
			
			layout = StageLayout.getInstance();
			layout.addEventListener(StageLayoutEvent.RESIZE, layout_resizeHandler, false, 0, true);
			layout.init(stage, settings.layout.width, settings.layout.height, settings.layout.minWidth, settings.layout.minHeight, settings.layout.offsetX, settings.layout.offsetY);
			
			initApplication();
		}
		
		/**
		 * Parse XML settings.
		 */
		private function populateSettings():void
		{
			var children:XMLList = xml.settings[0].children();
			var child:XML;
			for each(child in children) settings[child.name()] = com.oxylusflash.utils.XMLUtil.getParams(child);
		}
		
		/**
		 * Parse XML tooltips.
		 */
		private function populateToolTips():void
		{
			var child:XML;
			var child2:XML;
			var children:XMLList = xml.toolTips[0].children();
			var childInfo:Object;
			
			for each(child in children)
			{
				childInfo = { };
				for each(child2 in child.children()) childInfo[child2.name()] = new ToolTipInfo(child2);
				toolTips[child.name()] = childInfo;
			}
		}
		
		/**
		 * Add sounds
		 */
		private function addSounds():void
		{
			if (!soundsController)
			{
				soundsController = new SoundsController(settings.sounds.volume);
				soundsController.addSound("over", settings.sounds.mouseOver);
				soundsController.addSound("click", settings.sounds.click);
				soundsController.addSound("flip", settings.sounds.thumb3DFlip);
			}
		}
		
		/**
		 * Add 3D environment.
		 */
		private function addEnvironment3D():void
		{
			env3D = new Wall3DEnvironment(this);
			env3D.addEventListener(Environment3D.DATA_OUT, env3D_eventsHandler, false, 0, true);
			this.addChild(env3D);
		}
		
		/**
		 * Environment 3D events handler.
		 */
		private function env3D_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case Environment3D.DATA_OUT:
					detailView.feed(ParamEvent(e).params.data);
					break;
			}
		}
		
		/**
		 * Add scrollbar.
		 */
		private function addScrollBar():void
		{
			scrollBar = new LibHorizScrollBar;
			this.addChild(scrollBar);
			
			scrollBar.addEventListener(ScrollBar.SCROLL, scrollBar_eventsHandler, false, 0, true);
			scrollBar.addEventListener(ScrollBar.USER_INTERACTION, scrollBar_eventsHandler, false, 0, true);
			scrollBar.init(settings.scrollBar);
			
			if (settings.scrollBar.mouseWheelScroll)
			{
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, scrollBar_eventsHandler, false, 0, true);
			}
		}
		/**
		 * Scrollbar events handler.
		 */
		private function scrollBar_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case ScrollBar.SCROLL:
					env3D.percentageInput(ParamEvent(e).params.percentage);
					break;
					
				case ScrollBar.USER_INTERACTION:
					stopAutoPlay();
					break;
					
				case MouseEvent.MOUSE_WHEEL:
					if (!overlay.visible)
					{
						stopAutoPlay();
						scrollBar.stepScroll(NumberUtil.sign( -MouseEvent(e).delta));
					}
					break;
			}
		}
		
		/**
		 * Add toolbar.
		 */
		private function addToolBar():void
		{
			toolBarMc = new DestroyableSprite;
			this.addChild(toolBarMc);
			toolBarMc.visible = settings.toolBar.visible;
			
			playBtn = new LibPlayButton;
			pauseBtn = new LibPauseButton;
			fullScreenBtn = new LibToFullscreenButton;
			normalScreenBtn = new LibToNormalScreenButton;
			
			toolBarMc.addChild(playBtn);
			toolBarMc.addChild(pauseBtn);
			toolBarMc.addChild(fullScreenBtn);
			toolBarMc.addChild(normalScreenBtn);
			
			playBtn.x = pauseBtn.x = settings.playButton.offsetX;
			playBtn.y = pauseBtn.y = settings.playButton.offsetY;
			
			fullScreenBtn.x = normalScreenBtn.x = settings.fullScreenButton.offsetX;
			fullScreenBtn.y = normalScreenBtn.y = settings.fullScreenButton.offsetY;
			
			pauseBtn.visible = normalScreenBtn.visible = false;
			playBtn.visible = settings.playButton.visible;
			fullScreenBtn.visible = settings.fullScreenButton.visible;
			
			playBtn.addEventListener(MouseEvent.CLICK, toolBarBtn_clickHandler, false, 0, true);
			pauseBtn.addEventListener(MouseEvent.CLICK, toolBarBtn_clickHandler, false, 0, true);
			fullScreenBtn.addEventListener(MouseEvent.CLICK, toolBarBtn_clickHandler, false, 0, true);
			normalScreenBtn.addEventListener(MouseEvent.CLICK, toolBarBtn_clickHandler, false, 0, true);
		}
		
		/**
		 * Toolbar buttons click handler.
		 */
		private function toolBarBtn_clickHandler(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case playBtn:
					playBtn.visible = false && settings.playButton.visible;
					pauseBtn.visible = true && settings.playButton.visible;
					autoPlayTimer.start();
					dispatchEvent(new Event(AUTO_PLAY_USER_INPUT));
					break;
					
				case pauseBtn:
					pauseBtn.visible = false && settings.playButton.visible;
					playBtn.visible = true && settings.playButton.visible;
					autoPlayTimer.reset();
					dispatchEvent(new Event(AUTO_PLAY_USER_INPUT));
					break;
					
				case fullScreenBtn:
					stage.displayState = StageDisplayState.FULL_SCREEN;
					break;
					
				case normalScreenBtn:
					stage.displayState = StageDisplayState.NORMAL;
					break;
			}
		}
		
		/**
		 * Stage fullscreen handler.
		 */
		private function stage_fullScreenHandler(e:FullScreenEvent):void
		{
			normalScreenBtn.visible = stage.displayState != StageDisplayState.NORMAL && settings.fullScreenButton.visible;
			fullScreenBtn.visible = !normalScreenBtn.visible && settings.fullScreenButton.visible;
		}
		
		/**
		 * Add main menu.
		 */
		private function addMainMenu():void
		{
			wallXMLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, wallXMLLoader_eventsHandler, false, 0, true);
			wallXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, wallXMLLoader_eventsHandler, false, 0, true);
			wallXMLLoader.addEventListener(Event.COMPLETE, wallXMLLoader_eventsHandler, false, 0, true);
			
			mainMenu = this.addChild(new MainMenu) as MainMenu;
			mainMenu.visible = settings.mainMenu.visible;
			mainMenu.addEventListener(MainMenu.DATA_OUT, mainMenu_dataOutHandler, false, 0, true);
			mainMenu.populate(xml.content[0], settings);
		}
		
		/**
		 * Main menu button click handler.
		 */
		private function mainMenu_dataOutHandler(e:ParamEvent):void
		{
			stopAutoPlay();
			env3D.clear();
			
			try { wallXMLLoader.close(); } catch (err:Error) { }
			wallXMLLoader.load(new URLRequest(String(e.params.data.text())));
		}
		
		/**
		 * Wall XML loader events handler.
		 */
		private function wallXMLLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case SecurityErrorEvent.SECURITY_ERROR:
				case IOErrorEvent.IO_ERROR: trace(ErrorEvent(e).text); break;
				case Event.COMPLETE: env3D.populate(new XML(wallXMLLoader.data)); break;
			}
		}
		
		/**
		 * Add overlay
		 */
		private function addOverlay():void
		{
			overlay = new Overlay;
			this.addChild(overlay);
		}
		
		/**
		 * Add detail view
		 */
		private function addDetailView():void
		{
			detailView = new LibDetailView;
			this.addChild(detailView);
		}
		
		/**
		 * Add tooltip
		 */
		private function addToolTip():void
		{
			tooltip = this.addChild(new LibToolTip) as ToolTip;
			tooltip.styleSheet = styleSheet;
			
			tooltip.addItemTooltip(scrollBar.scrollArw1Mc, toolTips.scrollBar.arrowBtn1);
			tooltip.addItemTooltip(scrollBar.scrollBtnMc, toolTips.scrollBar.scrollTrack);
			tooltip.addItemTooltip(scrollBar.scrollArw2Mc, toolTips.scrollBar.arrowBtn2);
			
			tooltip.addItemTooltip(playBtn, toolTips.toolBar.playBtn);
			tooltip.addItemTooltip(pauseBtn, toolTips.toolBar.pauseBtn);
			tooltip.addItemTooltip(fullScreenBtn, toolTips.toolBar.fullScreenBtn);
			tooltip.addItemTooltip(normalScreenBtn, toolTips.toolBar.normalScreenBtn);
		}
		
		/**
		 * Init auto play.
		 */
		private function initAutoPlay():void
		{
			autoPlayDir = settings.autoPlay.direction != "forward" ? -1 : 1;
			autoPlayTimer = new Timer(settings.autoPlay.delay * 1000);
			autoPlayTimer.addEventListener(TimerEvent.TIMER, autoPlayTimer_timerHandler, false, 0, true);
		}
		/**
		 * Autoplay timer handlers.
		 */
		private function autoPlayTimer_timerHandler(e:TimerEvent):void
		{
			scrollBar.stepScroll(autoPlayDir);
		}
		
		/**
		 * Start auto play.
		 */
		public function startAutoPlay():void
		{
			playBtn.simulateClick();
		}
		
		/**
		 * Stop auto play.
		 */
		public function stopAutoPlay():void
		{
			pauseBtn.simulateClick();
		}
		
		/**
		 * Auto play is on.
		 */
		public function autoPlayRunning():Boolean
		{
			return autoPlayTimer.running;
		}
		
		/**
		 * Layout resize handler.
		 */
		private function layout_resizeHandler(e:StageLayoutEvent):void
		{
			rect.width = layout.width;
			rect.height = layout.height;
			this.scrollRect = rect;
			
			bgMc.width = layout.width;
			bgMc.height = layout.height;
			
			mainMenu.width = layout.width;
			if (settings.mainMenu.alignY == "bottom") mainMenu.y = layout.height - mainMenu.height;
			
			env3D.width = layout.width;
			env3D.height = layout.height;
			
			updateItemPosition(toolBarMc, settings.toolBar);
			updateItemPosition(scrollBar, settings.scrollBar);
			
			overlay.updateSize(layout.width, layout.height);
			
			detailView.width = layout.width;
			detailView.height = layout.height;
		}
		
		/**
		 * Update item position.
		 * @param	item	Item.
		 * @param	posInfo	Position info.
		 */
		private function updateItemPosition(item:DisplayObject, posInfo:Object):void
		{
			if (posInfo.alignX)
			{
				var marginX:Number = posInfo.marginX ? posInfo.marginY : 0;
				switch(posInfo.alignX)
				{
					case "middle":
					case "center": 	item.x = int((layout.width - item.width) * 0.5); break;
					case "left": 	item.x = marginX; break;
					case "right": 	item.x = layout.width - item.width - marginX; break;
				}
			}
			
			if (posInfo.alignY)
			{
				var marginY:Number = posInfo.marginY ? posInfo.marginY : 0;
				switch(posInfo.alignY)
				{
					case "middle":
					case "center": 	item.y = int((layout.height - item.height) * 0.5); break;
					case "top": 		item.y = marginY; break;
					case "bottom": 	item.y = layout.height - item.height - marginY; break;
				}
			}
		}
		
		/**
		 * Init application.
		 */
		private function initApplication():void
		{
			env3D.init();
			detailView.init(this);
			this.visible = true;
		}
		
		/**
		 * Destroy xml loader.
		 */
		private function destroyXMLLoader():void
		{
			if (xmlLoader)
			{
				try { xmlLoader.close(); }
				catch(error:Error) { }
				xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlLoader_eventsHandler);
				xmlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoader_eventsHandler);
				xmlLoader.removeEventListener(Event.COMPLETE, xmlLoader_eventsHandler);
				xmlLoader = null;
			}
		}
		
		/**
		 * App is blocked from mouse interaction
		 */
		public function get interactive():Boolean { return this.mouseChildren; }
		public function set interactive(value:Boolean):void { this.mouseChildren = value; }
		
		/**
		 * Overrides.
		 */
		override public function destroy():void
		{
			Tweener.removeAllTweens();
			
			if (xmlLoader) { destroyXMLLoader(); }
			if (mainMenu) { mainMenu.destroy();	mainMenu = null;	}
			if (toolBarMc) { toolBarMc.destroy(); toolBarMc = null; }
			if (playBtn) { playBtn.destroy(); playBtn = null; }
			if (pauseBtn) { pauseBtn.destroy(); pauseBtn = null; }
			if (fullScreenBtn) { fullScreenBtn.destroy(); fullScreenBtn = null; }
			if (normalScreenBtn) { normalScreenBtn.destroy(); normalScreenBtn = null; }
			if (scrollBar) { scrollBar.destroy(); scrollBar = null; }
			if (env3D) { env3D.destroy(); env3D = null; }
			xml = null;
			styleSheet = null;
			settings = null;
			layout.removeEventListener(StageLayoutEvent.RESIZE, layout_resizeHandler);
			layout = null;
			if (tooltip) { tooltip.destroy(); tooltip = null; }
			toolTips = null;
			if (autoPlayTimer) { autoPlayTimer.reset(); autoPlayTimer = null; }
			if (soundsController) { soundsController.destroy(); soundsController = null; }
			if (detailView) { detailView.destroy(); detailView = null; }
			
			super.destroy();
		}
		
		override public function get width():Number { return layout.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return layout.height; }
		override public function set height(value:Number):void { }

	}

}
