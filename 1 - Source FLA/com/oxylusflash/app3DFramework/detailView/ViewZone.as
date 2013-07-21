package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.*;
	import com.oxylusflash.app3DFramework.detailView.controls.Controls;
	import com.oxylusflash.app3DFramework.detailView.controls.ProgressBar;
	import com.oxylusflash.app3DFramework.detailView.controls.Slider;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.framework.events.*;
	import com.oxylusflash.framework.playback.*;
	import com.oxylusflash.framework.resize.AlignType;
	import com.oxylusflash.framework.resize.Resize;
	import com.oxylusflash.framework.resize.ResizeType;
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.utils.StageReference;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ViewZone extends DestroyableSprite
	{
		public static const SIZE_INFO:String = "sizeInfo";
		private static const IMAGE:String = "image";
		private static const VIDEO:String = "video";
		private static const AUDIO:String = "audio";
		private static const FLASH:String = "flash";
		
		private static var PRELOADER_VISIBLE:int = 1;
		private static var PRELOADER_INVISIBLE:int = 0;
		private var preloaderState:int = PRELOADER_INVISIBLE;
		
		public var bgMc:Sprite;
		public var videoBg:Sprite;
		public var preloader:Preloader = new LibPreloaderBig;
		public var zoomPanner:ZoomPanner = new ZoomPanner;
		public var controls:Controls = new LibControls;
		public var rollOutZone:Sprite = new Sprite;
		
		private var rect:Rectangle = new Rectangle;
		
		private var filePath:URLRequest;
		private var fileType:String;
		
		private var origWidth:Number;
		private var origHeight:Number;
		private var ratio:Number;
		
		private var video:VideoX = new VideoX;
		private var videoPback:VideoPlayback;
		private var audioPback:AudioPlayback;
		private var imageLoader:Loader;
		private var swfLoader:Loader;
		private var albumArtLoader:Loader;
		private var albumArtPath:URLRequest;
		private var visualisation:Visualisation = new LibVisualisation;
		
		private var allowZoom:Boolean = false;
		private var initZoomed:Boolean = false;
		
		private var globalDisplayState:String;
		public static const NORMAL_SIZE:int = 0;
		public static const FULL_SCREEN:int = 1;
		public var videoState:int = NORMAL_SIZE;
		
		private var normalRect:Rectangle;
		private var detailBox:DetailBox;
		
		private var cursorHideTimer:Timer = new Timer(1500, 1);
		
		public function ViewZone()
		{
			bgMc.cacheAsBitmap = true;
			videoBg.cacheAsBitmap = true;
			this.scrollRect = rect;
			this.mouseEnabled = false;
			this.mouseChildren = false;
			this.addChild(video);
			this.addChild(zoomPanner);
			this.addChild(visualisation);
			this.addChild(controls);
			this.addChild(preloader);
			preloader.alpha = 0;
			video.alpha = 0;
			
			rollOutZone.graphics.beginFill(0, 0);
			rollOutZone.graphics.drawRect(0, 0, 1, 1);
			rollOutZone.graphics.endFill();
			rollOutZone.visible = false;
			rollOutZone.cacheAsBitmap = true;
			
			videoPback = new VideoPlayback(video);
			videoPback.addEventListener(MediaLoadEvent.LOAD_START, videoPback_loadEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaLoadEvent.LOAD_PROGRESS, videoPback_loadEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaLoadEvent.LOAD_COMPLETE, videoPback_loadEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaBufferingEvent.BUFFERING_START, videoPback_bufferingEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaBufferingEvent.BUFFERING_END, videoPback_bufferingEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaPlaybackEvent.PLAYBACK_READY, videoPback_playbackEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaPlaybackEvent.PLAYBACK_START, videoPback_playbackEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, videoPback_playbackEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaPlaybackEvent.PLAYBACK_STOP, videoPback_playbackEventsHandler, false, 0, true);
			videoPback.addEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, videoPback_playbackEventsHandler, false, 0, true);
			
			audioPback = new AudioPlayback();
			audioPback.addEventListener(MediaLoadEvent.LOAD_START, audioPback_loadEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaLoadEvent.LOAD_PROGRESS, audioPback_loadEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaLoadEvent.LOAD_COMPLETE, audioPback_loadEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaBufferingEvent.BUFFERING_START, audioPback_bufferingEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaBufferingEvent.BUFFERING_END, audioPback_bufferingEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaPlaybackEvent.PLAYBACK_READY, audioPback_playbackEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaPlaybackEvent.PLAYBACK_START, audioPback_playbackEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, audioPback_playbackEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaPlaybackEvent.PLAYBACK_STOP, audioPback_playbackEventsHandler, false, 0, true);
			audioPback.addEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, audioPback_playbackEventsHandler, false, 0, true);
			
			controls.progressBar.addEventListener(ProgressBar.PROGRESS_CHANGE, progressBar_progressChangeHandler, false, 0, true);
			controls.playBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.pauseBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.replayBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.fullscreenBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.nscreenBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.albumartBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.osciloBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.spectrumBtn.addEventListener(MouseEvent.CLICK, controls_clickHandler, false, 0, true);
			controls.volumeBtn.volumeSlider.slider.addEventListener(Slider.PROGRESS_CHANGE, volumeSlider_progressChangeHandler, false, 0, true);
			
			this.addEventListener(MouseEvent.ROLL_OVER, mouseEventsHandler, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseEventsHandler, false, 0, true);
			
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, stage_fullScreenHandler, false, 0, true);
			cursorHideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cursorHideTimer_timerCompleteHandler, false, 0, true);
		}
		
		/* Init */
		public function init(pDetailBox:DetailBox):void
		{
			detailBox = pDetailBox;
			this.parent.addChild(rollOutZone);
		}
		
		/* Stage fullscreen event handler */
		private function stage_fullScreenHandler(e:FullScreenEvent):void
		{
			if (fileType == VIDEO)
			{
				switch(stage.displayState)
				{
					case StageDisplayState.FULL_SCREEN: videoToFullScreen(); break;
					default: videoToNormalSize(); break;
				}
			}
		}
		
		/* Controls click handler */
		private function controls_clickHandler(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case controls.playBtn: mediaPback.play();  break;
				case controls.pauseBtn: mediaPback.pause(); break;
				case controls.replayBtn: mediaPback.replay(); break;
				
				case controls.fullscreenBtn:
					globalDisplayState = stage.displayState;
					videoState = FULL_SCREEN;
					if (stage.displayState != StageDisplayState.FULL_SCREEN) stage.displayState = StageDisplayState.FULL_SCREEN;
					videoToFullScreen(true);
					break;
					
				case controls.nscreenBtn:
					if (stage.displayState != globalDisplayState) stage.displayState = globalDisplayState;
					videoToNormalSize();
					break;
					
				case controls.albumartBtn:
					controls.albumartBtn.visible = false;
					controls.osciloBtn.visible = true;
					visualisation.hide();
					break;
					
				case controls.osciloBtn:
					controls.osciloBtn.visible = false;
					controls.spectrumBtn.visible = true;
					visualisation.toOscilloscope();
					visualisation.show();
					break;
					
				case controls.spectrumBtn:
					controls.spectrumBtn.visible = false;
					controls.albumartBtn.visible = true;
					visualisation.toSpectrum();
					visualisation.show();
					break;
			}
		}
		
		/* Video to fullscreen */
		private function videoToFullScreen(forced:Boolean = false):void
		{
			if (videoState == NORMAL_SIZE || forced)
			{
				videoState = FULL_SCREEN;
				
				controls.fullscreenBtn.visible = false;
				controls.nscreenBtn.visible = true;
				controls.fullscreenBtn.forceRollOut();
				controls.nscreenBtn.forceRollOut();
				
				normalRect = new Rectangle(this.x, this.y, this.width, this.height);
				
				this.width = stage.width;
				this.height = stage.height;
				
				bgMc.y = rollOutZone.height;
				bgMc.visible = false;
				rollOutZone.visible = true;
				
				var position:Point = this.parent.globalToLocal(new Point(0, 0));
				this.x = position.x;
				this.y = position.y;
				
				var videoRect:Rectangle = Resize.compute(new Rectangle(0, 0, video.videoWidth, video.videoHeight), new Rectangle(0, 0, this.width, this.height), ResizeType.FIT_FORCED, AlignType.CENTER);
				video.x = videoRect.x;
				video.y = videoRect.y;
				video.width = videoRect.width;
				video.height = videoRect.height;
				
				if (!isUnderMouse)
				{
					controls.hide(true);
					cursorHideTimer.reset();
					cursorHideTimer.start();
				}
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
			}
		}
		
		/* Video to normal size */
		private function videoToNormalSize():void
		{
			if (videoState == FULL_SCREEN)
			{
				videoState = NORMAL_SIZE;
				
				controls.fullscreenBtn.visible = true;
				controls.nscreenBtn.visible = false;
				controls.fullscreenBtn.forceRollOut();
				controls.nscreenBtn.forceRollOut();
				
				bgMc.y = 0;
				bgMc.visible = true;
				rollOutZone.visible = false;
				video.x = video.y = 0;
				
				this.x = normalRect.x;
				this.y = normalRect.y;
				this.width = normalRect.width;
				this.height = normalRect.height;
				
				if (!isUnderMouse) controls.hide(true);
				if (detailBox) detailBox.centerAlign();
				
				cursorHideTimer.reset();
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
				Mouse.show();
			}
		}
		
		/* Cursor auto-hide */
		private function stage_mouseMoveHandler(e:MouseEvent):void
		{
			cursorHideTimer.reset();
			Mouse.show();
			if (controls.state == Controls.INVISIBLE) cursorHideTimer.start();
		}
		private function cursorHideTimer_timerCompleteHandler(e:TimerEvent):void { Mouse.hide(); }
		
		/* Progressbar progress change handler */
		private function progressBar_progressChangeHandler(e:ParamEvent):void
		{
			mediaPback.seek(e.params.progress);
		}
		
		/* Mouse events handler */
		private function mouseEventsHandler(e:MouseEvent):void
		{
			if (fileType == VIDEO || fileType == AUDIO)
			{
				switch(e.type)
				{
					case MouseEvent.ROLL_OVER: controls.show(); break;
					case MouseEvent.ROLL_OUT:
						if (!e.buttonDown) controls.hide();
						else stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
						break;
				}
			}
		}
		
		/* Stage mouse up handler */
		private function stage_mouseUpHandler(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			if (!isUnderMouse)
			{
				controls.hide();
				if (videoState == FULL_SCREEN)
				{
					cursorHideTimer.reset();
					cursorHideTimer.start();
				}
			}
		}
		
		/* Volume progress change handler */
		private function volumeSlider_progressChangeHandler(e:ParamEvent):void
		{
			mediaPback.volume = e.params.progress;
		}
		
		/**
		 * Run file
		 * @param	filePath	File path
		 * @param	fileType	File type
		 */
		public function run(path:URLRequest, type:String, settings:Object):void
		{
			filePath = path;
			fileType = type;
			
			allowZoom = false;
			initZoomed = false;
			
			switch(fileType)
			{
				case VIDEO:
					video.visible = true;
					controls.toVideo();
					Tweener.addTween(video, { alpha: 0 } );
					videoPback.autoPlay = settings.autoPlay;
					videoPback.repeat = settings.repeat;
					controls.volumeBtn.volumeSlider.slider.progress = settings.volume;
					videoPback.buffer = settings.buffer;
					videoPback.load(filePath.url);
					break;
					
				case AUDIO:
					controls.toAudio();
					audioPback.autoPlay = settings.autoPlay;
					audioPback.repeat = settings.repeat;
					controls.volumeBtn.volumeSlider.slider.progress = settings.volume;
					audioPback.buffer = settings.buffer;
					audioPback.load(filePath.url);
					albumArtLoader = destroyLoader(albumArtLoader, albumArtLoader_eventsHandler);
					albumArtLoader = createNewLoader(albumArtLoader_eventsHandler);
					albumArtPath = new URLRequest(settings.albumArt);
					albumArtLoader.load(albumArtPath);
					break;
					
				case IMAGE:
					allowZoom = settings.zoomPanning;
					initZoomed = settings.fullSize;
					imageLoader = destroyLoader(imageLoader, imageLoader_eventsHandler);
					imageLoader = createNewLoader(imageLoader_eventsHandler);
					imageLoader.load(filePath);
					break;
					
				case FLASH:
					allowZoom = settings.zoomPanning;
					initZoomed = settings.fullSize;
					swfLoader = destroyLoader(swfLoader, swfLoader_eventsHandler);
					swfLoader = createNewLoader(swfLoader_eventsHandler);
					swfLoader.load(filePath);
					break;
			}
			
			this.mouseEnabled = true;
			this.mouseChildren = true;
		}
		
		/* Create new image/swf loader */
		private function createNewLoader(eventsHandler:Function):Loader
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventsHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.INIT, eventsHandler, false, 0, true);
			return loader;
		}
		
		/* Destroy existing image/swf loader */
		private function destroyLoader(loader:Loader, eventsHandler:Function):Loader
		{
			if (loader)
			{
				try { loader.close(); } catch(error:Error) { }
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, eventsHandler);
				loader.contentLoaderInfo.removeEventListener(Event.INIT, eventsHandler);
				loader = null;
			}
			return loader;
		}
		
		/* Reset */
		public function reset():void
		{
			this.mouseEnabled = false;
			this.mouseChildren = false;
			filePath = null;
			fileType = null;
			albumArtPath = null;
			video.visible = false;
			videoPback.clear();
			audioPback.clear();
			visualisation.hide(true);
			imageLoader = destroyLoader(imageLoader, imageLoader_eventsHandler);
			swfLoader = destroyLoader(swfLoader, swfLoader_eventsHandler);
			albumArtLoader = destroyLoader(albumArtLoader, albumArtLoader_eventsHandler);
			zoomPanner.destroyContent();
		}
		
		/* Video load events */
		private function videoPback_loadEventsHandler(e:MediaLoadEvent):void
		{
			switch(e.type)
			{
				case MediaLoadEvent.LOAD_START:
					
					break;
					
				case MediaLoadEvent.LOAD_PROGRESS:
					controls.progressBar.loading = e.totalBytes > 0 ? e.loadedBytes / e.totalBytes : 0;
					break;
					
				case MediaLoadEvent.LOAD_COMPLETE:
					
					break;
			}
		}
		
		/* Video buffering events */
		private function videoPback_bufferingEventsHandler(e:MediaBufferingEvent):void
		{
			switch(e.type)
			{
				case MediaBufferingEvent.BUFFERING_START: 	showPreloader(); break;
				case MediaBufferingEvent.BUFFERING_END: 	hidePreloader(); break;
			}
		}
		
		/* Video playback events */
		private function videoPback_playbackEventsHandler(e:MediaPlaybackEvent):void
		{
			switch(e.type)
			{
				case MediaPlaybackEvent.PLAYBACK_READY:
					controls.fullscreenBtn.mouseEnabled = true;
					updateSizeInfo(videoPback.videoWidth, videoPback.videoHeight);
					Tweener.addTween(video, { alpha: 1, time: 0.3, transition: "easeoutquad" } );
					break;
					
				case MediaPlaybackEvent.PLAYBACK_START:
					controls.playBtn.visible = false;
					controls.pauseBtn.visible = true;
					break;
					
				case MediaPlaybackEvent.PLAYBACK_TIME_UPDATE:
					if (!controls.progressBar.mouseDrag) controls.progressBar.progress = e.totalTime > 0 ? e.currentTime / e.totalTime : 0;
					
					controls.timeDisplay.totalTime = e.totalTime;
					controls.timeDisplay.currentTime = e.currentTime;
					
					controls.progressBar.totalTime = e.totalTime;
					controls.progressBar.currentTime = e.currentTime;
					break;
				
				case MediaPlaybackEvent.PLAYBACK_STOP:
					controls.playBtn.visible = true;
					controls.pauseBtn.visible = false;
					break;
				
				case MediaPlaybackEvent.PLAYBACK_COMPLETE:
					
					break;
			}
		}
		
		/* Audio load events */
		private function audioPback_loadEventsHandler(e:MediaLoadEvent):void
		{
			switch(e.type)
			{
				case MediaLoadEvent.LOAD_START:
					
					break;
					
				case MediaLoadEvent.LOAD_PROGRESS:
					controls.progressBar.loading = e.totalBytes > 0 ? e.loadedBytes / e.totalBytes : 0;
					break;
					
				case MediaLoadEvent.LOAD_COMPLETE:
					
					break;
			}
		}
		
		/* Audio buffering events */
		private function audioPback_bufferingEventsHandler(e:MediaBufferingEvent):void
		{
			switch(e.type)
			{
				case MediaBufferingEvent.BUFFERING_START: showPreloader(); break;
				case MediaBufferingEvent.BUFFERING_END: if (!albumArtLoader) hidePreloader(); break;
			}
		}
		
		/* Audio playback events */
		private function audioPback_playbackEventsHandler(e:MediaPlaybackEvent):void
		{
			switch(e.type)
			{
				case MediaPlaybackEvent.PLAYBACK_READY:
					
					break;
					
				case MediaPlaybackEvent.PLAYBACK_START:
					controls.playBtn.visible = false;
					controls.pauseBtn.visible = true;
					break;
					
				case MediaPlaybackEvent.PLAYBACK_TIME_UPDATE:
					if (!controls.progressBar.mouseDrag) controls.progressBar.progress = e.totalTime > 0 ? e.currentTime / e.totalTime : 0;
					
					controls.timeDisplay.totalTime = e.totalTime;
					controls.timeDisplay.currentTime = e.currentTime;
					
					controls.progressBar.totalTime = e.totalTime;
					controls.progressBar.currentTime = e.currentTime;
					break;
				
				case MediaPlaybackEvent.PLAYBACK_STOP:
					controls.playBtn.visible = true;
					controls.pauseBtn.visible = false;
					break;
				
				case MediaPlaybackEvent.PLAYBACK_COMPLETE:
					
					break;
			}
		}
		
		/* Image loader events handler */
		private function imageLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR: trace("[IMAGE LOAD] " + ErrorEvent(e).text); break;
				case Event.INIT:
					hidePreloader();
					var w:Number = imageLoader.contentLoaderInfo.width;
					var h:Number = imageLoader.contentLoaderInfo.height;
					zoomPanner.addContent(imageLoader.content, w, h, allowZoom, initZoomed, true);
					updateSizeInfo(w, h);
					break;
			}
		}
		
		/* SWF loader events handler */
		private function swfLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR: trace("[SWF LOAD] " + ErrorEvent(e).text); break;
				case Event.INIT:
					hidePreloader();
					var w:Number = swfLoader.contentLoaderInfo.width;
					var h:Number = swfLoader.contentLoaderInfo.height;
					zoomPanner.addContent(swfLoader.content, w, h, allowZoom, initZoomed, false);
					updateSizeInfo(w, h);
					swfLoader = destroyLoader(swfLoader, swfLoader_eventsHandler);
					break;
			}
		}
		
		/* Album art loader events handler */
		private function albumArtLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR: trace("[ALBUM ART LOAD] " + ErrorEvent(e).text); break;
				case Event.INIT:
					if (!audioPback.buffering) hidePreloader();
					var w:Number = albumArtLoader.contentLoaderInfo.width;
					var h:Number = albumArtLoader.contentLoaderInfo.height;
					zoomPanner.addContent(albumArtLoader.content, w, h, allowZoom, initZoomed, true);
					updateSizeInfo(w, h);
					albumArtLoader = destroyLoader(albumArtLoader, albumArtLoader_eventsHandler);
					albumArtPath = null;
					break;
			}
		}
		
		/* Update size info */
		private function updateSizeInfo(newW:Number, newH:Number):void
		{
			origWidth = newW;
			origHeight = newH;
			ratio = origWidth / origHeight;
			dispatchEvent(new ParamEvent(SIZE_INFO, { mediaWidth: origWidth, mediaHeight: origHeight, mediaRatio: ratio } ));
		}
		
		/* Show preloader */
		public function showPreloader():void
		{
			if (preloaderState == PRELOADER_INVISIBLE)
			{
				preloaderState = PRELOADER_VISIBLE;
				Tweener.addTween(preloader, { alpha: 1, time: 0.6, transition: "easeinquad" } );
			}
		}
		
		/* Hide preloader */
		public function hidePreloader():void
		{
			if (preloaderState == PRELOADER_VISIBLE)
			{
				preloaderState = PRELOADER_INVISIBLE;
				Tweener.addTween(preloader, { alpha: 0, time: 0.1, transition: "easeoutquad" } );
			}
		}
		
		/* Is under mouse */
		public function get isUnderMouse():Boolean
		{
			return bgMc.hitTestPoint(stage.mouseX, stage.mouseY);
		}
		
		/* Get current media playback */
		public function get mediaPback():MediaPlayback
		{
			return fileType == VIDEO ? videoPback : audioPback;
		}
		
		/**
		 * Overrides
		 */
		override public function get width():Number { return rect.width; }
		override public function set width(value:Number):void
		{
			if (rect.width != value)
			{
				rect.width = value;
				rollOutZone.width = rect.width;
				bgMc.width = rect.width;
				videoBg.width = rect.width;
				video.width = rect.width;
				preloader.x = Math.round(rect.width * 0.5);
				zoomPanner.width = rect.width;
				visualisation.width = rect.width;
				controls.width = rect.width;
				this.scrollRect = rect;
			}
		}
		
		override public function get height():Number { return rect.height; }
		override public function set height(value:Number):void
		{
			if (rect.height != value)
			{
				rect.height = value;
				rollOutZone.height = rect.height - controls.triggerZoneHeight;
				bgMc.height = rect.height;
				videoBg.height = rect.height;
				video.height = rect.height;
				preloader.y = Math.round(rect.height * 0.5);
				zoomPanner.height = rect.height;
				visualisation.height = rect.height;
				controls.y = rect.height - controls.height;
				this.scrollRect = rect;
			}
		}
		
		override public function get x():Number { return super.x; }
		override public function set x(value:Number):void
		{
			super.x = value;
			rollOutZone.x = value;
		}
		
		override public function get y():Number { return super.y; }
		override public function set y(value:Number):void
		{
			super.y = value;
			if (rollOutZone) rollOutZone.y = value;
		}
		
		override public function destroy():void
		{
			reset();
			
			Tweener.removeTweens(video);
			Tweener.removeTweens(preloader);
			
			videoPback.removeEventListener(MediaLoadEvent.LOAD_START, videoPback_loadEventsHandler);
			videoPback.removeEventListener(MediaLoadEvent.LOAD_PROGRESS, videoPback_loadEventsHandler);
			videoPback.removeEventListener(MediaLoadEvent.LOAD_COMPLETE, videoPback_loadEventsHandler);
			videoPback.removeEventListener(MediaBufferingEvent.BUFFERING_START, videoPback_bufferingEventsHandler);
			videoPback.removeEventListener(MediaBufferingEvent.BUFFERING_END, videoPback_bufferingEventsHandler);
			videoPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_READY, videoPback_playbackEventsHandler);
			videoPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_START, videoPback_playbackEventsHandler);
			videoPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, videoPback_playbackEventsHandler);
			videoPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_STOP, videoPback_playbackEventsHandler);
			videoPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, videoPback_playbackEventsHandler);
			videoPback.destroy();
			videoPback = null;
			
			audioPback.removeEventListener(MediaLoadEvent.LOAD_START, audioPback_loadEventsHandler);
			audioPback.removeEventListener(MediaLoadEvent.LOAD_PROGRESS, audioPback_loadEventsHandler);
			audioPback.removeEventListener(MediaLoadEvent.LOAD_COMPLETE, audioPback_loadEventsHandler);
			audioPback.removeEventListener(MediaBufferingEvent.BUFFERING_START, audioPback_bufferingEventsHandler);
			audioPback.removeEventListener(MediaBufferingEvent.BUFFERING_END, audioPback_bufferingEventsHandler);
			audioPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_READY, audioPback_playbackEventsHandler);
			audioPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_START, audioPback_playbackEventsHandler);
			audioPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_TIME_UPDATE, audioPback_playbackEventsHandler);
			audioPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_STOP, audioPback_playbackEventsHandler);
			audioPback.removeEventListener(MediaPlaybackEvent.PLAYBACK_COMPLETE, audioPback_playbackEventsHandler);
			audioPback.destroy();
			audioPback = null;
			
			this.removeChild(preloader);
			preloader.destroy();
			
			filePath = null;
			fileType = null;
			rect = null;
			
			super.destroy();
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}
