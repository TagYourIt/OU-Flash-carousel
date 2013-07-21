package com.oxylusflash.app3DFramework.detailView.controls 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import caurina.transitions.Tweener;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.StageReference;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
	/**
	 * Slider
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Slider extends DestroyableSprite
	{
		public static const PROGRESS_CHANGE:String = "progressChange";
		
		public var bgMc:Sprite;
		public var patternMc:Sprite;
		public var progressInd:Sprite;
		public var progressTip:Sprite;
		
		private var _progress:Number = 0.75;
		private var _mouseDrag:Boolean = false;
		
		private var patternBd:BitmapData = new LibSliderPattern(0, 0);		
		private var margin:Number;
		
		public function Slider() 
		{
			margin = this.height - progressInd.y - progressInd.height;
			
			bgMc.cacheAsBitmap = true;
			patternMc.cacheAsBitmap = true;
			progressInd.cacheAsBitmap = true;	
		
			progressTip.alpha = 0;
			progressTip.useHandCursor = false;
			
			updatePatternMc();
			
			this.hitArea = bgMc;
			this.buttonMode = true;
			this.mouseChildren = false;
			
			this.addEventListener(MouseEvent.ROLL_OVER, mouseEventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseEventsHandler, false, 0, true);
		}
		
		/* Mouse events handler */
		private function mouseEventsHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER: 
					stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseEventsHandler, false, 0, true);
					showProgressTip();
					break;
				case MouseEvent.ROLL_OUT: 
					hideProgressTip(); 
					if (!_mouseDrag) stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseEventsHandler);
					break;
				case MouseEvent.MOUSE_DOWN: 
					_mouseDrag = true;					
					stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseEventsHandler, false, 0, true);	
					stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
					break;
			}
		}
		
		/* Stage mouse events handler */
		private function stage_mouseEventsHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_MOVE:
					if (_mouseDrag) this.progress = 1 - (Math.max(margin, Math.min(this.height - margin, mouseY)) - margin) / (this.height - 2 * margin);
					if (stage.displayState != StageDisplayState.FULL_SCREEN) e.updateAfterEvent();
					break;
					
				case MouseEvent.MOUSE_UP: 
					_mouseDrag = false;
					stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseEventsHandler);					
					if (!isUnderMouse) stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseEventsHandler);
					hideProgressTip();
					break;
			}
		}
		
		/* Show progress tip */
		private function showProgressTip():void
		{
			if (!progressTip.useHandCursor)
			{
				progressTip.useHandCursor = true;
				Tweener.addTween(progressTip, { alpha: 1, time: 0.2, transition: "easeoutquad" } );
			}
		}
		
		/* Hide progress tip */
		private function hideProgressTip():void
		{
			if (!_mouseDrag && !isUnderMouse) 
			{
				if (progressTip.useHandCursor)
				{
					progressTip.useHandCursor = false;
					Tweener.addTween(progressTip, { alpha: 0, time: 0.2, transition: "easeoutquad" } );
				}
			}
		}
		
		/* Update pattern */
		public function updatePatternMc():void
		{
			patternMc.graphics.clear();
			patternMc.graphics.beginBitmapFill(patternBd);
			patternMc.graphics.drawRect(0, 0, this.width - 2 * patternMc.x, this.height - 2 * patternMc.y);
			patternMc.graphics.endFill();
		}
		
		/* Update progress indicator */
		public function updateProgressInd():void
		{
			progressInd.height = Math.round((this.height - 2 * margin) * _progress);
			progressInd.y = this.height - margin - progressInd.height;
			progressTip.y = progressInd.y;
		}
		
		/* Is under mouse */
		public function get isUnderMouse():Boolean
		{
			return this.hitTestPoint(stage.mouseX, stage.mouseY, true);
		}
		
		/* Progress */
		public function get progress():Number { return _progress; }		
		public function set progress(value:Number):void 
		{
			value = Math.max(0, Math.min(1, value));
			if (_progress != value)
			{
				_progress = value;
				updateProgressInd();
				dispatchEvent(new ParamEvent(PROGRESS_CHANGE, { progress: _progress } ));
			}
		}
		
		/* Mouse drag */
		public function get mouseDrag():Boolean { return _mouseDrag; }
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void { }		
		
		override public function get height():Number { return bgMc.height; }		
		override public function set height(value:Number):void { }
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}