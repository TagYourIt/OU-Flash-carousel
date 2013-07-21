package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.filters.BlurFilter;
	
	/**
	 * Oscilloscope canvas
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class OscilloCanvas extends DestroyableSprite
	{
		public function OscilloCanvas() { }
		
		/* Die */
		public function die():void
		{
			Tweener.addTween(this, { alpha: 0, time: 1, transition: "easeoutquint", onComplete: destroy } );
		}
		
		/* Overrides */
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			this.graphics.clear();
			super.destroy();
		}
		
	}

}
