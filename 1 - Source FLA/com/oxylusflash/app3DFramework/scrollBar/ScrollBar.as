package com.oxylusflash.app3DFramework.scrollBar 
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.IconButton;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.NumberUtil;
	import com.oxylusflash.utils.StageReference;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ScrollBar extends DestroyableSprite
	{		
		// Stage movieclips
		public var scrollTrackMc:Sprite;
		public var scrollBtnMc:ScrollButton;
		public var scrollArw1Mc:IconButton;
		public var scrollArw2Mc:IconButton;
		
		// Orientation
		private static const VERTICAL:String = "vertical";
		private static const HORIZONTAL:String = "horizontal";
		private var orientation:String;
		
		// scroll event
		public static const SCROLL:String = "scroll";
		
		// user interaction
		public static const USER_INTERACTION:String = "userInteraction";
		
		// scrollbar percentage and proportion
		private var _percentage:Number = 0;
		private var _proportion:Number = 1;
		
		// scroll arrow buttons params
		public var stepPercentage:Number = 0.1;
		private var circular:Boolean = false;
		
		private var scrollDir:int = 1;
		private var waitTimer:Timer = new Timer(400, 1);
		private var scrollTimer:Timer = new Timer(100, 0);
		
		// scroll button margin and drag params
		private var scrollBtnMargin:Number;
		private var mouseDif:Number;
		private var scrollDist:Number;
		private var maxSBSize:Number;
		private var minSBPos:Number;
		private var minSBSize:Number = 16;
		
		[Event(name="scroll", type="flash.events.Event")] 
		
		// Constructor
		public function ScrollBar() 
		{			
			orientation = super.width > super.height ? HORIZONTAL : VERTICAL;
			
			this.scaleX = this.scaleY = 1;
			
			if (orientation == HORIZONTAL) 
			{
				scrollBtnMargin = scrollBtnMc.y;
				this.width = super.width;
			}
			else 
			{
				scrollBtnMargin = scrollBtnMc.x;
				this.height = super.height;
			}
			
			scrollTrackMc.cacheAsBitmap = true;
			
			scrollBtnMc.buttonMode = true;
			scrollBtnMc.addEventListener(MouseEvent.ROLL_OVER, scrollBtnMc_eventsHandler, false, 0, true);
			scrollBtnMc.addEventListener(MouseEvent.ROLL_OUT, scrollBtnMc_eventsHandler, false, 0, true);
			scrollBtnMc.addEventListener(MouseEvent.MOUSE_DOWN, scrollBtnMc_eventsHandler, false, 0, true);
			
			waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timers_eventsHandler, false, 0, true);
			scrollTimer.addEventListener(TimerEvent.TIMER, timers_eventsHandler, false, 0, true);
			
			scrollArw1Mc.addEventListener(MouseEvent.MOUSE_DOWN, scrollMcs_mouseDownHandler, false, 0, true);
			scrollArw2Mc.addEventListener(MouseEvent.MOUSE_DOWN, scrollMcs_mouseDownHandler, false, 0, true);
		}
		
		// Init scrollbar from settings
		public function init(settings:Object):void
		{
			this.visible = settings.visible;
			
			minSBSize = settings.minScrollBtnSize;
			
			if (orientation == HORIZONTAL) this.width = settings.size;
			else this.height = settings.size;

			waitTimer.delay = Math.max(1, settings.autoScrollAfter * 1000);
			scrollTimer.delay = Math.max(1, settings.autoScrollDelay * 1000);
			circular = settings.circularScroll;
		}
		
		// scroll arrow buttons mouse down handlers
		private function scrollMcs_mouseDownHandler(e:MouseEvent):void 
		{
			dispatchEvent(new Event(USER_INTERACTION));
			scrollDir = e.currentTarget == scrollArw1Mc ? -1 : 1;
			stepScroll(scrollDir);
			waitTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
		}
		
		// 1 scroll
		public function stepScroll(dir:int = 1):void
		{
			var crtPerc:Number = _percentage;
			var newPerc:Number = _percentage + dir * stepPercentage;			
			this.percentage = newPerc < 0 ? (circular ? newPerc + 1 : 0) : (newPerc > 1 ? (circular ? newPerc - 1 : 1) : newPerc);
			fireScrollEvent(crtPerc);
		}
		
		// timer events handler
		private function timers_eventsHandler(e:TimerEvent):void 
		{
			switch(e.type)
			{
				case TimerEvent.TIMER_COMPLETE: 
					waitTimer.reset();
					scrollTimer.start();
					break;
					
				case TimerEvent.TIMER:
					stepScroll(scrollDir);
					//e.updateAfterEvent();
					break;
			}
		}
		
		// stage mouse up fater arrow buttons click
		private function stage_mouseUpHandler(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			waitTimer.reset();
			scrollTimer.reset();
		}
		
		// Scroll button events handler
		private function scrollBtnMc_eventsHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER:
					scrollBtnMc.playOverAnimation();
					if (!e.buttonDown) MainApp3D.soundsController.playSound("over");
					break;
					
				case MouseEvent.ROLL_OUT:
					if (!e.buttonDown) scrollBtnMc.playOutAnimation();
					break;
					
				case MouseEvent.MOUSE_DOWN:
					dispatchEvent(new Event(USER_INTERACTION));
					if (orientation == HORIZONTAL)
					{
						mouseDif = scrollBtnMc.isUnderMouse ? mouseX - scrollBtnMc.x : Math.round(scrollBtnMc.width * 0.5);
					}
					else
					{
						mouseDif = scrollBtnMc.isUnderMouse ? mouseY - scrollBtnMc.y : Math.round(scrollBtnMc.height * 0.5);
					}
					stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_eventsHandler, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, stage_eventsHandler, false, 0, true);
					if (!scrollBtnMc.isUnderMouse) stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
					MainApp3D.soundsController.playSound("click");
					break;
			}
		}
		
		// stage events handler after track click
		private function stage_eventsHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_MOVE:	
					var crtPerc:Number = _percentage;
					this.percentage = ((orientation == HORIZONTAL ? mouseX : mouseY) - mouseDif - minSBPos) / scrollDist;
					fireScrollEvent(crtPerc);
					if (stage.displayState != StageDisplayState.FULL_SCREEN) e.updateAfterEvent();
					break;
					
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_eventsHandler);
					stage.removeEventListener(MouseEvent.MOUSE_UP, stage_eventsHandler);
					if (!scrollBtnMc.isUnderMouse) scrollBtnMc.playOutAnimation();
					break;
			}
		}
		
		// scrollbar proportion
		public function get proportion():Number { return _proportion; }		
		public function set proportion(value:Number):void 
		{
			value = int(NumberUtil.limit(value, 0, 1) * 1000) / 1000;
			if (_proportion != value)
			{
				_proportion = value;
				updateScrollBtn();
			}
		}
		
		// scroll percentage
		public function get percentage():Number { return _percentage; }		
		public function set percentage(value:Number):void 
		{
			value = int(NumberUtil.limit(value, 0, 1) * 1000) / 1000;
			if (_percentage != value)
			{
				_percentage = value;
				updateScrollBtn();
			}
		}
		
		// update scroll button dimension and position
		private function updateScrollBtn():void
		{
			scrollBtnMc.visible = this.mouseChildren = _proportion < 1;
			if (orientation == HORIZONTAL)
			{
				scrollBtnMc.width = Math.max(minSBSize, Math.round(_proportion * maxSBSize));
				scrollDist = maxSBSize - scrollBtnMc.width;			
				scrollBtnMc.x = minSBPos + Math.round(_percentage * scrollDist);
			}
			else
			{
				scrollBtnMc.height = Math.max(minSBSize, Math.round(_proportion * maxSBSize));
				scrollDist = maxSBSize - scrollBtnMc.height;			
				scrollBtnMc.y = minSBPos + Math.round(_percentage * scrollDist);
			}
		}
		
		// fire scroll event
		private function fireScrollEvent(oldPerc:Number = -1):void
		{
			if (_percentage != oldPerc) dispatchEvent(new ParamEvent(SCROLL, { percentage: percentage } ));
		}
		
		/**
		 * Overrides
		 */
		override public function get width():Number
		{ 
			return orientation == HORIZONTAL ? int(scrollArw2Mc.x + scrollArw2Mc.width) : int(scrollTrackMc.width); 
		}		
		override public function set width(value:Number):void 
		{
			if (orientation == HORIZONTAL)
			{
				value = int(value);
				scrollTrackMc.width = value - 2 * scrollTrackMc.x;
				scrollArw2Mc.x = scrollTrackMc.x + scrollTrackMc.width - (scrollArw1Mc.width - scrollTrackMc.x);
				maxSBSize = scrollTrackMc.width - 2 * scrollBtnMargin;
				minSBPos = scrollTrackMc.x + scrollBtnMargin;
				updateScrollBtn();
			}
		}
		
		override public function get height():Number 
		{ 
			return int(orientation == VERTICAL ? scrollArw2Mc.y + scrollArw2Mc.height : scrollTrackMc.height);  
		}		
		override public function set height(value:Number):void 
		{ 
			if (orientation == VERTICAL)
			{
				value = int(value);
				scrollTrackMc.height = value - 2 * scrollTrackMc.y;
				scrollArw2Mc.y = scrollTrackMc.y + scrollTrackMc.height - (scrollArw1Mc.height - scrollTrackMc.y);
				maxSBSize = scrollTrackMc.height - 2 * scrollBtnMargin;
				minSBPos = scrollTrackMc.y + scrollBtnMargin;
				updateScrollBtn();
			}
		}
		
		override public function destroy():void 
		{
			super.destroy();
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}