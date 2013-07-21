package com.oxylusflash.framework.display 
{
	import com.oxylusflash.framework.core.IDestructible;
	import flash.display.MovieClip;
	
	/**
	 * MovieClip extended
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class MovieClipX extends MovieClip implements IDestructible
	{
		private var _destroyed:Boolean = false;
		
		/* MovieClip extended */
		public function MovieClipX() { }
		
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