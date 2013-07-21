package com.oxylusflash.app3DFramework.environment3D 
{
	import com.oxylusflash.app3DFramework.environment3D.Wrapper3D;
	import com.oxylusflash.events.ParamEvent;
	import flash.events.Event;
	import org.papervision3d.view.layer.ViewportLayer;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class ThumbsWrapper3D extends Wrapper3D
	{
		public static const THUMBNAIL_PRESS:String = "thumbnailPress";	
		public static const THUMBNAIL_ROLL_OVER:String = "thumbnailRollOver";
		public static const THUMBNAIL_ROLL_OUT:String = "thumbnailRollOut";
		
		private var thumbs:Array;
		
		/**
		 * 3D thumbs wrapper.
		 */
		public function ThumbsWrapper3D(env3D:Environment3D, pParentLayer:ViewportLayer = null) 
		{
			super(env3D, pParentLayer);
		}
		
		/**
		 * Add 3D thumbnail.
		 * @param	itemData	Thumbnail data.
		 * @return	Added 3d thumbnail refernce.
		 */
		public function addThumbnail3D(itemData:XML):Thumbnail3D
		{
			var tn3D:Thumbnail3D = this.addChild(new Thumbnail3D(env3DRef, _layer, itemData)) as Thumbnail3D;			
			tn3D.addEventListener(Thumbnail3D.PRESS, tn3D_eventsHandler, false, 0, true);
			tn3D.addEventListener(Thumbnail3D.ROLL_OVER, tn3D_eventsHandler, false, 0, true);
			tn3D.addEventListener(Thumbnail3D.ROLL_OUT, tn3D_eventsHandler, false, 0, true);
			
			if (thumbs == null) thumbs = [];
			thumbs.push(tn3D);
			
			if (thumbs.length >= 2)
			{
				tn3D.extraInfo.prevTn3D = thumbs[thumbs.length - 2];
				Thumbnail3D(tn3D.extraInfo.prevTn3D).extraInfo.nextTn3D = tn3D;
			}
			
			return tn3D;
		}
		
		/**
		 * Connects the first and last thumbs
		 */
		public function connectFirstAndLastThumbs():void
		{
			if (thumbs.length >= 3)
			{
				var tn3D:Thumbnail3D = thumbs[thumbs.length - 1];
				tn3D.extraInfo.nextTn3D = thumbs[0];
				Thumbnail3D(tn3D.extraInfo.nextTn3D).extraInfo.prevTn3D = tn3D;
			}
		}
		
		/**
		 * 3D Thumbnail press handler.
		 */
		private function tn3D_eventsHandler(e:Event):void 
		{
			switch(e.type)
			{
				case Thumbnail3D.PRESS:
					dispatchEvent(new ParamEvent(THUMBNAIL_PRESS, { data: ParamEvent(e).params.data, tn3DRef: e.currentTarget } ));
					break;
					
				case Thumbnail3D.ROLL_OVER:
					dispatchEvent(new Event(THUMBNAIL_ROLL_OVER));
					break;
					
				case Thumbnail3D.ROLL_OUT:
					dispatchEvent(new Event(THUMBNAIL_ROLL_OUT));
					break;
			}
		}
		
		/**
		 * Add 3D reflection.
		 * @param	thumb3DSource	Source thumbnail 3D.
		 * @return  Reflection 3D.
		 */
		public function addReflection3D(thumb3DSource:Thumbnail3D, reflSettings:Object):Reflection3D
		{
			return this.addChild(new Reflection3D(thumb3DSource.frontSource.bitmap, reflSettings.alpha, reflSettings.dropOff, reflSettings.blurX, reflSettings.blurY, env3DRef, _layer)) as Reflection3D;			
		}
		
		/**
		 * Destroy thumbnails.
		 */
		public function destroyThumbnails():void
		{
			if (thumbs)
			{
				var tn3D:Thumbnail3D;
				for each(tn3D in thumbs)
				{
					if (tn3D.reflection3D) this.removeChild(tn3D.reflection3D);
					tn3D.removeEventListener(Thumbnail3D.PRESS, tn3D_eventsHandler);
					tn3D.removeEventListener(Thumbnail3D.ROLL_OVER, tn3D_eventsHandler);
					tn3D.removeEventListener(Thumbnail3D.ROLL_OUT, tn3D_eventsHandler);
					this.removeChild(tn3D);
					tn3D.destroy();					
				}
				thumbs = null;
			}
		}
		
		/**
		 * Overrides.
		 */
		override public function destroy():void 
		{
			destroyThumbnails();
			thumbs = null;
			super.destroy();
		}
		
		/**
		 * Render: rendering the whole scene seems to be faster than rendering the layer with nested layers.
		 */
		//override public function render():void { env3DRef.render(); }
		
	}

}