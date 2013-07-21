package com.oxylusflash.app3DFramework.environment3D
{
	import com.oxylusflash.app3DFramework.IDestroyable;
	import flash.display.BitmapData;
	import flash.events.Event;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.view.layer.ViewportLayer;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class PlaneX extends Cube
	{
		protected var _layer:ViewportLayer;
		private var parentLayer:ViewportLayer;
		protected var env3DRef:Environment3D;
		
		protected var planeFaces:PlaneXFaces;
		protected var _frontSource:MaterialSource;
		protected var _backSource:MaterialSource;
		
		public var extraInfo:Object = { };
		
		/**
		 * Create a double sided plane.
		 * @param	env3D			Environment3D reference.
		 * @param	parentLayer		Parent viewport layer.
		 * @param	frontSrc		Front material source.
		 * @param	backSrc			Back material source.
		 * @param	frontCol		Front color replacement.
		 * @param	backCol			Back color replacement.
		 * @param	width			Plane width.
		 * @param	height			Plane height.
		 * @param	segments		Plane segments.
		 */
		public function PlaneX(frontSrc:MaterialSource, backSrc:MaterialSource, env3D:Environment3D, pParentLayer:ViewportLayer = null, width:Number = 100, height:Number = 100, segments:int = 1)
		{
			env3DRef = env3D;
			_frontSource = frontSrc;
			_backSource = backSrc;
			
			// create viewport layer
			_layer = new ViewportLayer(env3DRef.viewport, this);
			parentLayer = pParentLayer || env3DRef.viewport.containerSprite;
			parentLayer.addLayer(_layer);
			
			// create plane materials
			planeFaces = new PlaneXFaces(_frontSource.bitmap, _backSource.bitmap);
			
			// create plane
			super(planeFaces, width, 0, height, 1, segments, segments, Cube.NONE, Cube.TOP + Cube.BOTTOM + Cube.LEFT + Cube.RIGHT);
		}
		
		/**
		 * Render plane.
		 */
		public function render():void { env3DRef.render([_layer]); }
		
		/**
		 * Plane viewport layer.
		 */
		public function get layer():ViewportLayer { return _layer; }
		
		/**
		 * Front material source.
		 */
		public function get frontSource():MaterialSource { return _frontSource; }
		
		/**
		 * Back material source.
		 */
		public function get backSource():MaterialSource { return _backSource; }
		
		/**
		 * Destroy plane.
		 */
		override public function destroy():void
		{
			extraInfo = null;
			
			parentLayer.removeLayer(_layer);
			parentLayer = _layer = null;
			env3DRef = null;
			
			planeFaces.destroy();
			planeFaces = null;
			
			if (_frontSource)
			{
				_frontSource.destroy();
				_frontSource = null;
			}
			
			if (_backSource)
			{
				_backSource.destroy();
				_backSource = null;
			}
			
			super.destroy();
		}
		
	}

}
