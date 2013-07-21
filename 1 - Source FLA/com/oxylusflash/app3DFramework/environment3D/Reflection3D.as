package com.oxylusflash.app3DFramework.environment3D
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.layer.ViewportLayer;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Reflection3D extends Plane
	{
		protected var _layer:ViewportLayer;
		private var parentLayer:ViewportLayer;
		protected var env3DRef:Environment3D;
		
		private var materialSource:MaterialSource;
		private var bitmapMaterial:BitmapMaterial;
		
		/**
		 * Create new reflection.
		 * @param	sourceBitmap	Source bitmap data
		 * @param	env3D			Parent 3D environment
		 * @param	pParentLayer	Parent layer
		 */
		public function Reflection3D(sourceBitmap:BitmapData, alpha:Number, dropOff:Number, blurX:Number, blurY:Number, env3D:Environment3D, pParentLayer:ViewportLayer = null)
		{
			materialSource = new ReflectionSource(sourceBitmap, alpha, dropOff, blurX, blurY);
			
			bitmapMaterial = new BitmapMaterial(materialSource.bitmap, false);
			
			bitmapMaterial.precisionMode = 1;
			bitmapMaterial.precision = 16;
			bitmapMaterial.pixelPrecision = 16;
			bitmapMaterial.minimumRenderSize = 8;
			bitmapMaterial.smooth = true;
			bitmapMaterial.tiled = false;
			bitmapMaterial.baked = true;
			
			super(bitmapMaterial, sourceBitmap.width, sourceBitmap.height, 2, 2);
			
			env3DRef = env3D;
			
			// create viewport layer
			_layer = new ViewportLayer(env3DRef.viewport, this);
			parentLayer = pParentLayer || env3DRef.viewport.containerSprite;
			parentLayer.addLayer(_layer);
		}
		
		/**
		 * Render plane.
		 */
		public function render():void { update(); env3DRef.render([_layer]); }
		
		/**
		 * Update reflection.
		 */
		public function update():void { materialSource.update(); }
		
		/**
		 * Plane viewport layer.
		 */
		public function get layer():ViewportLayer { return _layer; }
		
		/**
		 * Destroy plane.
		 */
		public function destroy():void
		{
			parentLayer.removeLayer(_layer);
			parentLayer = _layer = null;
			env3DRef = null;
			
			if (bitmapMaterial)
			{
				bitmapMaterial.destroy();
				bitmapMaterial = null;
			}
			
			if (materialSource)
			{
				materialSource.destroy();
				materialSource = null;
			}
		}
		
	}

}
