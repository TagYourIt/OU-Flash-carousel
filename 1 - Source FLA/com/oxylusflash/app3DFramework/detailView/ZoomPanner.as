package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.app3DFramework.toolTip.ToolTip;
	import com.oxylusflash.app3DFramework.toolTip.ToolTipInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ZoomPanner extends DestroyableSprite
	{
		private var rect:Rectangle = new Rectangle;
		
		private var allowZoom:Boolean = false;
		private var initZoomed:Boolean = false;
		private var zoomed:Boolean = false;
		
		private var swfHolder:DestroyableSprite;
		private var bitmap:Bitmap;
		private var container:DestroyableSprite;
		private var origContW:Number;
		private var origContH:Number;
		
		private var panXPerc:Number;
		private var panYPerc:Number;
		
		private var mainApp3D:MainApp3D;
		private var tips:Object;
		
		public function ZoomPanner()
		{
			this.scrollRect = rect;
		}
		
		/* Init zoomPanner */
		public function init(mainApp3DRef:MainApp3D):void
		{
			mainApp3D = mainApp3DRef;
			tips = mainApp3D.toolTips.detailsBox;
		}
		
		/**
		 * Add content
		 * @param	content		Content to be added
		 * @param	contentW	Content width
		 * @param	contentH	Content height
		 * @param	canZoom		Allow content zoom
		 * @param	initZoomed	Content is initially zoomed
		 * @param	asBitmap	Content is bitmap
		 */
		public function addContent(content:DisplayObject, contentW:Number, contentH:Number, canZoom:Boolean, initZoomed:Boolean, asBitmap:Boolean = false):void
		{
			this.alpha = 0;
			
			content.scrollRect = new Rectangle(0, 0, contentW, contentH);
			origContW = contentW;
			origContH = contentH;
			
			destroyContent();
			container = new DestroyableSprite();
			this.addChild(container);
			
			if (asBitmap)
			{
				var bd:BitmapData = new BitmapData(origContW, origContH, true, 0);
				bd.draw(content);
				bitmap = new Bitmap(bd);
				container.addChild(bitmap);
			}
			else
			{
				swfHolder = new DestroyableSprite();
				swfHolder.addChild(content);
				container.addChild(swfHolder);
				swfHolder.doubleClickEnabled = canZoom;
			}
			
			this.doubleClickEnabled = allowZoom = canZoom;
			container.doubleClickEnabled = allowZoom;
			zoomed = allowZoom && initZoomed;
			
			if (zoomed)
			{
				panXPerc = panYPerc = 0.5;
				container.x = (this.width - origContW) * 0.5;
				container.y = (this.height - origContH) * 0.5;
				addMouseMoveEventListener();
			}
			else
			{
				panXPerc = panYPerc = 0;
				container.width = this.width;
				container.height = this.height;
			}
			
			updateBitmapSmoothing();
			
			if (allowZoom)
			{
				this.addEventListener(MouseEvent.DOUBLE_CLICK, eventsHandler, false, 0, true);
				this.addEventListener(MouseEvent.MOUSE_DOWN, eventsHandler, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OVER, eventsHandler, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OUT, eventsHandler, false, 0, true);
			}
			
			Tweener.addTween(this, { alpha: 1, time: .3, transition: "easeoutquad" } );
		}
		
		/* Update pan percents */
		private function updatePanPercents():void
		{
			panXPerc = this.mouseX / rect.width;
			panXPerc = panXPerc < 0 ? 0 : (panXPerc > 1 ? 1 : panXPerc);
			panYPerc = this.mouseY / rect.height;
			panYPerc = panYPerc < 0 ? 0 : (panYPerc > 1 ? 1 : panYPerc);
		}
		
		/* Events handler */
		private function eventsHandler(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.DOUBLE_CLICK: toggleZoom(); break;
				case MouseEvent.MOUSE_MOVE: pan(); break;
				
				case MouseEvent.ROLL_OVER:
					if (mainApp3D) mainApp3D.tooltip.show(zoomed ? tips.zoomOut : tips.zoomIn);
					break;
					
				case MouseEvent.MOUSE_DOWN:
				case MouseEvent.ROLL_OUT:
					if (mainApp3D) mainApp3D.tooltip.hide();
					break;
			}
		}
		
		/* Toggle zoom */
		private function toggleZoom():void
		{
			if (zoomed)
			{
				this.removeEventListener(MouseEvent.MOUSE_MOVE, eventsHandler);
				panXPerc = panYPerc = 0;
				Tweener.addTween(container, { x: 0, y: 0, width: this.width, height: this.height, time: 0.3, transition: "easeoutquad", onUpdate: updateBitmapSmoothing } );
				zoomed = false;
			}
			else
			{
				updatePanPercents();
				Tweener.addTween(container, { width: origContW, height: origContH, time: 0.3, transition: "easeoutquad", onUpdate: onContainerSizeUpdate, onComplete: addMouseMoveEventListener } );
				zoomed = true;
			}
			dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
		}
		
		/* On container size update */
		private function onContainerSizeUpdate():void
		{
			pan(true, false);
			updateBitmapSmoothing();
		}
		
		/* Update bitmap smoothing */
		private function updateBitmapSmoothing():void
		{
			if (bitmap)
			{
				bitmap.smoothing = container.width != origContW || container.height != origContH;
			}
		}
		
		/* Add mouse move event handler */
		private function addMouseMoveEventListener():void
		{
			this.addEventListener(MouseEvent.MOUSE_MOVE, eventsHandler, false, 0, true);
		}
		
		/**
		 * Pan container
		 * @param	instant 		If false, animated pan
		 * @param	percentsUpdate	Update percents before panning ?
		 */
		private function pan(instant:Boolean = false, percentsUpdate:Boolean = true):void
		{
			if (percentsUpdate) updatePanPercents();
			
			var containerX:Number = (this.width - container.width) * panXPerc;
			var containerY:Number = (this.height - container.height) * panYPerc;
			
			if (instant)
			{
				container.x = containerX;
				container.y = containerY;
			}
			else
			{
				Tweener.addTween(container, { x: containerX, y: containerY, time: 0.3, transition: "easeoutquad" } );
			}
		}
		
		/* On component width or height change */
		private function onSizeChange():void
		{
			if (container)
			{
				if (Tweener.isTweening(container)) Tweener.removeTweens(container);
				if (zoomed)
				{
					pan(true, false);
				}
				else
				{
					container.width = this.width;
					container.height = this.height;
					updateBitmapSmoothing();
				}
			}
		}
		
		/* Destroy content */
		public function destroyContent():void
		{
			this.removeEventListener(MouseEvent.DOUBLE_CLICK, eventsHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, eventsHandler);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, eventsHandler);
			this.removeEventListener(MouseEvent.ROLL_OVER, eventsHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT, eventsHandler);
			
			destroySwfHolder();
			destroyBitmap();
			
			if (container) { container.destroy(); container = null; }
		}
		
		/* Destroy swf holder */
		private function destroySwfHolder():void
		{
			if (swfHolder)
			{
				while (swfHolder.numChildren) swfHolder.removeChildAt(0);
				swfHolder.destroy();
				swfHolder = null;
			}
		}
		
		/* Destroy bitmap */
		private function destroyBitmap():void
		{
			if (bitmap)
			{
				bitmap.bitmapData.dispose();
				if (bitmap.parent) bitmap.parent.removeChild(bitmap);
				bitmap = null;
			}
		}
		
		/* Overrides */
		override public function get width():Number { return rect.width; }
		override public function set width(value:Number):void
		{
			if (rect.width != value)
			{
				rect.width = value;
				this.scrollRect = rect;
				onSizeChange();
			}
		}
		
		override public function get height():Number { return rect.height; }
		override public function set height(value:Number):void
		{
			if (rect.height != value)
			{
				rect.height = value;
				this.scrollRect = rect;
				onSizeChange();
			}
		}
		
		override public function destroy():void
		{
			this.scrollRect = null;
			rect = null;
			
			mainApp3D = null;
			tips = null;
			destroyContent();
			
			super.destroy();
		}
		
	}

}
