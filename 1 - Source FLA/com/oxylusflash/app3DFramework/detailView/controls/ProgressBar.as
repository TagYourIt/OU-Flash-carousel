package com.oxylusflash.app3DFramework.detailView.controls 
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.detailView.SlideTip;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.utils.StageReference;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ProgressBar extends DestroyableSprite
	{
		public static const PROGRESS_CHANGE:String = "progressChange";
		
		public var bgMc:Sprite;
		public var patternMc:Sprite;
		public var loadingInd:Sprite;
		public var progressInd:Sprite;
		public var progressTip:SlideTip;
		
		private var _totalTime:Number = 0;
		private var _currentTime:Number = 0;
		
		private var _loading:Number = 0.6;
		private var _progress:Number = 0;
		private var _mouseDrag:Boolean = false;
		
		private var patternBd:BitmapData = new LibProgressBarPattern(0, 0);
		
		public function ProgressBar() 
		{
			bgMc.cacheAsBitmap = true;
			patternMc.cacheAsBitmap = true;
			loadingInd.cacheAsBitmap = true;
			progressInd.cacheAsBitmap = true;	
		
			progressTip.alpha = 0;
			progressTip.useHandCursor = false;
			
			this.width = 200;
			
			bgMc.mouseEnabled = false;
			patternMc.mouseEnabled = false;
			progressInd.mouseEnabled = false;
			progressTip.mouseEnabled = false;
			
			loadingInd.buttonMode = true;
			loadingInd.addEventListener(MouseEvent.ROLL_OVER, mouseEventsHandler, false, 0, true);
			loadingInd.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventsHandler, false, 0, true);
			loadingInd.addEventListener(MouseEvent.ROLL_OUT, mouseEventsHandler, false, 0, true);
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
					progressTip.x = Math.max(progressInd.x, Math.min(loadingInd.x + loadingInd.width - (progressInd.x - loadingInd.x), mouseX));
					if (_mouseDrag) this.progress = (progressTip.x - progressInd.x) / (this.width - 2 * progressInd.x);
					updateTip();
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
				stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
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
		
		/* Update loading indicator */
		public function updateLoadingInd():void
		{
			loadingInd.width = Math.round((bgMc.width - 2 * loadingInd.x) * _loading);
		}
		
		/* Update progress indicator */
		public function updateProgressInd():void
		{
			progressInd.width = Math.min(loadingInd.width, Math.round((bgMc.width - 2 * progressInd.x) * _progress));
		}
		
		/* Is under mouse */
		public function get isUnderMouse():Boolean
		{
			return loadingInd.hitTestPoint(stage.mouseX, stage.mouseY, true);
		}
		
		/* Update tip */
		public function updateTip():void
		{
			progressTip.textField.text = StringUtil.toTimeString(Math.round((progressTip.x - progressInd.x) / (bgMc.width - 2 * progressInd.x) * _totalTime));
		}
		
		/* Properties */
		/* Loading */
		public function get loading():Number { return _loading; }		
		public function set loading(value:Number):void 
		{
			value = Math.max(0, Math.min(1, value));
			if (_loading != value)
			{
				_loading = value;
				updateLoadingInd();
			}
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
			
				if (_mouseDrag) 
				{
					dispatchEvent(new ParamEvent(PROGRESS_CHANGE, { progress: _progress } ));
				}
			}
		}
		
		/* Mouse drag */
		public function get mouseDrag():Boolean { return _mouseDrag; }
		
		/* Total time */
		public function get totalTime():Number { return _totalTime; }		
		public function set totalTime(value:Number):void 
		{
			if (_totalTime != value)
			{
				_totalTime = value;
				updateTip();
			}
		}
		
		/* Current time */
		public function get currentTime():Number { return _currentTime; }		
		public function set currentTime(value:Number):void 
		{
			if (_currentTime != value)
			{
				_currentTime = value;				
			}
		}
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }		
		override public function set width(value:Number):void 
		{
			if (bgMc.width != value)
			{
				bgMc.width = value;
				updatePatternMc();
				updateLoadingInd();
				updateProgressInd();
			}			
		}
		
		override public function get height():Number { return bgMc.height; }		
		override public function set height(value:Number):void { }
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}