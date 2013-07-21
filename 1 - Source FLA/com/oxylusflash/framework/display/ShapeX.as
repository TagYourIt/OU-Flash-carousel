package com.oxylusflash.framework.display 
{
	import com.oxylusflash.framework.core.IDestructible;
	import flash.display.Shape;
	
	/**
	 * Shape extended
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ShapeX extends Shape implements IDestructible
	{
		private var _destroyed:Boolean = false;
		
		/* Shape extended */
		public function ShapeX() { }
		
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