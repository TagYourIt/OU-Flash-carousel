package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.LabelButton;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.app3DFramework.SimpleButton;
	import com.oxylusflash.app3DFramework.detailView.textBox.TextBox;
	import com.oxylusflash.app3DFramework.toolTip.ToolTip;
	import com.oxylusflash.app3DFramework.toolTip.ToolTipInfo;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.framework.util.StringUtil;
	import com.oxylusflash.framework.util.XMLUtil;
	import com.oxylusflash.utils.Resize;
	import com.oxylusflash.wall3D.Wall3DEnvironment;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class DetailBox extends DestroyableSprite
	{
		private static const EXIT_ACTION:int = 0;
		private static const NEXT_ACTION:int = 1;
		private static const PREV_ACTION:int = -1;
		
		public var bgMc:Sprite;
		private var detailView:DetailView;
		private var rightWrapper:Sprite = new Sprite;
		
		private var textBox:TextBox = new LibTextBox;
		private var viewZone:ViewZone = new LibViewZone;
		
		private var scrollBarHolder:ScrollBarHolder = new LibScrollBarHolder;
		
		private var closeBtn:LabelButton = new LibDetailBoxButton;
		private var purchaseBtn:LabelButton = new LibDetailBoxButton;
		private var downloadBtn:LabelButton = new LibDetailBoxButton;
		private var nextBtn:SimpleButton = new LibDetailBoxArrowButton;
		private var prevBtn:SimpleButton = new LibDetailBoxArrowButton;
		
		private var origMediaW:Number;
		private var origMediaH:Number;
		private var targMediaW:Number;
		private var targMediaH:Number;
		private var tempMediaH:Number;
		private var tempMediaW:Number;
		private var mediaRatio:Number;
		private var invMediaRatio:Number;
		private var targTextH:Number;
		private var tempTextH:Number;
		
		private var marginX:Number;
		private var marginY:Number;
		
		private var _data:XML;
		
		private var detailsLdr:URLLoader = new URLLoader;
		private var detailsXML:XML;
		
		private var purchaseLink:URLRequest;
		private var purchaseTarget:String;
		
		private var fileReference:FileReference = new FileReference;
		private var fileSource:URLRequest;
		private var downloadName:String;
		
		private var fileType:String;
		private var allowResize:Boolean = false;
		
		private var nextTipString:String;
		private var prevTipString:String;
		
		/* Detail view box */
		public function DetailBox()
		{
			this.filters = [new DropShadowFilter(0, 45, 0, 0.3, 8, 8, 1, 3)];
			
			this.addChildAt(rightWrapper, 0);
			this.addChild(textBox);
			this.addChild(viewZone);
			
			this.addChildAt(closeBtn, 0);
			this.addChildAt(purchaseBtn, 0);
			this.addChildAt(downloadBtn, 0);
			this.addChildAt(prevBtn, 0);
			rightWrapper.addChild(nextBtn);
			rightWrapper.addChild(scrollBarHolder);
			
			prevBtn.scaleX = -1;
			
			viewZone.addEventListener(ViewZone.SIZE_INFO, viewZone_sizeInfoHandler, false, 0, true);
			viewZone.init(this);
			
			detailsLdr.addEventListener(IOErrorEvent.IO_ERROR, detailsLdr_eventsHandler, false, 0, true);
			detailsLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, detailsLdr_eventsHandler, false, 0, true);
			detailsLdr.addEventListener(Event.COMPLETE, detailsLdr_eventsHandler, false, 0, true);
			
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileReference_eventsHandler, false, 0, true);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileReference_eventsHandler, false, 0, true);
		}
		
		/**
		 * Init
		 * @param	detailViewRef	Detail view reference
		 */
		public function init(detailViewRef:DetailView):void
		{
			detailView = detailViewRef;
			detailView.addEventListener(DetailView.BOUNDS_CHANGED, detailView_boundsChangeHandler, false, 0, true);
			
			marginX = nextBtn.width + settings.margin;
			marginY = closeBtn.height + settings.margin;
			
			viewZone.x = viewZone.y = settings.padding;
			viewZone.zoomPanner.init(mainApp);
			
			scrollBarHolder.init(settings.padding);
			
			textBox.init(settings.maxDescrHeight, scrollBarHolder.scrollBar);
			textBox.styleSheet = mainApp.styleSheet;
			textBox.x = settings.padding;
			
			closeBtn.label = settings.closeBtn;
			closeBtn.redrawMask(settings.topBtnsCorners_tl, settings.topBtnsCorners_tr, settings.topBtnsCorners_bl, settings.topBtnsCorners_br);
			closeBtn.height = settings.topBtnsHeight;
			closeBtn.addEventListener(SimpleButton.PRESS, buttons_pressHandler, false, 0, true);
			
			purchaseBtn.label = settings.purchaseBtn;
			purchaseBtn.redrawMask(settings.topBtnsCorners_tl, settings.topBtnsCorners_tr, settings.topBtnsCorners_bl, settings.topBtnsCorners_br);
			purchaseBtn.height = settings.topBtnsHeight;
			purchaseBtn.addEventListener(SimpleButton.PRESS, buttons_pressHandler, false, 0, true);
			
			downloadBtn.label = settings.downloadBtn;
			downloadBtn.redrawMask(settings.topBtnsCorners_tl, settings.topBtnsCorners_tr, settings.topBtnsCorners_bl, settings.topBtnsCorners_br);
			downloadBtn.height = settings.topBtnsHeight;
			downloadBtn.addEventListener(SimpleButton.PRESS, buttons_pressHandler, false, 0, true);
			
			nextBtn.redrawMask(settings.navBtnsCorners_tl, settings.navBtnsCorners_tr, settings.navBtnsCorners_bl, settings.navBtnsCorners_br);
			nextBtn.addEventListener(SimpleButton.PRESS, buttons_pressHandler, false, 0, true);
			nextBtn.addEventListener(MouseEvent.ROLL_OVER, buttons_rollHandler, false, 0, true);
			nextBtn.addEventListener(MouseEvent.ROLL_OUT, buttons_rollHandler, false, 0, true);
			nextBtn.addEventListener(MouseEvent.MOUSE_DOWN, buttons_rollHandler, false, 0, true);
			toolTips.detailsBox.nextBtn.item = nextBtn;
			
			prevBtn.redrawMask(settings.navBtnsCorners_tl, settings.navBtnsCorners_tr, settings.navBtnsCorners_bl, settings.navBtnsCorners_br);
			prevBtn.addEventListener(SimpleButton.PRESS, buttons_pressHandler, false, 0, true);
			prevBtn.addEventListener(MouseEvent.ROLL_OVER, buttons_rollHandler, false, 0, true);
			prevBtn.addEventListener(MouseEvent.ROLL_OUT, buttons_rollHandler, false, 0, true);
			prevBtn.addEventListener(MouseEvent.MOUSE_DOWN, buttons_rollHandler, false, 0, true);
			toolTips.detailsBox.prevBtn.item = prevBtn;
			
			nextTipString = toolTips.detailsBox.nextBtn.tipString;
			prevTipString = toolTips.detailsBox.prevBtn.tipString;
			
			positionOtherButtons();
			
			mainApp.tooltip.addItemTooltip(viewZone.controls.playBtn, mainApp.toolTips.playbackControls.playBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.pauseBtn, mainApp.toolTips.playbackControls.pauseBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.replayBtn, mainApp.toolTips.playbackControls.replayBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.fullscreenBtn, mainApp.toolTips.playbackControls.fullScreenBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.nscreenBtn, mainApp.toolTips.playbackControls.normalScreenBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.albumartBtn, mainApp.toolTips.playbackControls.albumartBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.osciloBtn, mainApp.toolTips.playbackControls.oscilloscopeBtn);
			mainApp.tooltip.addItemTooltip(viewZone.controls.spectrumBtn, mainApp.toolTips.playbackControls.spectrumBtn);
			
			reset();
		}
		
		/* Buttons roll over/out handler */
		private function buttons_rollHandler(e:MouseEvent):void
		{
			if (e.type == MouseEvent.ROLL_OVER)
			{
				if (!e.buttonDown)
				{
					var tipInfo:ToolTipInfo;
					switch(e.currentTarget)
					{
						case nextBtn:
							tipInfo = toolTips.detailsBox.nextBtn;
							tipInfo.tipString = nextTipString.replace(/%TITLE%/g, env3D.nextThumb3DData().title[0].text());
							break;
							
						case prevBtn:
							tipInfo = toolTips.detailsBox.prevBtn;
							tipInfo.tipString = prevTipString.replace(/%TITLE%/g, env3D.prevThumb3DData().title[0].text());
							break;
					}
					tooltip.show(tipInfo);
				}
			}
			else
			{
				tooltip.hide();
			}
		}
		
		/* File reference events handler */
		private function fileReference_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR: trace("[DOWNLOAD] " + ErrorEvent(e).text); break;
			}
		}
		
		/* Buttons click handler */
		private function buttons_pressHandler(e:Event):void
		{
			switch(e.currentTarget)
			{
				case purchaseBtn:
					try { navigateToURL(purchaseLink, purchaseTarget); }
					catch (error:Error) { trace("[PURCHASE] " + error.message); }
					break;
					
				case downloadBtn:
					try { fileReference.download(fileSource, downloadName); }
					catch (error:Error) { trace("[DOWNLOAD] " + error.message); }
					break;
					
				case closeBtn: 	allInAnimation(EXIT_ACTION); mainApp.startAutoPlay(); break;
				case nextBtn: 	allInAnimation(NEXT_ACTION); break;
				case prevBtn: 	allInAnimation(PREV_ACTION); break;
			}
		}
		
		/* Stop details xml load */
		private function stopCurrentDetailsLoad():void
		{
			try { detailsLdr.close(); }
			catch (error:Error) { }
		}
		
		/* Data */
		public function get data():XML { return _data; }
		public function set data(value:XML):void
		{
			reset();
			
			_data = value;
			viewZone.showPreloader();
			
			fileType = String(_data.type[0].text());
			
			purchaseBtn.visible = StringUtil.toBoolean(_data.purchase[0].text());
			downloadBtn.visible = StringUtil.toBoolean(_data.download[0].text());
			downloadBtn.mouseEnabled = false;
			purchaseBtn.mouseEnabled = false;
			downloadBtn.x = purchaseBtn.visible ? purchaseBtn.width + settings.topBtnsSpacingX : 0;
			
			stopCurrentDetailsLoad();
			detailsLdr.load(new URLRequest(_data.details[0].text()));
		}
		
		/* Details loader events handler */
		private function detailsLdr_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR: trace("[DETAILS XML] " + ErrorEvent(e).text); break;
				case Event.COMPLETE: onDetailsXMLLoad(); break;
			}
		}
		
		/* When details xml is loaded */
		private function onDetailsXMLLoad():void
		{
			detailsXML = new XML(detailsLdr.data);
			
			purchaseLink = new URLRequest(detailsXML.file[0].purchaseLink[0].text());
			purchaseTarget = detailsXML.file[0].purchaseLink[0].@target;
			
			fileSource = new URLRequest(detailsXML.file[0].source[0].text());
			downloadName = toFileName(_data.title[0].text()) + fileExtension(fileSource.url);
			
			textBox.text = detailsXML.file[0].description[0].text();
			
			downloadBtn.mouseEnabled = true;
			purchaseBtn.mouseEnabled = true;
		
			viewZone.run(fileSource, fileType, com.oxylusflash.framework.util.XMLUtil.toObject(detailsXML.settings[0]));
		}
		
		/* View zone size info handler */
		private function viewZone_sizeInfoHandler(e:ParamEvent):void
		{
			origMediaW = e.params.mediaWidth;
			origMediaH = e.params.mediaHeight;
			mediaRatio = e.params.mediaRatio;
			invMediaRatio = 1 / mediaRatio;
			
			allowResize = true;
			updateSize();
		}
		
		/* String to file name */
		private function toFileName(string:String):String
		{
			return string.replace(/\s/g, '_').replace(/[^a-z_0-9]*/gi, '').toLowerCase();
		}
		
		/* Get file extension */
		private function fileExtension(string:String):String
		{
			var i:int = string.length;
			var ext:String = '';
			var c:String;
			
			while (i--)
			{
				c = string.charAt(i).toLowerCase();
				if (c == '.') return '.' + ext;
				else ext = c + ext;
			}
			
			return '';
		}
		
		/* Reset size and aspect */
		public function reset():void
		{
			allowResize = false;
			stopCurrentDetailsLoad();
			
			viewZone.reset();
			textBox.text = '';
			
			targMediaW = origMediaW = settings.initWidth - 2 * settings.padding;
			targMediaH = origMediaH = settings.initHeight - 2 * settings.padding;
			targTextH = 0;
			
			resizeAnimation(true);
		}
		
		/* Calculate target media size */
		private function calcTargetMediaSize(boundsW:Number, boundsH:Number):void
		{
			tempMediaW = targMediaW;
			tempMediaH = targMediaH;
			
			if (origMediaW <= boundsW && origMediaH <= boundsH)
			{
				targMediaW = origMediaW;
				targMediaH = origMediaH;
			}
			else
			{
				var boundsRatio:Number = boundsW / boundsH;
				if (boundsRatio > mediaRatio)
				{
					targMediaW = Math.round(boundsH * mediaRatio);
					targMediaH = boundsH;
				}
				else
				{
					targMediaW = boundsW;
					targMediaH = Math.round(boundsW * invMediaRatio);
				}
			}
		}
		
		/* Calculate target sizes */
		private function calcTargetSize():void
		{
			if (allowResize)
			{
				var boundsW:Number = detailView.width - 2 * (marginX + settings.padding);
				var boundsH:Number = detailView.height - 2 * (marginY + settings.padding);
				
				calcTargetMediaSize(boundsW, boundsH);
				targTextH = 0;
				
				if (!textBox.isBlank)
				{
					do
					{
						tempTextH = targTextH;
						calcTargetMediaSize(boundsW, boundsH - (targTextH + settings.spacingY));
						if (textBox.textSprite.getAreaFor(targMediaW) < targMediaW * targTextH) break;
					}
					while (targTextH++ <= textBox.maxHeight);
					
					targMediaW = tempMediaW;
					targMediaH = tempMediaH;
					targTextH = tempTextH;
				}
			}
			
			targMediaW = int(targMediaW + 0.5);
			targMediaH = int(targMediaH + 0.5);
			targTextH = int(targTextH + 0.5);
		}
		
		/* Animated resize */
		private function updateSize(instant:Boolean = false):void
		{
			if (!allowResize) centerAlign();
			else
			{
				calcTargetSize();
				resizeAnimation(instant);
			}
		}
		
		/* Resize animation */
		private function resizeAnimation(instant:Boolean = false):void
		{
			Tweener.addTween(viewZone, { rounded: true, width: targMediaW, height: targMediaH, time: instant ? 0 : 0.3, transition: "easeoutquad" } );
			Tweener.addTween(textBox, { rounded: true, height: targTextH, time: instant ? 0 : 0.3, transition: "easeoutquad", onUpdate: resizeAnim_updateHandler, onComplete: resizeAnim_completeHandler } );
		}
		
		/* Resize animation update handler */
		private function resizeAnim_updateHandler():void
		{
			bgMc.width = viewZone.width + 2 * settings.padding;
			bgMc.height = viewZone.height + (textBox.height ? settings.spacingY + textBox.height : 0) + 2 * settings.padding;
			
			rightWrapper.x = bgMc.width;
			closeBtn.x = bgMc.width - closeBtn.width;
			nextBtn.y = prevBtn.y = Math.round((bgMc.height - (textBox.height ? textBox.height + settings.padding : 0) - nextBtn.height) * 0.5);
			
			textBox.width = viewZone.width;
			textBox.y = bgMc.height - settings.padding - textBox.height;
			
			scrollBarHolder.height = textBox.height + 2 * settings.padding;
			scrollBarHolder.y = bgMc.height - scrollBarHolder.height;
			
			centerAlign();
		}
		
		/* Resize animation complete handler */
		private function resizeAnim_completeHandler():void
		{
			var condition:Boolean = targTextH > 0 && scrollBarHolder.scrollBar.scrollBtnMc.visible;
			Tweener.addTween(scrollBarHolder, { x: condition ? 0 : -scrollBarHolder.width, time: 0.15, transition: "easeoutquad" } );
		}
		
		/* Center align box */
		public function centerAlign():void
		{
			if (detailView)
			{
				this.x = int((detailView.width - this.width) * 0.5);
				this.y = int((detailView.height - this.height) * 0.5);
			}
		}
		
		/* Detail view bounds change */
		private function detailView_boundsChangeHandler(e:Event):void
		{
			if (viewZone.videoState != ViewZone.FULL_SCREEN) updateSize(true);
		}
		
		/* Initial transition after box becomes visible, all elements go out */
		public function allOutAnimation():void
		{
			mainApp.interactive = true;
			Tweener.addTween(closeBtn, { y: -closeBtn.height, time: 0.3, delay: 0.15, transition: "easeInOutQuad", onUpdate: positionOtherButtons } );
		}
		
		/* All elements go in and we exit detail view */
		public function allInAnimation(action:int = 0):void
		{
			allowResize = false;
			mainApp.interactive = false;
			mainApp.overlay.hide();
			Tweener.addTween(closeBtn, { y: 0, time: 0.3, transition: "easeInOutQuad", onUpdate: positionOtherButtons, onComplete: allInTween_completeHandler, onCompleteParams: [action] } );
		}
		
		/* Update other top buttons in the same time with the close button */
		private function positionOtherButtons():void
		{
			var perc:Number = Math.abs(closeBtn.y / closeBtn.height);
			purchaseBtn.y = - perc * purchaseBtn.height;
			downloadBtn.y = - perc * downloadBtn.height;
			nextBtn.x = - (1 - perc) * nextBtn.width;
			prevBtn.x = (1 - perc) * prevBtn.width;
		}
		
		/* When all elements go in tween has completed */
		private function allInTween_completeHandler(action:int):void
		{
			switch(action)
			{
				case NEXT_ACTION:
					detailView.invisible = true;
					env3D.selectNextThumb3D();
					break;
					
				case PREV_ACTION:
					detailView.invisible = true;
					env3D.selectPrevThumb3D();
					break;
					
				case EXIT_ACTION:
					detailView.visible = false;
					mainApp.interactive = true;
					break;
			}
			reset();
		}
		
		/* Properties */
		public function get mainApp():MainApp3D { return detailView.mainApp; }
		public function get settings():Object 	{ return mainApp.settings.detailsBox; }
		public function get toolTips():Object 	{ return mainApp.toolTips; }
		public function get tooltip():ToolTip	{ return mainApp.tooltip; }
		public function get env3D():Wall3DEnvironment { return mainApp.env3D; }
		
		/* Overrides */
		override public function get width():Number { return bgMc.width; }
		override public function set width(value:Number):void { }
		
		override public function get height():Number { return bgMc.height; }
		override public function set height(value:Number):void { }
		
		override public function destroy():void
		{
			this.filters = null;
			
			Tweener.removeTweens(viewZone);
			Tweener.removeTweens(textBox);
			Tweener.removeTweens(scrollBarHolder);
			Tweener.removeTweens(closeBtn);
			
			stopCurrentDetailsLoad();
			detailsLdr.removeEventListener(IOErrorEvent.IO_ERROR, detailsLdr_eventsHandler);
			detailsLdr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, detailsLdr_eventsHandler);
			detailsLdr.removeEventListener(Event.COMPLETE, detailsLdr_eventsHandler);
			detailsLdr = null;
			detailsXML = null;
			
			detailView = null;
			
			nextTipString = prevTipString = null;
			
			this.removeChild(rightWrapper);
			rightWrapper = null;
		
			closeBtn.removeEventListener(SimpleButton.PRESS, buttons_pressHandler);
			closeBtn.destroy();
			closeBtn = null;
			
			purchaseBtn.removeEventListener(SimpleButton.PRESS, buttons_pressHandler);
			purchaseBtn.destroy();
			purchaseBtn = null;
			
			downloadBtn.removeEventListener(SimpleButton.PRESS, buttons_pressHandler);
			downloadBtn.destroy();
			downloadBtn = null;
			
			nextBtn.removeEventListener(SimpleButton.PRESS, buttons_pressHandler);
			nextBtn.removeEventListener(MouseEvent.ROLL_OVER, buttons_rollHandler);
			nextBtn.removeEventListener(MouseEvent.ROLL_OUT, buttons_rollHandler);
			nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN, buttons_rollHandler);
			nextBtn.destroy();
			nextBtn = null;
			
			prevBtn.removeEventListener(SimpleButton.PRESS, buttons_pressHandler);
			prevBtn.removeEventListener(MouseEvent.ROLL_OVER, buttons_rollHandler);
			prevBtn.removeEventListener(MouseEvent.ROLL_OUT, buttons_rollHandler);
			prevBtn.removeEventListener(MouseEvent.MOUSE_DOWN, buttons_rollHandler);
			prevBtn.destroy();
			prevBtn = null;
			
			fileReference.removeEventListener(IOErrorEvent.IO_ERROR, fileReference_eventsHandler);
			fileReference.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, fileReference_eventsHandler);
			fileReference = null;
			
			purchaseLink = null;
			purchaseTarget = null;
			fileSource = null;
			downloadName = null;
			
			textBox.destroy();
			textBox = null;
			
			viewZone.destroy();
			viewZone = null;

			fileType = null;
			
			super.destroy();
		}
		
	}

}
