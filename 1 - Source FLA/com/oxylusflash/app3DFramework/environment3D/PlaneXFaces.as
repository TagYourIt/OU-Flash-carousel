package com.oxylusflash.app3DFramework.environment3D
{
	import flash.display.BitmapData;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class PlaneXFaces extends MaterialsList
	{
		private var _frontMaterial:BitmapMaterial;
		private var _backMaterial:BitmapMaterial;
		
		/**
		 * Create two-faces plane material list
		 * @param	frontBmp		Front face bitmap data.
		 * @param	backBmp			Back face bitmap data.
		 * @param	frontBaseColor	Front face color replacement, if bitmap data not specified.
		 * @param	backBaseColor	Back face color replacement, if bitmap data not specified.
		 */
		public function PlaneXFaces(frontBitmap:BitmapData, backBitmap:BitmapData)
		{
			_frontMaterial = addMaterial(createMaterial(frontBitmap), "front") as BitmapMaterial;
			_backMaterial = addMaterial(createMaterial(backBitmap) , "back") as BitmapMaterial;
		}
		
		/**
		 * Create face material.
		 * @param	bitmap	Face bitmap data.
		 * @param	color	Face color replacement, if bitmap data not specified.
		 * @return	A bitmap material.
		 */
		private function createMaterial(bitmap:BitmapData):BitmapMaterial
		{
			var bitmapMaterial:BitmapMaterial = new BitmapMaterial(bitmap, false);
			
			bitmapMaterial.precisionMode = 1;
			bitmapMaterial.precision = 16;
			bitmapMaterial.pixelPrecision = 16;
			bitmapMaterial.minimumRenderSize = 8;
			bitmapMaterial.smooth = true;
			bitmapMaterial.tiled = false;
			bitmapMaterial.baked = true;
			
			return bitmapMaterial;
		}
		
		/**
		 * Destroy materials.
		 */
		public function destroy():void
		{
			_frontMaterial.destroy();
			_backMaterial.destroy();
			_frontMaterial = _backMaterial = null;
		}

		public function get frontMaterial():BitmapMaterial { return _frontMaterial; }
		public function get backMaterial():BitmapMaterial { return _backMaterial; }

	}

}
