package com.oxylusflash.app3DFramework.environment3D 
{
	import com.oxylusflash.app3DFramework.IDestroyable;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.Viewport3D;
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Wrapper3D extends DisplayObject3D implements IDestroyable
	{
		protected var _layer:ViewportLayer;
		protected var parentLayer:ViewportLayer;
		protected var env3DRef:Environment3D;
		protected var _destroyed:Boolean = false;
		
		/**
		 * Create 3D wrapper (container for other 3D objects.)
		 * @param	env3D			Environment3D instance where the wrapper will be added.
		 * @param	parentLayer		Parent viewport layer.
		 */
		public function Wrapper3D(env3D:Environment3D, pParentLayer:ViewportLayer = null) 
		{
			env3DRef = env3D;
			parentLayer = pParentLayer || env3DRef.viewport.containerSprite;			
			_layer = new ViewportLayer(env3DRef.viewport, this);
			parentLayer.addLayer(_layer);
		}
		
		/**
		 * Create child wrapper;
		 * @return	Created child wrapper as Wrapper3D.
		 */
		public function createChildWrapper():Wrapper3D { return this.addChild(new Wrapper3D(env3DRef, _layer)) as Wrapper3D; }
		
		/**
		 * Render wrapper and contents.
		 */
		public function render():void { env3DRef.render([_layer]); }
		
		/**
		 * Get wrapper viewport layer.
		 */
		public function get layer():ViewportLayer { return _layer; }
		
		/**
		 * Destroy wrapper.
		 */
		public function destroy():void
		{
			parentLayer.removeLayer(_layer);
			parentLayer = _layer = null;
			env3DRef = null;
		}
		
		public function get destroyed():Boolean { return _destroyed; }
		
	}

}