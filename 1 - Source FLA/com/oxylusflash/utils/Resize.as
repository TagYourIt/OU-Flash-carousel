/**
 * @version 17/01/10
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	/**
	 * Class with static methods for resize and positioning.
	 */
	public class Resize
	{
		public function Resize()
		{
			throw new Error("Resize is a class with static methods, it doesn't need instantiation.");
		}
		
		public static const RESIZE_TO_FIT:String 		= "resizeToFit";
		public static const RESIZE_TO_FIT_FORCED:String = "resizeToFitForced";
		public static const RESIZE_TO_FILL:String 		= "resizeToFill";
		public static const RESIZE_STRETCH:String 		= "resizeStretch";
		public static const RESIZE_TO_ORIGINAL:String 	= "resizeToOriginal";		
		public static const ALIGN_TOP_LEFT:String 		= "alignTopLeft";
		public static const ALIGN_TOP:String 			= "alignTop";
		public static const ALIGN_TOP_RIGHT:String 		= "alignTopRight";
		public static const ALIGN_RIGHT:String 			= "alignRight";
		public static const ALIGN_BOTTOM_RIGHT:String 	= "alignBottomRight";
		public static const ALIGN_BOTTOM:String 		= "alignBottom";
		public static const ALIGN_BOTTOM_LEFT:String 	= "alignBottomLeft";
		public static const ALIGN_LEFT:String 			= "alignLeft";	
		public static const ALIGN_CENTER:String 		= "alignCenter";
		
		/**
		 * Get resize/align parameters for a object resize/align within a container.
		 * @param	contW		Container width.
		 * @param	contH		Container height.
		 * @param	objW		Object original width.
		 * @param	objH		Object original height.
		 * @param	offsetX		Align x offset (usualy will be container x property)
		 * @param	offsetY		Align y offset (usualy will be container y property)
		 * @param	resizeKind	Resize kind.
		 * @param	alignKind	Align kind.
		 * @param	rounded		If true, parameters will be rounded.
		 * @return				Object like: { w: <Number>, h: <Number>, x: <Number>, y: <Number> }
		 */
		public static function getParams(	contW:Number, 
											contH:Number, 
											objW:Number, 
											objH:Number, 
											offsetX:Number = 0, 
											offsetY:Number = 0, 
											resizeKind:String = "resizeToOriginal", 
											alignKind:String = "alignCenter",
											rounded:Boolean = true
										):Object 
		{
			var params:Object = { };
			
			if (resizeKind == RESIZE_STRETCH)
			{
				params.w = contW;
				params.h = contH;
			}
			else if (resizeKind == RESIZE_TO_ORIGINAL || 
					(resizeKind == RESIZE_TO_FIT && objW <= contW && objH <= contH))
			{
				params.w = objW;
				params.h = objH;
			}
			else
			{
				var contRatio:Number = contW / contH;
				var objRatio:Number = objW / objH;
				
				if ((resizeKind == RESIZE_TO_FILL && contRatio < objRatio) || 
					((resizeKind == RESIZE_TO_FIT || resizeKind == RESIZE_TO_FIT_FORCED) && contRatio > objRatio))
				{
					params.h = contH;
					params.w = contH * objRatio;
				}
				else
				{
					params.w = contW;
					params.h = contW / objRatio;
				}
			}
			
			params.x = offsetX;
			params.y = offsetY;
			
			switch(alignKind)
			{
				case ALIGN_BOTTOM:
				case ALIGN_CENTER:
				case ALIGN_TOP: params.x += (contW - params.w) * 0.5; break;
				
				case ALIGN_BOTTOM_RIGHT:
				case ALIGN_RIGHT:
				case ALIGN_TOP_RIGHT: params.x += contW - params.w; break;
			}
			
			switch(alignKind)
			{
				case ALIGN_BOTTOM:
				case ALIGN_BOTTOM_LEFT:
				case ALIGN_BOTTOM_RIGHT: params.y += contH - params.h; break;
				
				case ALIGN_CENTER:
				case ALIGN_LEFT:
				case ALIGN_CENTER: params.y += (contH - params.h) * 0.5; break;
			}
			
			if (rounded)
			{
				params.w = Math.round(params.w);
				params.h = Math.round(params.h);
				params.x = Math.round(params.x);
				params.y = Math.round(params.y);
			}
			
			return params;
		}
	}
}