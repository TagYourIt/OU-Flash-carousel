package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.framework.display.SpriteX;
	
	/**
	 * Spectrum bar
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class SpectrumBar extends SpriteX
	{
		private var _targetHeight:Number;
		
		public function SpectrumBar()
		{
			this.height = 0;
		}
		
		/* Target height */
		public function get targetHeight():Number { return _targetHeight; }
		public function set targetHeight(value:Number):void
		{
			if (_targetHeight != value)
			{
				_targetHeight = value;
				Tweener.addTween(this, { height: _targetHeight, time: 0.5, transition: "easeOutQuad", onUpdate: tweenUpdateHandler } );
			}
		}
		
		/* Tween update handler */
		private function tweenUpdateHandler():void
		{
			this.y = -this.height;
		}
		
		/* Overrides */
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			super.destroy();
		}
		
	}

}