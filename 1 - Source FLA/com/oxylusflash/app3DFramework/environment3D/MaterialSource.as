package com.oxylusflash.app3DFramework.environment3D
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MaterialSource extends DestroyableSprite
	{
		public static var UPDATE:String = "update";
		protected var _bitmap:BitmapData;
		
		/**
		 * Material source sprite.
		 * @param	bitmapW		Bitmap representation width.
		 * @param	bitmapH		Bitmap representation height.
		 */
		public function MaterialSource(bitmapW:Number = 100, bitmapH:Number = 100)
		{
			this.mouseChildren = this.mouseEnabled = false;
			_bitmap = new BitmapData(bitmapW, bitmapH, true, 0);
		}
		
		/**
		 * Update bitmap, fire update event.
		 */
		public function update():void
		{
			if (_bitmap)
			{
				_bitmap.lock();
				_bitmap.fillRect(_bitmap.rect, 0);
				_bitmap.draw(this);
				_bitmap.unlock();
				
				dispatchEvent(new Event(UPDATE));
			}
		}
		
		// Simulate roll over and out.
		public function simulateRollOver():void { update(); }
		public function simulateRollOut():void { update(); }
		
		/**
		 * Bitmap representation of the sprite.
		 */
		public function get bitmap():BitmapData { return _bitmap; }
		
		/**
		 * Destroy material source.
		 */
		override public function destroy():void
		{
			if (_bitmap)
			{
				_bitmap.dispose();
				_bitmap = null;
			}
			super.destroy();
		}
		
	}

}
