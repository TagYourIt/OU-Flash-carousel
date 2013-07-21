package com.oxylusflash.app3DFramework
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.events.ParamEvent;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SimpleButton extends RoundedItem
	{
		
		// Background states
		public var normalBg:Sprite;
		public var overBg:Sprite;
		public var selectedBg:Sprite;
		
		// Button group
		protected var _group:String;
		protected static var selection:Object = { };
		protected var _locked:Boolean = false;
		
		// Button press event name
		public static const PRESS:String = "press";
		
		// Button states toggle
		public static const NORMAL_STATE:int = 0;
		public static const OVER_STATE:int = 1;
		public static const SELECTED_STATE:int = 2;
		protected var _state:int = NORMAL_STATE;
		
		// Fire PRESS event instantly or after button tween
		public var fireInstantly:Boolean = true;
		
		public function SimpleButton()
		{
			// Disable children and show hand cursor
			this.mouseChildren = false;
			this.buttonMode = true;
			this.blendMode = BlendMode.LAYER;
			
			// Disable children and show hand cursor
			this.mouseChildren = false;
			this.buttonMode = true;
			this.blendMode = BlendMode.LAYER;
			
			normalBg.cacheAsBitmap = true;
			overBg.cacheAsBitmap = true;
			if (selectedBg) selectedBg.cacheAsBitmap = true;
			
			// Hide over and selected states
			overBg.alpha = 0;
			if (selectedBg) selectedBg.alpha = 0;
			
			// Init height (will draw the rounded shape)
			this.height = normalBg.height;
			
			// Add event listeners for mouse interaction
			this.addEventListener(MouseEvent.ROLL_OVER, eventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, eventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, eventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, eventsHandler, false, 0, true);
		}
		
		// Events handler
		protected function eventsHandler(e:Event):void
		{
			if (!_locked)
			{
				switch(e.type)
				{
					// On roll over show over state
					case MouseEvent.ROLL_OVER:
						this.state = OVER_STATE;
						if (!MouseEvent(e).buttonDown) MainApp3D.soundsController.playSound("over");
						break;
					// On roll out show over state
					case MouseEvent.ROLL_OUT:
						this.state = NORMAL_STATE;
						break;
					// Play click sound.
					case MouseEvent.MOUSE_DOWN:
						MainApp3D.soundsController.playSound("click");
						break;
					// On click run the click action
					case MouseEvent.CLICK:
						simulatePress();
						break;
				}
			}
		}
		
		/**
		 * If in a group, it will get selected
		 */
		public function select():void
		{
			if (_group)
			{
				this.state = SELECTED_STATE;
				lock();
			}
		}
		
		/**
		 * If in a group, it will get deselected
		 */
		public function deSelect():void
		{
			if (_group)
			{
				unLock();
				this.state = NORMAL_STATE;
			}
		}
		
		/**
		 * Fire press event.
		 */
		protected function firePressEvent():void
		{
			this.dispatchEvent(new Event(PRESS));
		}
		
		/**
		 * Button state
		 */
		public function get state():int { return _state; }
		public function set state(value:int):void
		{
			if (!selectedBg && state == SELECTED_STATE) return;
			
			if (!_locked)
			{
				_state = value;
				
				var overBgAlpha:Number = _state < OVER_STATE ? 0 : 1;
				var selectedBgAlpha:Number = _state < SELECTED_STATE ? 0 : 1;
				
				Tweener.addTween(overBg, { alpha: overBgAlpha, time: .3, transition: "easeOutQuad" } );
				if (_group && selectedBg) Tweener.addTween(selectedBg, { alpha: selectedBgAlpha, time: .3, transition: "easeOutQuad", onComplete: selectedBg_fadeCompleteHandler } );
				
				extraTweens();
			}
		}
		protected function selectedBg_fadeCompleteHandler():void
		{
			if (_state == SELECTED_STATE && !fireInstantly) firePressEvent();
		}
		
		/**
		 * Extra tweens
		 */
		protected function extraTweens():void { }
		
		/**
		 * Tab group
		 */
		public function get group():String { return _group; }
		public function set group(value:String):void
		{
			if (selectedBg)
			{
				_group = value;
			}
		}
		
		/**
		 * Simulate click
		 */
		public function simulatePress():void
		{
			if (!_locked)
			{
				if (_group)
				{
					if (selection[_group]) SimpleButton(selection[_group]).deSelect();
					this.select();
					selection[_group] = this;
					if (fireInstantly) firePressEvent();
				}
				else
				{
					firePressEvent();
				}
			}
		}
		
		/**
		 * Lock/unlock tab interaction
		 */
		public function lock():void
		{
			_locked = true;
			this.useHandCursor = false;
		}
		public function unLock():void
		{
			_locked = false;
			this.useHandCursor = true;
		}
		
		/**
		 * Destroy.
		 */
		override public function destroy():void
		{
			Tweener.removeTweens(selectedBg);
			Tweener.removeTweens(overBg);
			
			this.removeEventListener(MouseEvent.ROLL_OVER, eventsHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, eventsHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, eventsHandler);
			this.removeEventListener(MouseEvent.CLICK, eventsHandler);
			
			super.destroy();
		}
		
		/**
		 * Delete group.
		 * @param	group
		 */
		public static function removeGroup(group:String):void
		{
			if (selection[group]) delete selection[group];
		}
		
		/**
		 * Overrides
		 */
		override public function get width():Number { return normalBg.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return normalBg.height; }
		override public function set height(value:Number):void { }
		
		override public function get alpha():Number { return super.alpha; }
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			this.visible = value > 0;
		}
		
	}

}
