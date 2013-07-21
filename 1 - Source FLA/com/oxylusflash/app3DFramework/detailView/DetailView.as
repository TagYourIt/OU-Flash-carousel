package com.oxylusflash.app3DFramework.detailView 
{
	import com.oxylusflash.app3DFramework.DestroyableSprite;
	import com.oxylusflash.app3DFramework.MainApp3D;
	import com.oxylusflash.app3DFramework.Overlay;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class DetailView extends DestroyableSprite
	{
		public static const BOUNDS_CHANGED:String = "boundsChanged";		
		public var detailBox:DetailBox;
		
		private var w:Number = 0;
		private var h:Number = 0;
		
		public var mainApp:MainApp3D;
		
		/**
		 * Detail view
		 */
		public function DetailView() 
		{
			super.visible = false;
		}
		
		/**
		 * Init detail view
		 * @param	mainAppRef	Main app 3d reference
		 */
		public function init(mainAppRef:MainApp3D):void
		{
			mainApp = mainAppRef;
			detailBox.init(this);
		}
		
		/**
		 * Feed detail view
		 * @param	xmlData		XML data.
		 */
		public function feed(xmlData:XML):void
		{
			detailBox.data = xmlData;
			this.visible = true;
		}
		
		/**
		 * Invisible
		 */
		public function get invisible():Boolean { return !super.visible; }
		public function set invisible(value:Boolean):void { super.visible = !value; }
		
		/**
		 * Overrides
		 */
		override public function get width():Number { return w; }		
		override public function set width(value:Number):void 
		{
			if (w != value)
			{
				w = value;
				if (w + h > 0) dispatchEvent(new Event(BOUNDS_CHANGED));
			}
		}
		
		override public function get height():Number { return h; }		
		override public function set height(value:Number):void 
		{
			if (h != value)
			{
				h = value;
				if (w + h > 0) dispatchEvent(new Event(BOUNDS_CHANGED));
			}
		}
		
		override public function destroy():void 
		{
			detailBox.destroy();
			detailBox = null;
			
			super.destroy();
		}
		
		override public function get visible():Boolean { return super.visible; }		
		override public function set visible(value:Boolean):void 
		{
			if (super.visible != value)
			{
				if (value) 
				{
					detailBox.allOutAnimation();
					mainApp.overlay.show();
				}
				else
				{
					mainApp.env3D.selectedTn3DReset();
				}
				super.visible = value;
			}
		}
		
	}

}