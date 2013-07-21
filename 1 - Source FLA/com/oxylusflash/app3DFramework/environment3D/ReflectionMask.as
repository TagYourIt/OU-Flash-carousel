package com.oxylusflash.app3DFramework.environment3D 
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ReflectionMask extends Sprite
	{
		
		/**
		 * Reflection mask.
		 */
		public function ReflectionMask() 
		{
			this.blendMode = BlendMode.ALPHA;
			cacheAsBitmap = true;
		}
		
	}

}