package com.oxylusflash.app3DFramework.detailView 
{
	import flash.media.Video;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class VideoX extends Video
	{
		public function VideoX() { }
		
		/* Update video smoothing */
		private function updateSmoothing():void
		{
			this.smoothing = this.width != this.videoWidth || this.height != this.videoHeight;
		}
		
		/* Overrides */
		override public function get width():Number { return super.width; }		
		override public function set width(value:Number):void 
		{
			super.width = value;
			updateSmoothing();
		}
		
		override public function get height():Number { return super.height; }		
		override public function set height(value:Number):void 
		{
			super.height = value;
			updateSmoothing();
		}
		
	}

}