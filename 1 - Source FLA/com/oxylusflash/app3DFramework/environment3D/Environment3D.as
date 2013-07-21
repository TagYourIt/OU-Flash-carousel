package com.oxylusflash.app3DFramework.environment3D
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.app3DFramework.toolTip.ToolTip;
	import com.oxylusflash.events.ParamEvent;
	import com.oxylusflash.utils.StageReference;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.stats.StatsView;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Environment3D extends DestroyableSprite
	{
		public static var DATA_OUT:String = "dataOut";
		
		public var scene:Scene3D = new Scene3D;
		public var camera:Camera3D = new Camera3D;
		public var viewport:Viewport3D = new Viewport3D;
		public var engine:BasicRenderEngine = new BasicRenderEngine;
		
		protected var mainApp:MainApp3D;
		
		protected var w:Number = 0;
		protected var h:Number = 0;
		
		public var tn3DSettings:Object;
		
		public static const RADIAN:Number = Math.PI / 180;
		
		/**
		 * 3D Environment.
		 * @param	pMainApp	Main app reference.
		 */
		public function Environment3D(pMainApp:MainApp3D)
		{
			mainApp = pMainApp;
			
			camera.useClipping = true;
			camera.useCulling = true;
			/*camera.z = Math.abs(camera.z);
			camera.focus = camera.z / camera.zoom;*/
			
			viewport.cacheAsBitmap = true;
			this.addChild(viewport);
			
			/* Stats */
			//stage.addChild(new StatsView(engine));
		}
		
		/**
		 * Render
		 * @param	layers	Layers to be rendered
		 * @param	forced	Force render
		 */
		public function render(layers:Array = null, forced:Boolean = false):void
		{
			if (forced || scene.numChildren)
			{
				if (layers) engine.renderLayers(scene, camera, viewport, layers);
				else engine.renderScene(scene, camera, viewport);
			}
		}
		
		/**
		 * Data output
		 */
		public function outputData(pData:XML):void
		{
			dispatchEvent(new ParamEvent(DATA_OUT, { data: pData } ));
		}
		
		/**
		 * Properties
		 */
		public function get tooltip():ToolTip { return mainApp.tooltip; }
		public function get toolTips():Object { return mainApp.toolTips; }
		
		/**
		 * Overrides
		 */
		override public function destroy():void
		{
			for each(var child:Object in scene.children)
			{
				scene.removeChild(child as DisplayObject3D);
			}
			scene = null;
			camera = null;
			this.removeChild(viewport);
			viewport.destroy(); viewport = null;
			engine.destroy(); engine = null;
			mainApp = null;
			super.destroy();
		}
		
		override public function get width():Number { return w; }
		override public function set width(value:Number):void
		{
			w = value;
			viewport.viewportWidth = int(w * 0.5) * 2;
			render(null, true);
		}
		
		override public function get height():Number { return h; }
		override public function set height(value:Number):void
		{
			h = value;
			viewport.viewportHeight = int(h * 0.5) * 2;
			render(null, true);
		}
		
		override public function get stage():Stage { return StageReference.stage || super.stage; }
		
	}

}