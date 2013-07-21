package com.oxylusflash.app3DFramework.environment3D
{
	import caurina.transitions.Tweener;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.app3DFramework.toolTip.ToolTipInfo;
	import com.oxylusflash.events.ParamEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import org.papervision3d.materials.BitmapColorMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.view.layer.ViewportLayer;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class Thumbnail3D extends PlaneX
	{
		public static const PRESS:String = "press";
		public static const ROLL_OVER:String = "rollOver";
		public static const ROLL_OUT:String = "rollOut";
		
		private var _data:XML;
		private var _reflection3D:Reflection3D;
		
		/**
		 * Create new 3D thumbnail.
		 * @param	env3D			3D environment.
		 * @param	parentLayer		Thumbnail parent viewport layer.
		 * @param	itemData		Thumbnail xml data.
		 */
		public function Thumbnail3D(env3D:Environment3D, parentLayer:ViewportLayer, itemData:XML)
		{
			_data = itemData;
			
			var settings:Object = env3D.tn3DSettings;
			super(new ThumbnailSource(_data, settings), new SolidColorSource(settings.backColor, settings.maxWidth, settings.maxHeight), env3D, parentLayer, settings.maxWidth, settings.maxHeight, 2);
			_frontSource.addEventListener(ThumbnailSource.INTERACTION_READY, frontSource_interactionReadyHandler, false, 0, true);
			
			planeFaces.frontMaterial.doubleSided = false;
			planeFaces.backMaterial.invisible = true;
		}
		
		/**
		 * Front source is ready for interaction.
		 */
		private function frontSource_interactionReadyHandler(e:Event):void
		{
			_frontSource.removeEventListener(ThumbnailSource.INTERACTION_READY, frontSource_interactionReadyHandler);
			
			planeFaces.frontMaterial.doubleSided = false;
			planeFaces.backMaterial.invisible = false;
			
			//_backSource.width = _frontSource.width;
			//_backSource.height = _frontSource.height;
			//_backSource.update();
			
			_layer.buttonMode = true;
			_layer.addEventListener(MouseEvent.ROLL_OVER, layer_eventsHandler, false, 0, true);
			_layer.addEventListener(MouseEvent.ROLL_OUT, layer_eventsHandler, false, 0, true);
			_layer.addEventListener(MouseEvent.MOUSE_DOWN, layer_eventsHandler, false, 0, true);
			_layer.addEventListener(MouseEvent.CLICK, layer_eventsHandler, false, 0, true);
		}
		
		/**
		 * Viewport layer events handler.
		 */
		private function layer_eventsHandler(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.ROLL_OVER:
					if (!e.buttonDown)
					{
						var tipInfo:ToolTipInfo = env3DRef.toolTips.configOnly.thumbnail;
						tipInfo.item = _layer;
						tipInfo.tipString = String(_data.tooltip[0].text());
						env3DRef.tooltip.show(tipInfo);
						_frontSource.simulateRollOver();
						MainApp3D.soundsController.playSound("over");
					}
					dispatchEvent(new Event(ROLL_OVER));
					break;
					
				case MouseEvent.ROLL_OUT:
					env3DRef.tooltip.hide();
					_frontSource.simulateRollOut();
					dispatchEvent(new Event(ROLL_OUT));
					break;
					
				case MouseEvent.MOUSE_DOWN:
					env3DRef.tooltip.hide();
					MainApp3D.soundsController.playSound("click");
					break;
					
				case MouseEvent.CLICK:
					simulateClick();
					break;
			}
		}
		
		/**
		 * Simulate thumbnail 3D click
		 */
		public function simulateClick():void
		{
			dispatchEvent(new ParamEvent(PRESS, { data: _data } ));
		}
		
		/**
		 * Mouse enabled.
		 */
		public function get mouseEnabled():Boolean { return _layer.mouseEnabled; }
		public function set mouseEnabled(value:Boolean):void { _layer.mouseEnabled = value; }
		
		/**
		 * Thumbnail data
		 */
		public function get data():XML { return _data; }
		
		/**
		 * Reflection.
		 */
		public function get reflection3D():Reflection3D { return _reflection3D; }
		public function set reflection3D(value:Reflection3D):void
		{
			_reflection3D = value;
			_frontSource.addEventListener(MaterialSource.UPDATE, materialSource_updateHandler, false, 0, true);
		}
		
		private function materialSource_updateHandler(e:Event):void
		{
			_reflection3D.update();
		}
		
		/**
		 * Destroy thumbnail.
		 */
		override public function destroy():void
		{
			Tweener.removeTweens(this);
			
			_data = null;

			_layer.buttonMode = true;
			_layer.removeEventListener(MouseEvent.ROLL_OVER, layer_eventsHandler);
			_layer.removeEventListener(MouseEvent.ROLL_OUT, layer_eventsHandler);
			_layer.removeEventListener(MouseEvent.MOUSE_DOWN, layer_eventsHandler);
			_layer.removeEventListener(MouseEvent.CLICK, layer_eventsHandler);
				
			_frontSource.removeEventListener(ThumbnailSource.INTERACTION_READY, frontSource_interactionReadyHandler);
			_frontSource.removeEventListener(MaterialSource.UPDATE, materialSource_updateHandler);
			
			if (_reflection3D)
			{
				_reflection3D.destroy();
				_reflection3D = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Render.
		 */
		override public function render():void
		{
			if (_reflection3D) { _reflection3D.render(); }
			super.render();
		}
		
	}

}
