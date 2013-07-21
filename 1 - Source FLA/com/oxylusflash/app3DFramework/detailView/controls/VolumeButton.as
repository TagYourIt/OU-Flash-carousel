package com.oxylusflash.app3DFramework.detailView.controls 
{
	import com.oxylusflash.app3DFramework.IconButton;
	import com.oxylusflash.events.ParamEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Volume slider
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class VolumeButton extends IconButton
	{
		public var volumeSlider:VolumeSlider;
		private var storedVolume:Number = 0;
		
		public function VolumeButton() 
		{
			this.buttonMode = false;
			this.mouseChildren = true;
			this.hitArea = null;
			
			bgMc.buttonMode = true;
			normalIcon.mouseEnabled = overIcon.mouseEnabled = false;
			
			bgMc.addEventListener(MouseEvent.CLICK, bgMc_clickHandler, false, 0, true);
			volumeSlider.slider.addEventListener(Slider.PROGRESS_CHANGE, slider_progressChange, false, 0, true);
		}
		
		/* Slide progress change hanlder */
		private function slider_progressChange(e:ParamEvent):void 
		{
			if (storedVolume > 0 && e.params.progress > 0) storedVolume = 0;
			updateLoudnessIcons();
		}
		
		/* Click handler (mute) */
		private function bgMc_clickHandler(e:MouseEvent):void 
		{
			if (storedVolume > 0)
			{
				volumeSlider.slider.progress = storedVolume;
				storedVolume = 0;	
			}
			else
			{
				storedVolume = volumeSlider.slider.progress;
				volumeSlider.slider.progress = 0;
			}
		}
		
		/* Update ludness icons */
		public function updateLoudnessIcons():void
		{
			LoudnessIcon(normalIcon).loudness = volumeSlider.slider.progress;
			LoudnessIcon(overIcon).loudness = volumeSlider.slider.progress;
		}
		
		/* Stage mouse up handler */
		private function stage_mouseUpHandler(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			if (!isUnderMouse) rollOutAction(false);
		}
		
		/* Overrides */
		override protected function rollOverAction(buttonDown:Boolean):void 
		{
			volumeSlider.show();
			super.rollOverAction(buttonDown);
		}
		
		override protected function rollOutAction(buttonDown:Boolean):void 
		{
			if (!buttonDown)
			{
				super.rollOutAction(false);
				volumeSlider.hide();
			}
			else
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
			}
		}

	}

}