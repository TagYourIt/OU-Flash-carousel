package com.oxylusflash.app3DFramework.detailView.controls 
{
	import flash.display.MovieClip;
	
	/**
	 * Loudness icon
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class LoudnessIcon extends MovieClip
	{
		private var _loudness:Number = 1;
		
		public function LoudnessIcon() 
		{
			this.stop();
		}
		
		/* Loudness */
		public function get loudness():Number { return _loudness; }		
		public function set loudness(value:Number):void 
		{
			if (_loudness != value)
			{
				_loudness = value;
				this.gotoAndStop(_loudness == 0 ? 3 : (_loudness <= 0.5 ? 2 : 1));
			}
		}
		
	}

}