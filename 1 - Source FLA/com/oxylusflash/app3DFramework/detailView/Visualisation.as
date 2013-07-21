package com.oxylusflash.app3DFramework.detailView
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	/**
	 * Audio visualisation
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Visualisation extends DestroyableSprite
	{
		public var bgMc:Sprite;
		
		private static const INVISIBLE:int = 0;
		private static const VISIBLE:int = 1;
		private var _state:int = INVISIBLE;
		
		private var _compute:Boolean = false;
		private static const DATA_BYTES:uint = 256;
		private var stepX:Number = 0;
		private var midY:Number = 0;
		private var byteArray:ByteArray = new ByteArray;
		
		private static const OSCILLO:int = 0;
		private static const SPECTRUM:int = 1;
		private var _type:int = OSCILLO;
		
		private var oscilloHolder:DestroyableSprite;
		private var spectrumHolder:DestroyableSprite;
		
		private static const BARS_SPACING:Number = 2;
		private static const BAR_WIDTH:Number = 20;
		private static const BOOST:Number = 1;
		private var numBars:int = 1;
		private var divX:Number = 0;
		
		var flag:Boolean = true;
		
		private static const GLOW:GlowFilter = new GlowFilter(0x40ACD4, 1, 32, 32, 1, 1);
		
		public function Visualisation()
		{
			this.alpha = 0;
			//bgMc.cacheAsBitmap = true;
			
			oscilloHolder = this.addChild(new DestroyableSprite) as DestroyableSprite;
			spectrumHolder = this.addChild(new DestroyableSprite) as DestroyableSprite;
			
			oscilloHolder.filters = [GLOW];
		}
		
		/* Enter frame handler */
		private function enterFrameHandler(e:Event):void
		{
			try { SoundMixer.computeSpectrum(byteArray, _type == SPECTRUM); } catch (error:Error) { }
			update();
		}
		
		/* Show */
		public function show(instant:Boolean = false):void
		{
			if (_state != VISIBLE)
			{
				_state = VISIBLE;
				Tweener.addTween(this, { alpha: 1, time: instant ? 0 : 0.3, transition: "easeoutquad" } );
			}
		}
		
		/* Hide */
		public function hide(instant:Boolean = false):void
		{
			if (_state != INVISIBLE)
			{
				_state = INVISIBLE;
				Tweener.addTween(this, { alpha: 0, time: instant ? 0 : 0.3, transition: "easeoutquad" } );
			}
		}
		
		/* Change it to oscilloscope */
		public function toOscilloscope():void
		{
			_type = OSCILLO;
			oscilloHolder.visible = true;
			spectrumHolder.visible = false;
		}
		
		/* Change it to spectrum */
		public function toSpectrum():void
		{
			_type = SPECTRUM;
			oscilloHolder.visible = false;
			spectrumHolder.visible = true;
		}
		
		/* Update visualisation */
		private function update():void
		{
			if (_compute)
			{
				if (_type == OSCILLO) updateOscillo();
				else updateSpectrum();
			}
		}
		
		/* Read float */
		private function readFloat():Number
		{
			var value:Number = 0;
			try { value = byteArray.readFloat(); } catch (error:Error) { value = 0; }
			return value;
		}
		
		/* Update oscilloscope */
		private function updateOscillo():void
		{
			var oscilloCanvas:OscilloCanvas = new OscilloCanvas;
			oscilloHolder.addChild(oscilloCanvas);
			
			oscilloCanvas.graphics.clear();
			oscilloCanvas.graphics.lineStyle(1, 0x40ACD4, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.ROUND);
			//oscilloCanvas.graphics.beginFill(0x40ACD4, 0.5);
			oscilloCanvas.graphics.moveTo(-2, midY);
			
			for (var i:uint = 0; i < DATA_BYTES; ++i)
			{
				oscilloCanvas.graphics.lineTo(i * stepX, (1 + readFloat()) * midY);
			}
			
			oscilloCanvas.graphics.lineTo(bgMc.width + 2, midY);
			//oscilloCanvas.graphics.endFill();
			
			oscilloCanvas.die();
		}
		
		/* Update spectrum */
		private function updateSpectrum():void
		{
			var childIndex:int = 0;
			var bar:SpectrumBar;
			
			for (var i:uint = 0; i < DATA_BYTES; i += divX)
			{
				if (childIndex < numBars)
				{
					bar = spectrumHolder.getChildAt(childIndex) as SpectrumBar;
					bar.targetHeight = BOOST * this.height * readFloat();
					childIndex++;
				}
			}
		}
		
		/* Update num bars */
		private function updateBars():void
		{
			var bar:SpectrumBar;
			while (spectrumHolder.numChildren)
			{
				bar = spectrumHolder.getChildAt(0) as SpectrumBar;
				bar.destroy();
			}
			
			for (var i:int = 0; i < numBars; ++i)
			{
				bar = spectrumHolder.addChild(new LibSpectrumBar) as SpectrumBar;
				bar.width = BAR_WIDTH;
				bar.x = i * (BAR_WIDTH + BARS_SPACING);
			}
		}
		
		/* Start spectrum computing */
		private function startComputing():void
		{
			if (!_compute)
			{
				_compute = true;
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
			}
		}
		
		/* Stop spectrum computing */
		private function stopComputing():void
		{
			if (_compute)
			{
				_compute = false;
				this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/* Override */
		override public function get alpha():Number { return super.alpha; }
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			this.visible = value > 0;
			if (this.visible) startComputing();
			else stopComputing();
		}
		
		override public function get width():Number { return bgMc.width; }
		override public function set width(value:Number):void
		{
			bgMc.width = value;
			stepX = value / (DATA_BYTES - 1);
			numBars = Math.max(1, Math.ceil((value + BARS_SPACING) / (BAR_WIDTH + BARS_SPACING)));
			divX = Math.round(DATA_BYTES / numBars);
			updateBars();
			update();
		}
		
		override public function get height():Number { return bgMc.height; }
		override public function set height(value:Number):void
		{
			bgMc.height = value;
			spectrumHolder.y = value;
			midY = value * 0.5;
			update();
		}
		
	}

}