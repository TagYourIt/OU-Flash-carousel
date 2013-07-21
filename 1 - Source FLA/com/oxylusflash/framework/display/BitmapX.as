package com.oxylusflash.framework.display 
{
	import com.oxylusflash.framework.core.IDestructible;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * Bitmap extended
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class BitmapX extends Bitmap implements IDestructible
	{
		private var _destroyed:Boolean = false;
		
		/* Bitmap extended */
		public function BitmapX(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false) 
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/* Destroy object */
		public function destroy():void 
		{ 
			if (this.parent) this.parent.removeChild(this);
			_destroyed = true; 
		}
		
		/* Check if object is destroyed */
		public function get destroyed():Boolean { return _destroyed; }
		
	}

}