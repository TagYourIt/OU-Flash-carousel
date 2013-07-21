package com.oxylusflash.app3DFramework 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class RoundedItem extends DestroyableSprite
	{
		// Rounded shape
		protected var shapeMask:Shape = new Shape;
		private var cornerTL:Number = 0;
		private var cornerTR:Number = 0;
		private var cornerBL:Number = 0;
		private var cornerBR:Number = 0;
		
		public function RoundedItem() 
		{
			// Add mask shape
			this.addChild(shapeMask);
			this.mask = shapeMask;
		}
		
		/**
		 * Redraw rounded mask
		 */
		public function redrawMask(tl:Number = -1, tr:Number = -1, bl:Number = -1, br:Number = -1, forced:Boolean = false):void
		{
			var updateMask:Boolean = false;
			
			if (tl >= 0) { cornerTL = tl; updateMask = true; }
			if (tr >= 0) { cornerTR = tr; updateMask = true; }
			if (bl >= 0) { cornerBL = bl; updateMask = true; }
			if (br >= 0) { cornerBR = br; updateMask = true; }
			
			updateMask ||= shapeMask.width == 0 && shapeMask.height == 0;
			if (updateMask || forced)
			{
				shapeMask.graphics.clear();
				shapeMask.graphics.beginFill(0);
				shapeMask.graphics.drawRoundRectComplex(0, 0, this.width, this.height, cornerTL, cornerTR, cornerBL, cornerBR);				
				extraDrawing();
				shapeMask.graphics.endFill();
			}
		}
		
		protected function extraDrawing():void { }
		
		/**
		 * Destroy.
		 */
		override public function destroy():void
		{
			this.removeChild(shapeMask);
			shapeMask = null;			
			super.destroy();
		}
		
	}

}