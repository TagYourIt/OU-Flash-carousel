package com.oxylusflash.app3DFramework.environment3D
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.Preloader;
	import com.oxylusflash.utils.Resize;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ThumbnailSource extends MaterialSource
	{
		public static const INTERACTION_READY:String = "interactionReady";
		
		private static const VIDEO:String = "video";
		private static const AUDIO:String = "audio";
		private static const FLASH:String = "flash";
		
		public var nBorder:Sprite;
		public var oBorder:Sprite;
		
		private var loaderAni:Preloader;
		private var iconMc:Sprite;
		
		private var thumbLoader:Loader = new Loader;
		private var thumbnailMc:Bitmap = new Bitmap;
		
		private var maxW:Number;
		private var maxH:Number;
		private var brdW:Number;
		private var showIcon:Boolean;
		
		private var _data:XML;
		
		/**
		 * Create thumbnail source.
		 * @param	itemData	XML data.
		 * @param	maxWidth	Maximum width.
		 * @param	maxHeight	Maximum height.
		 * @param	border		Border width.
		 */
		public function ThumbnailSource(itemData:XML, settings:Object)
		{
			super(settings.maxWidth, settings.maxHeight);
			
			_data = itemData;
			
			maxW = settings.maxWidth;
			maxH = settings.maxHeight;
			brdW = settings.border;
			showIcon = settings.showFileTypeIcon;
			
			oBorder.alpha = nBorder.alpha = thumbnailMc.alpha = 0;
			
			loaderAni = this.addChild(new LibPreloader) as Preloader;
			loaderAni.x = int(maxW * 0.5);
			loaderAni.y = int(maxH * 0.5);
			loaderAni.addEventListener(Preloader.UPDATE, loaderAni_updateHandler, false, 0, true);
			
			thumbLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, thumbLoader_eventsHandler, false, 0, true);
			thumbLoader.contentLoaderInfo.addEventListener(Event.INIT, thumbLoader_eventsHandler, false, 0, true);
			thumbLoader.load(new URLRequest(_data.thumbnail[0].text()));
			
			update();
		}
		
		/**
		 * Loader animation update handler.
		 */
		private function loaderAni_updateHandler(e:Event):void { update(); }
		
		/**
		 * Thumb loader events handler.
		 */
		private function thumbLoader_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
					trace(ErrorEvent(e).text);
					break;
					
				case Event.INIT:
					initAfterThumbnailLoad();
					break;
			}
			
			destroyThumbLoader();
		}
		
		/**
		 * Init thumbnail after image load.
		 */
		private function initAfterThumbnailLoad():void
		{
			loaderAni.removeEventListener(Preloader.UPDATE, loaderAni_updateHandler);
			
			this.addChild(thumbnailMc);
			thumbnailMc.bitmapData = new BitmapData(thumbLoader.contentLoaderInfo.width, thumbLoader.contentLoaderInfo.height, true, 0);
			thumbnailMc.bitmapData.draw(thumbLoader.content);
			
			var o:Object = Resize.getParams(maxW - 2 * brdW, maxH - 2 * brdW, thumbnailMc.width, thumbnailMc.height, brdW, brdW, Resize.RESIZE_TO_FIT);
			if (thumbnailMc.width != o.w || thumbnailMc.height != o.h) thumbnailMc.smoothing = true;
			
			thumbnailMc.x = o.x;
			thumbnailMc.y = o.y;
			thumbnailMc.width = o.w;
			thumbnailMc.height = o.h;
			
			nBorder.x = oBorder.x = o.x - brdW;
			nBorder.y = oBorder.y = o.y - brdW;
			nBorder.width = oBorder.width = o.w + 2 * brdW;
			nBorder.height = oBorder.height = o.h + 2 * brdW;
			
			var nBorderMsk:Sprite = this.addChild(new Sprite) as Sprite;
			nBorderMsk.x = nBorder.x;
			nBorderMsk.y = nBorder.y;
			nBorder.mask = nBorderMsk;
			drawFrame(nBorderMsk, nBorder, brdW);
			
			var oBorderMsk:Sprite = this.addChild(new Sprite) as Sprite;
			oBorderMsk.x = oBorder.x;
			oBorderMsk.y = oBorder.y;
			oBorder.mask = oBorderMsk;
			drawFrame(oBorderMsk, oBorder, brdW);
			
			if (showIcon)
			{
				switch(String(_data.type[0].text()).toLowerCase())
				{
					case VIDEO: iconMc = this.addChild(new LibVideoIcon) as Sprite; break;
					case AUDIO: iconMc = this.addChild(new LibAudioIcon) as Sprite; break;
					case FLASH: iconMc = this.addChild(new LibFlashIcon) as Sprite; break;
				}
				if (iconMc)
				{
					iconMc.x = loaderAni.x;
					iconMc.y = loaderAni.y;
					iconMc.alpha = 0;
				}
			}
			
			dispatchEvent(new Event(INTERACTION_READY));
			
			this.blendMode = BlendMode.LAYER;
			Tweener.addTween(nBorder, { alpha: 1, time: 0.3, transition: "easeInQuad", onUpdate: fadeUpdateHandler, onComplete: fadeCompleteHandler } );
		}
		
		/**
		 * Fade in update handler.
		 */
		private function fadeUpdateHandler():void
		{
			thumbnailMc.alpha = nBorder.alpha;
			loaderAni.alpha = 1 - nBorder.alpha;
			if (iconMc) iconMc.alpha = nBorder.alpha;
			
			update();
		}
		
		/**
		 * Fade in complete handler.
		 */
		private function fadeCompleteHandler():void
		{
			this.blendMode = BlendMode.NORMAL;
			
			if (loaderAni)
			{
				loaderAni.destroy();
				loaderAni = null;
			}
			
			update();
		}
		
		/**
		 * Draw mask frame.
		 * @param	maskRef		Make reference.
		 * @param	src			Source sprite.
		 * @param	b			Border width.
		 */
		private function drawFrame(maskRef:Sprite, src:Sprite, b:Number):void
		{
			var gfx:Graphics = maskRef.graphics;
			gfx.clear();
			gfx.beginFill(0);
			gfx.moveTo(0, 0);
			gfx.lineTo(src.width, 0);
			gfx.lineTo(src.width, src.height);
			gfx.lineTo(0, src.height);
			gfx.lineTo(0, 0);
			gfx.lineTo(b, b);
			gfx.lineTo(src.width - b, b);
			gfx.lineTo(src.width - b, src.height - b);
			gfx.lineTo(b, src.height - b);
			gfx.lineTo(b, b);
			gfx.endFill();
		}
		
		/**
		 * Destroy thumb loader.
		 */
		private function destroyThumbLoader():void
		{
			if (thumbLoader)
			{
				try { thumbLoader.close(); } catch (err:Error) {  }
				
				thumbLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, thumbLoader_eventsHandler);
				thumbLoader.contentLoaderInfo.removeEventListener(Event.INIT, thumbLoader_eventsHandler);
				thumbLoader = null;
			}
		}
		
		/**
		 * Overrides.
		 */
		override public function simulateRollOver():void
		{
			Tweener.addTween(oBorder, { alpha: 1, time: .3, transition: "easeOutQuad", onUpdate: update } );
		}
		
		override public function simulateRollOut():void
		{
			Tweener.addTween(oBorder, { alpha: 0, time: .3, transition: "easeOutQuad", onUpdate: update } );
		}
		
		override public function destroy():void
		{
			Tweener.removeTweens(nBorder);
			Tweener.removeTweens(oBorder);
			
			_data = null;
			
			destroyThumbLoader();
			nBorder.mask = oBorder.mask = null;
			if (Tweener.isTweening(oBorder)) Tweener.removeTweens(oBorder);
			
			if (loaderAni)
			{
				loaderAni.removeEventListener(Preloader.UPDATE, loaderAni_updateHandler);
				loaderAni.destroy();
				loaderAni = null;
			}
			
			if (thumbnailMc)
			{
				if (thumbnailMc.bitmapData) thumbnailMc.bitmapData.dispose();
				thumbnailMc.bitmapData = null;
				thumbnailMc = null;
			}
			
			super.destroy();
		}
		
		override public function get width():Number { return nBorder.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return nBorder.height; }
		override public function set height(value:Number):void { }
		
	}

}
