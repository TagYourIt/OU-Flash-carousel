package com.oxylusflash.wall3D
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.environment3D.Environment3D;
	import com.oxylusflash.app3DFramework.environment3D.Reflection3D;
	import com.oxylusflash.app3DFramework.environment3D.Thumbnail3D;
	import com.oxylusflash.app3DFramework.environment3D.ThumbsWrapper3D;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.NumberUtil;
	import com.oxylusflash.utils.XMLUtil;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import org.papervision3d.core.math.Matrix3D;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Wall3DEnvironment extends Environment3D
	{
		private static const TN_ANIM_TIME:Number = 0.25;
		private static const ROTATE_TIME:Number = 0.4;
		
		public var thumbsWrapper:ThumbsWrapper3D;
		private var selectedTn3D:Thumbnail3D;
		
		private var initData:XML;
		private var initPercentage:Number = 0;
		
		private var wl3DSettings:Object;
		private var reflSettings:Object;
		
		private var radius:Number;
		private var numItems:int;
		private var count:int;
		private var itemsList:XMLList;
		private var sliceAngle:Number;
		private var tnOffsetY:Number = 0;
		private var rowNumItems:Number;
		private var halfNumRows:Number;
		
		private var autoPlayResumeTimer:Timer;
		private var autoPlayWasRunning:Boolean = false;
		
		private var selectedTn3DProps:Object;
		private var M3D:Matrix3D = Matrix3D.IDENTITY;
		
		/**
		 * Wall environment.
		 */
		public function Wall3DEnvironment(pMainApp:MainApp3D)
		{
			super(pMainApp);
		}
		
		/**
		 * Init wall.
		 */
		public function init():void
		{
			thumbsWrapper = new ThumbsWrapper3D(this);
			scene.addChild(thumbsWrapper);
			
			thumbsWrapper.addEventListener(ThumbsWrapper3D.THUMBNAIL_PRESS, thumbsWrapper_eventsHandler, false, 0, true);
			
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, mmh);
			
			if (mainApp.settings.autoPlay.pauseOnMouseOver)
			{
				autoPlayResumeTimer = new Timer(Math.max(0.1, mainApp.settings.autoPlay.resumeAfter * 1000), 1);
				autoPlayResumeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, autoPlayResumeTimer_timerCompleteHandler, false, 0, true);
				
				thumbsWrapper.addEventListener(ThumbsWrapper3D.THUMBNAIL_ROLL_OVER, thumbsWrapper_eventsHandler, false, 0, true);
				thumbsWrapper.addEventListener(ThumbsWrapper3D.THUMBNAIL_ROLL_OUT, thumbsWrapper_eventsHandler, false, 0, true);
				
				mainApp.addEventListener(MainApp3D.AUTO_PLAY_USER_INPUT, mainApp_eventsHandler, false, 0, true);
			}
			
			if (initData)
			{
				populate(initData);
				initData = null;
			}

			if (initPercentage > 0)
			{
				percentageInput(initPercentage, true);
				initPercentage = 0;
			}
		}
		
		/* Clear thumbs */
		public function clear():void
		{
			if (thumbsWrapper)
			{
				thumbsWrapper.destroyThumbnails();
				thumbsWrapper.rotationY = 0;
				thumbsWrapper.localRotationY = 0;
			}
			
			selectedTn3D = null;
			selectedTn3DProps = null;
		}
		
		/*private function mmh(e:MouseEvent):void
		{
			var w_2:Number = w * 0.5;
			var h_2:Number = h * 0.5;
			
			var xPer:Number = (stage.mouseX - w_2) / w_2;
			var yPer:Number = (stage.mouseY - h_2) / h_2;
			
			thumbsWrapper.rotationX = -yPer * 15;
			
			render();
		}*/
		
		/**
		 * Main app events handler.
		 */
		private function mainApp_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case MainApp3D.AUTO_PLAY_USER_INPUT:
					autoPlayResumeTimer.reset();
					break;
			}
		}
		
		/**
		 * Auto play resume timer complete handler.
		 */
		private function autoPlayResumeTimer_timerCompleteHandler(e:TimerEvent):void
		{
			mainApp.startAutoPlay();
		}
		
		/**
		 * Populate wall.
		 * @param	xmlData		XML data.
		 */
		public function populate(xmlData:XML):void
		{
			wl3DSettings = com.oxylusflash.utils.XMLUtil.getParams(xmlData.settings[0].wall3D[0]);
			tn3DSettings = com.oxylusflash.utils.XMLUtil.getParams(xmlData.settings[0].thumb3D[0]);
			reflSettings = com.oxylusflash.utils.XMLUtil.getParams(xmlData.settings[0].reflections[0]);
			
			if (thumbsWrapper)
			{
				tnOffsetY = tn3DSettings.maxHeight + tn3DSettings.spacingY;
				
				itemsList = xmlData.items[0].item;
				numItems = itemsList.length() + wl3DSettings.ghostItems;
				
				if (numItems > 0)
				{
					count = 0;
					
					rowNumItems = Math.ceil(numItems / wl3DSettings.numRows);
					halfNumRows = (wl3DSettings.numRows - 1) * 0.5;
					
					mainApp.scrollBar.proportion = 1 / rowNumItems;
					mainApp.scrollBar.percentage = (wl3DSettings.initRotationY % 360) / 360;
					mainApp.scrollBar.stepPercentage = wl3DSettings.jumpNumColumns * mainApp.scrollBar.proportion;
					
					radius = (rowNumItems * (tn3DSettings.maxWidth + tn3DSettings.spacingX) - tn3DSettings.spacingX)  / (2 * Math.PI);
					M3D.n34 = - radius * (1 - Math.min(tn3DSettings.maxWidth / mainApp.settings.detailsBox.initWidth, tn3DSettings.maxHeight / mainApp.settings.detailsBox.initHeight));
					sliceAngle = 360 / rowNumItems;
					
					var n:int = numItems - wl3DSettings.ghostItems;
					for (; count < n ; ++count) addThumbnail();
					thumbsWrapper.connectFirstAndLastThumbs();
					
					camera.z = -radius;
					camera.focus = Math.abs(camera.z / camera.zoom);
					
					thumbsWrapper.x = wl3DSettings.offsetX;
					thumbsWrapper.y = -wl3DSettings.offsetY;
					thumbsWrapper.z = camera.z + Math.max(0, Math.min(radius, wl3DSettings.offsetZ));
					
					thumbsWrapper.rotationX = wl3DSettings.rotationOffsetX;
					thumbsWrapper.rotationZ = wl3DSettings.rotationOffsetZ;
					rotateThumbsWrapper(wl3DSettings.initRotationY, true, true);
					
					if (wl3DSettings.autoPlay) mainApp.startAutoPlay();
					
					render();
				}
				
				itemsList = null;
			}
			else
			{
				initData = xmlData;
			}
		}
		
		/**
		 * Add thumbnail.
		 */
		private function addThumbnail():void
		{
			var itemData:XML = itemsList[count];
			var angleDeg:Number = wl3DSettings.rotationOffsetY + count * sliceAngle;
			var angleRad:Number = angleDeg * RADIAN;
			var rowOffset:Number = halfNumRows - Math.floor(count / rowNumItems);
			
			var tn3D:Thumbnail3D = thumbsWrapper.addThumbnail3D(itemData);
			tn3D.extraInfo.angle = angleDeg;
			tn3D.x = Math.round(Math.sin(angleRad) * radius);
			tn3D.y = rowOffset * tnOffsetY;
			tn3D.z = Math.round(Math.cos(angleRad) * radius);
			tn3D.rotationY = (180 + angleDeg) % 360;
			
			if (halfNumRows + rowOffset == 0 && reflSettings.visible)
			{
				tn3D.reflection3D = thumbsWrapper.addReflection3D(tn3D, reflSettings);
				tn3D.reflection3D.x = tn3D.x;
				tn3D.reflection3D.y = (rowOffset - 1) * tnOffsetY + tn3DSettings.spacingY - reflSettings.distance;
				tn3D.reflection3D.z = tn3D.z;
				tn3D.reflection3D.rotationY = tn3D.rotationY + 180;
			}
		}
		
		/**
		 * Thumbnail click handler.
		 */
		private function thumbsWrapper_eventsHandler(e:Event):void
		{
			switch(e.type)
			{
				case ThumbsWrapper3D.THUMBNAIL_PRESS:
					var params:Object = ParamEvent(e).params;
					
					mainApp.interactive = false;
					
					
					mainApp.stopAutoPlay();
					autoPlayWasRunning = false;
					
					var rowChanged:Boolean = selectedTn3D != null;
					var aniDelay:Number = rowChanged ? TN_ANIM_TIME + 0.1 : 0;
					var prevTnY:Number = rowChanged ? selectedTn3D.y : 0;
					
					selectedTn3DReset();
					
					selectedTn3D = Thumbnail3D(params.tn3DRef);
					var toRotationY:Number = thumbsWrapper.localRotationY;
					
					var inView:Boolean = thumbIsInView(selectedTn3D);
					selectedTn3DProps = { x: selectedTn3D.x, y: selectedTn3D.y, z: selectedTn3D.z, rotationY: selectedTn3D.rotationY };
					
					var tempRotY:Number = thumbsWrapper.localRotationY;
					if (!inView)
					{
						thumbsWrapper.localRotationY = (360 + int(selectedTn3D.extraInfo.angle) % 360) % 360;
						thumbsWrapper.render();
					}
					
					var mat3D:Matrix3D = Matrix3D.multiply(Matrix3D.inverse(thumbsWrapper.world), M3D);
					
					if (!inView)
					{
						thumbsWrapper.localRotationY = tempRotY;
						thumbsWrapper.render();
					}
					
					if (!inView)
					{
						aniDelay += ROTATE_TIME;
						rotateThumbsWrapper(selectedTn3D.extraInfo.angle, false, false, true);
						toRotationY = selectedTn3D.extraInfo.angle;
					}
					
					selectedTn3D.rotationY %= 360;
					toRotationY %= 360;
					if (selectedTn3D.rotationY * toRotationY < 0)
					{
						toRotationY = ((selectedTn3D.rotationY < 0) ? ((toRotationY) % 360 - 360) : (360 + (toRotationY) % 360)) % 360;
					}
					
					animateThumb3D(selectedTn3D, { x: mat3D.n14, y: mat3D.n24, z: mat3D.n34, rotationY: toRotationY }, true, aniDelay);
					break;
					
				case ThumbsWrapper3D.THUMBNAIL_ROLL_OVER:
					if (autoPlayResumeTimer.running) autoPlayResumeTimer.reset();
					else autoPlayWasRunning = mainApp.autoPlayRunning();
					
					if (autoPlayWasRunning) mainApp.stopAutoPlay();
					break;
					
				case ThumbsWrapper3D.THUMBNAIL_ROLL_OUT:
					if (autoPlayWasRunning)
					{
						if (autoPlayResumeTimer.delay > 0.1) autoPlayResumeTimer.start();
						else mainApp.startAutoPlay();
					}
					break;
			}
		}
		
		/**
		 * Check if thumbnail 3d is entirely in view
		 * @param	thumb3DRef	Thumbnail 3D reference
		 */
		private function thumbIsInView(thumb3DRef:Thumbnail3D):Boolean
		{
			var tnBounds:Rectangle = thumb3DRef.layer.getBounds(mainApp);
			var appBounds:Rectangle = new Rectangle(0, 0, mainApp.width, mainApp.height);
			return appBounds.containsRect(tnBounds);
		}
		
		/**
		 * Reset position/rotation of the select thumbnail
		 */
		public function selectedTn3DReset():void
		{
			if (selectedTn3D)
			{
				animateThumb3D(selectedTn3D, selectedTn3DProps, false);
				selectedTn3D = null;
				selectedTn3DProps = null;
			}
		}
		
		/**
		 * Animate thumbnail 3D
		 * @param	thumb3DRef			Thumbnail 3D reference
		 * @param	tweenProps			Properties to tween
		 * @param	goesToFront			Thumbnail goes to front
		 */
		private function animateThumb3D(thumb3DRef:Thumbnail3D, tweenProps:Object, goesToFront:Boolean = true, delay:Number = 0):void
		{
			if (!goesToFront) thumb3DRef.visible = true;
			
			var tweenParams:Object = { base: tweenProps, time: TN_ANIM_TIME, delay: delay, transition: "easeInQuad" };
			
			tweenParams.onStart = animateThumb3DTween_startHandler;
			tweenParams.onStartParams = [thumb3DRef, goesToFront];
			
			tweenParams.onUpdate = animateThumb3DTween_updateHandler;
			tweenParams.onUpdateParams = tweenParams.onStartParams;
			
			tweenParams.onComplete = animateThumb3DTween_completeHandler;
			tweenParams.onCompleteParams = tweenParams.onStartParams;
			
			Tweener.addTween(thumb3DRef, tweenParams);
			
		}
		
		/**
		 * On animation start
		 */
		private function animateThumb3DTween_startHandler(thumb3DRef:Thumbnail3D, goesToFront:Boolean):void
		{
			if (goesToFront)
			{
				MainApp3D.soundsController.playSound("flip");
				if (thumb3DRef.reflection3D)
				{
					thumb3DRef.reflection3D.visible = false;
					thumb3DRef.reflection3D.render();
				}
			}
		}
		
		/**
		 * On animation update
		 */
		private function animateThumb3DTween_updateHandler(thumb3DRef:Thumbnail3D, goesToFront:Boolean):void
		{
			thumb3DRef.render();
		}
		
		/**
		 * On animation complete
		 */
		private function animateThumb3DTween_completeHandler(thumb3DRef:Thumbnail3D, isInFront:Boolean):void
		{
			if (isInFront)
			{
				thumb3DRef.visible = false;
				thumb3DRef.render();
				outputData(thumb3DRef.data);
			}
			else
			{
				if (thumb3DRef.reflection3D)
				{
					thumb3DRef.reflection3D.visible = true;
					thumb3DRef.reflection3D.render();
				}
			}
		}
		
		/**
		 * Select next thumbnail 3D
		 */
		public function selectNextThumb3D():void
		{
			if (selectedTn3D && selectedTn3D.extraInfo.nextTn3D)
			{
				Thumbnail3D(selectedTn3D.extraInfo.nextTn3D).simulateClick();
			}
		}
		
		/**
		 * Select prev thumbnail 3D
		 */
		public function selectPrevThumb3D():void
		{
			if (selectedTn3D && selectedTn3D.extraInfo.prevTn3D)
			{
				Thumbnail3D(selectedTn3D.extraInfo.prevTn3D).simulateClick();
			}
		}
		
		/**
		 * Next data
		 */
		public function nextThumb3DData():XML
		{
			if (selectedTn3D) return Thumbnail3D(selectedTn3D.extraInfo.nextTn3D).data;
			return <data/>;
		}
		
		/**
		 * Prev data
		 */
		public function prevThumb3DData():XML
		{
			if (selectedTn3D) return Thumbnail3D(selectedTn3D.extraInfo.prevTn3D).data;
			return <data/>;
		}
		
		/**
		 * Scrollbar percentage input.
		 */
		public function percentageInput(percentage:Number, instantEffect:Boolean = false):void
		{
			if (thumbsWrapper)
			{
				thumbsWrapper.localRotationY = (360 + int(thumbsWrapper.localRotationY) % 360) % 360;
				var rotY:Number = int(360 * percentage);
					
				if (rotY != thumbsWrapper.localRotationY)
				{
					var distFwd:Number;
					var distBwd:Number;
					
					if (rotY > thumbsWrapper.localRotationY)
					{
						distFwd = rotY - thumbsWrapper.localRotationY;
						distBwd = 360 - distFwd;
					}
					else
					{
						distBwd = thumbsWrapper.localRotationY - rotY;
						distFwd = 360 - distBwd;
					}
					
					if (distFwd < distBwd) rotY = thumbsWrapper.localRotationY + distFwd;
					else rotY = thumbsWrapper.localRotationY - distBwd;
				
					rotateThumbsWrapper(rotY, instantEffect);
				}
			}
			else
			{
				initPercentage = percentage;
			}
		}
		
		/**
		 * Rotate thumbs wrapper.
		 * @param	to			To rotation y.
		 * @param	instant		Instant or animated.
		 */
		private function rotateThumbsWrapper(to:Number, instant:Boolean = false, noRender:Boolean = false, updateScrollbar:Boolean = false):void
		{
			Tweener.addTween(thumbsWrapper, { localRotationY: to, time: instant ? 0 : ROTATE_TIME, transition: "easeOutQuad", onUpdate: noRender ? null : render } );
			if (updateScrollbar) mainApp.scrollBar.percentage = ((360 + (to % 360)) % 360) / 360;
		}
		
		/**
		 * Normalize rotation angle
		 * @param	value	Angle
		 * @return	Normalized rotation angle
		 */
		private function normRotation(value:Number):Number
		{
			return ((360 + (value % 360)) % 360) / 360;
		}
		
		/**
		 * Destroy.
		 */
		override public function destroy():void
		{
			mainApp.removeEventListener(MainApp3D.AUTO_PLAY_USER_INPUT, mainApp_eventsHandler);
			
			thumbsWrapper.removeEventListener(ThumbsWrapper3D.THUMBNAIL_PRESS, thumbsWrapper_eventsHandler);
			thumbsWrapper.layer.removeEventListener(ThumbsWrapper3D.THUMBNAIL_ROLL_OVER, thumbsWrapper_eventsHandler);
			thumbsWrapper.layer.removeEventListener(ThumbsWrapper3D.THUMBNAIL_ROLL_OUT, thumbsWrapper_eventsHandler);
			
			thumbsWrapper.destroy();
			thumbsWrapper = null;
			
			if (autoPlayResumeTimer)
			{
				autoPlayResumeTimer.reset();
				autoPlayResumeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, autoPlayResumeTimer_timerCompleteHandler);
				autoPlayResumeTimer = null;
			}
			
			super.destroy();
		}
		
	}

}
