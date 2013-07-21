package com.oxylusflash.app3DFramework.toolTip
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.utils.StageReference;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ToolTip extends DestroyableSprite
	{
		private static const BORDER:Number = 1;
		private static const MARGIN_X:Number = 15;
		
		private var position:int = ToolTipInfo.ABOVE;
		
		public var bodyMc:Body;
		public var tipMc:Sprite;
		
		private var offsetY:Number = 20;
		private var offsetX:Number = 0;
		private var mouseFollow:Boolean = true;
		private var showDelay:Number;
		private var stayFor:Number;
		
		private var infoDict:Dictionary = new Dictionary(true);
		
		private var showTimer:Timer = new Timer(0 ,1);
		private var hideTimer:Timer = new Timer(0, 1);
		
		private static const VISIBLE:int = 1;
		private static const INVISIBLE:int = 0;
		private var _state:int = INVISIBLE;
		
		/* Tooltip */
		public function ToolTip()
		{
			this.mouseChildren = this.mouseEnabled = false;
			this.alpha = 0;
			this.label = "...";
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
			
			tipMc.cacheAsBitmap = true;
			
			showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timers_timerCompleteHandler, false, 0, true);
			hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timers_timerCompleteHandler, false, 0, true);
		}
		
		/* Show / hide timers events handlers. */
		private function timers_timerCompleteHandler(e:TimerEvent):void
		{
			switch(e.currentTarget)
			{
				case showTimer: fadeIn(); break;
				case hideTimer: hide(); break;
			}
		}
		
		/* Stage mouse move handler - tooltip follows mouse. */
		private function stage_mouseMoveHandler(e:MouseEvent):void
		{
			if (parent && this.visible && mouseFollow)
			{
				updatePos(parent.mouseX, parent.mouseY);
				if (stage.displayState != StageDisplayState.FULL_SCREEN) e.updateAfterEvent();
			}
		}
		
		/**
		 * Update tooltip position.
		 * @param	posX	Position x.
		 * @param	posY	Position y.
		 */
		private function updatePos(posX:Number, posY:Number)
		{
			this.x = Math.round(offsetX + Math.max(MARGIN_X, Math.min(parent.width - MARGIN_X, posX)));
			this.y = Math.round(posY + (position == ToolTipInfo.ABOVE ? -1 : 1) * offsetY);
			updateBodyX();
		}
		
		/* Tooltip label text. */
		public function get label():String { return bodyMc.label; }
		public function set label(value:String):void
		{
			bodyMc.label = value;
			arrange();
		}
		
		/* Arrange tooltip. */
		private function arrange():void
		{
			switch(position)
			{
				case ToolTipInfo.ABOVE:
					tipMc.rotation = 0;
					bodyMc.y = -(tipMc.height - BORDER + bodyMc.height);
					break;
					
				default:
					tipMc.rotation = 180;
					bodyMc.y = tipMc.height - BORDER;
					break;
			}
			updateBodyX();
			updateBodyMask();
		}
		
		/* Update body x position so it doesn't get out of bounds. */
		private function updateBodyX():void
		{
			if (parent)
			{
				var bodyX:Number = Math.max(0, Math.min(parent.width - bodyMc.width, this.x - Math.round(bodyMc.width * 0.5))) - this.x;
				if (bodyMc.x != bodyX)
				{
					bodyMc.x = bodyX;
					updateBodyMask();
				}
			}
		}
		
		/* Update body mask */
		private function updateBodyMask():void
		{
			bodyMc.updateMask(tipMc.width - 2 * BORDER, BORDER, position);
		}
		
		/**
		 * Show tooltip.
		 * @param	tipInfo		Info object.
		 */
		public function show(tipInfo:ToolTipInfo):void
		{
			_state = VISIBLE;
			
			resetTimers();
			Tweener.removeTweens(this, "alpha");
			this.alpha = 0;
			
			mouseFollow = tipInfo.mouseFollow;
			offsetX = tipInfo.offsetX;
			offsetY = tipInfo.offsetY;
			position = tipInfo.position;
			showDelay = Math.max(0, tipInfo.showDelay * 1000);
			stayFor = Math.max(0, tipInfo.stayFor * 1000);
			this.label = tipInfo.tipString;
			
			showTimer.delay = Math.max(1, showDelay);
			hideTimer.delay = Math.max(1, stayFor);
			
			if (!mouseFollow && parent)
			{
				var posPoint:Point = tipInfo.item.localToGlobal(new Point(Math.round(tipInfo.item.width * 0.5), (position == ToolTipInfo.ABOVE ? 0 : tipInfo.item.height)));
				posPoint = parent.globalToLocal(posPoint);
				updatePos(posPoint.x, posPoint.y);
			}
			
			if (showDelay) showTimer.start();
			else fadeIn();
		}
		
		/* Hide tooltip. */
		public function hide():void
		{
			if (_state != INVISIBLE)
			{
				_state = INVISIBLE;
				Tweener.addTween(this, { alpha: 0, time: .15, transition: "easeoutquad" } );
				resetTimers();
			}
		}
		
		/* Reset show/hide timers. */
		private function resetTimers():void
		{
			showTimer.reset();
			hideTimer.reset();
		}
		
		/* Tooltip fade in. */
		private function fadeIn():void
		{
			if (mouseFollow && parent) updatePos(parent.mouseX, parent.mouseY);
			Tweener.addTween(this, { alpha: 1, time: .3, transition: "easeoutquad", onComplete: fadeIn_completeHandler  } );
		}
		
		/* Tooltip fade in complete handler. */
		private function fadeIn_completeHandler():void
		{
			if (stayFor) hideTimer.start();
		}
		
		/**
		 * Add tooltip for a GUI item.
		 * @param	item		Item.
		 * @param	tipInfo		Info object.
		 */
		public function addItemTooltip(item:Sprite, tipInfo:ToolTipInfo):void
		{
			tipInfo.item = item;
			infoDict[item] = tipInfo;
			item.addEventListener(MouseEvent.ROLL_OVER, item_evetHandlers, false, 0, true);
			item.addEventListener(MouseEvent.ROLL_OUT, item_evetHandlers, false, 0, true);
			item.addEventListener(MouseEvent.MOUSE_DOWN, item_evetHandlers, false, 0, true);
		}
		
		/* GUI items events handler. */
		private function item_evetHandlers(e:MouseEvent):void
		{
			var item:Sprite = e.currentTarget as Sprite;
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER: if (!e.buttonDown) show(infoDict[item]); break;
				case MouseEvent.MOUSE_DOWN:
				case MouseEvent.ROLL_OUT: hide(); break;
			}
		}
		
		/* Tooltip text style sheet. */
		public function get styleSheet():StyleSheet { return bodyMc.textField.styleSheet; }
		public function set styleSheet(value:StyleSheet):void
		{
			bodyMc.textField.styleSheet = value;
		}
		
		/* Overrides. */
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			bodyMc.destroy();
			bodyMc = null;
			super.destroy();
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
	
		override public function get alpha():Number { return super.alpha; }
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			this.visible = value > 0;
		}
		
	}

}
