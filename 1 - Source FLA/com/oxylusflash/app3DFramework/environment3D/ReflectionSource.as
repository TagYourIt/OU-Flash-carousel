package com.oxylusflash.app3DFramework.environment3D 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ReflectionSource extends MaterialSource
	{
		private var reflMask:ReflectionMask = new LibReflectionMask;
		private var reflBmp:Bitmap = new Bitmap;
		
		/**
		 * Reflection material source.
		 * @param	sourceBitmap	Source bitmap data.
		 * @param	pAlpha			Reflection alpha.
		 * @param	dropOff			Reflection drop off.
		 */
		public function ReflectionSource(sourceBitmap:BitmapData, pAlpha:Number, dropOff:Number, blurX:Number, blurY:Number) 
		{		
			reflBmp.bitmapData = sourceBitmap;
			reflBmp.cacheAsBitmap = true;
			reflBmp.scaleY = -1;
			reflBmp.y = sourceBitmap.height;
			
			reflMask.width = sourceBitmap.width;
			reflMask.height = sourceBitmap.height * dropOff;	
			reflMask.alpha = pAlpha;
			
			this.addChild(reflBmp);
			this.addChild(reflMask);			
			
			reflBmp.mask = reflMask;
			
			if (blurX || blurY) this.filters = [new BlurFilter(blurX, blurY, 3)];
			
			super(sourceBitmap.width, sourceBitmap.height);
		}
		
		/**
		 * Destroy.
		 */
		override public function destroy():void 
		{
			this.filters = null;
			this.removeChild(reflBmp);
			this.removeChild(reflMask);
			
			reflBmp.mask = null;
			reflBmp = null;
			reflMask = null;
			
			super.destroy();
		}
		
	}

}