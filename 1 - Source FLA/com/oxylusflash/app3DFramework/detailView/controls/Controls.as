package com.oxylusflash.app3DFramework.detailView.controls
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.IconButton;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Controls extends DestroyableSprite
	{
		private static const VIEW_H:Number = 150;
		
		private var spacing:Number;
		
		public var bgMc:Sprite;
		public var playBtn:IconButton;
		public var pauseBtn:IconButton;
		public var progressBar:ProgressBar;
		public var timeDisplay:TimeDisplay;
		public var replayBtn:IconButton;
		public var volumeBtn:VolumeButton;
		public var fullscreenBtn:IconButton;
		public var nscreenBtn:IconButton;
		public var albumartBtn:IconButton;
		public var osciloBtn:IconButton;
		public var spectrumBtn:IconButton;
		
		private var rect:Rectangle = new Rectangle;
		
		public static const INVISIBLE:int = 0;
		public static const VISIBLE:int = 1;
		private var _state:int = 0;
		
		public var triggerZoneHeight:Number = 105;
		
		public function Controls()
		{
			spacing = playBtn.x;
			
			rect.y = -bgMc.height;
			rect.height = VIEW_H;
			updateScrollRect();
			bgMc.cacheAsBitmap = true;
			
			pauseBtn.visible = false;
			toVideo();
			
			bgMc.y = VIEW_H - bgMc.height;
			playBtn.y = bgMc.y + Math.round((bgMc.height - playBtn.height) * 0.5);
			pauseBtn.x = playBtn.x;
			pauseBtn.y = playBtn.y;
			progressBar.x = playBtn.x + playBtn.width + spacing;
			progressBar.y = bgMc.y + Math.round((bgMc.height - progressBar.height) * 0.5);
			timeDisplay.y = progressBar.y;
			replayBtn.y = bgMc.y + Math.round((bgMc.height - replayBtn.height) * 0.5);
			volumeBtn.y = replayBtn.y;
			fullscreenBtn.y = replayBtn.y;
			nscreenBtn.y = replayBtn.y;
			albumartBtn.y = replayBtn.y;
			osciloBtn.y = replayBtn.y;
			spectrumBtn.y = replayBtn.y;
			
			this.width = 500;
		}
		
		/* Show */
		public function show():void
		{
			if (_state == INVISIBLE)
			{
				_state = VISIBLE;
				Tweener.addTween(rect, { y: 0, rounded: true, time: 0.15, transition: "easeoutquad", onUpdate: updateScrollRect } );
			}
		}
		
		/* Hide */
		public function hide(instant:Boolean = false):void
		{
			if (_state == VISIBLE)
			{
				_state = INVISIBLE;
				Tweener.addTween(rect, { y: -bgMc.height, rounded: true, time: instant ? 0 : 0.3, transition: "easeoutquad", onUpdate: updateScrollRect } );
			}
		}
		
		/* Update scrollRect */
		private function updateScrollRect():void
		{
			this.scrollRect = rect;
			this.mouseEnabled = this.mouseChildren = rect.y == 0;
		}
		
		/* Show audio specific controls */
		public function toAudio():void
		{
			fullscreenBtn.visible = false;
			nscreenBtn.visible = false;
			albumartBtn.visible = false;
			osciloBtn.visible = true;
			spectrumBtn.visible = false;
		}
		
		/* Show video specific controls */
		public function toVideo():void
		{
			fullscreenBtn.visible = true;
			fullscreenBtn.mouseEnabled = false;
			nscreenBtn.visible = false;
			albumartBtn.visible = false;
			osciloBtn.visible = false;
			spectrumBtn.visible = false;
		}
		
		public function get state():int { return _state; }
		
		/* Overrides */
		override public function get width():Number { return rect.width; }
		override public function set width(value:Number):void
		{
			if (rect.width != value)
			{
				rect.width = value;
				bgMc.width = rect.width;
				fullscreenBtn.x = rect.width - spacing - fullscreenBtn.width;
				nscreenBtn.x = fullscreenBtn.x;
				albumartBtn.x = fullscreenBtn.x;
				osciloBtn.x = fullscreenBtn.x;
				spectrumBtn.x = fullscreenBtn.x;
				volumeBtn.x = fullscreenBtn.x - spacing - volumeBtn.width;
				replayBtn.x = volumeBtn.x - spacing - replayBtn.width;
				timeDisplay.x = replayBtn.x - spacing - timeDisplay.width;
				progressBar.width = timeDisplay.x - progressBar.x;
				updateScrollRect();
			}
		}
		
		override public function get height():Number { return rect.height; }
		override public function set height(value:Number):void { }
		
		override public function destroy():void
		{
			super.destroy();
			updateScrollRect();
		}
		
	}

}