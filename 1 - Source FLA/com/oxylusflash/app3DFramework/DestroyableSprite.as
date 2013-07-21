package com.oxylusflash.app3DFramework 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class DestroyableSprite extends Sprite implements IDestroyable
	{
		private var _destroyed:Boolean = false;
		
		/**
		 * Sprite that can be destroyed.
		 */
		public function DestroyableSprite() { }
		
		/**
		 * Sprite is destroyed.
		 */
		public function get destroyed():Boolean { return _destroyed; }
		
		/**
		 * Destroy sprite.
		 */
		public function destroy():void 
		{ 
			if (parent) parent.removeChild(this);	
			_destroyed = true;
		}
		
	}

}