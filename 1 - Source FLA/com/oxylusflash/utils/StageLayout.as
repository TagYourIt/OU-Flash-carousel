/**
 * @version 10/04/10
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.oxylusflash.events.StageLayoutEvent;
	
	/**
	 * Layout class.
	 */
	public class StageLayout extends EventDispatcher
	{
		private static var INSTANCE:StageLayout;
		
		private var _stage:Stage;
		
		private var widthInf:Number;
		private var heightInf:Number;		
		
		private var widthAsPerc:Boolean = false;
		private var heightAsPerc:Boolean = false;
		
		private var _width:Number;
		private var _height:Number;
		private var _x:Number;
		private var _y:Number;
		private var _minWidth:Number;
		private var _minHeight:Number;
		
		public function StageLayout()
		{
			if (INSTANCE)
				throw new Error("An instance of StageLayout already exists. Use StageLayout.getInstance()");
		}
		
		/**
		 * Get StageLayout instance.
		 * @return StageLayout instance.
		 */
		public static function getInstance():StageLayout
		{
			if (INSTANCE == null)
			{
				INSTANCE = new StageLayout();
			}
			
			return INSTANCE;
		}
		
		/**
		 * Initialize layout. Add RESIZE event listener before calling init.
		 * @param	stageRef	Stage reference.
		 * @param	width		Layout width (e.g.: 250, "80%", -300).
		 * @param	height		Layout height (e.g.: 300, "75%", -100).
		 * @param	minWidth	Layout minimum width.
		 * @param	minHeight	Layout minimum height.
		 * @param	x			Layout x offset.
		 * @param	y			Layout y offset.
		 */
		public function init(stageRef:Stage, width:*, height:*, minWidth:Number = 0, minHeight:Number = 0, x:Number = 0, y:Number = 0):void
		{
			_stage = stageRef;			
			_minWidth = minWidth;
			_minHeight = minHeight;
			_x = x;
			_y = y;
			
			if (width is Number)
			{
				widthInf = width;
			}
			else if(width is String)
			{
				widthInf = Number(width.split("%")[0]) / 100;
				widthAsPerc = true;
			}
			else
			{
				throw new ArgumentError("<width> must Number or String.");
			}
			
			if (height is Number)
			{
				heightInf = height;
			}
			else if(height is String)
			{
				heightInf = Number(height.split("%")[0]) / 100;
				heightAsPerc = true;
			}
			else
			{
				throw new ArgumentError("<height> must Number or String.");
			}
			
			_stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
			updateLayout();
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			updateLayout();
		}
		
		/**
		 * Update layout info (dispatches RESIZE event).
		 * Init must be called before.
		 */
		public function updateLayout():void
		{
			if (_stage == null)
			{
				throw new Error("Init wasn't called !");
			}
			
			var sw:Number = _stage.stageWidth - _x;
			var sh:Number = _stage.stageHeight - _y;
			
			_width = Math.round(Math.max(_minWidth, widthAsPerc ? widthInf * sw : (widthInf <= 0 ? sw + widthInf : widthInf)));
			_height = Math.round(Math.max(_minHeight, heightAsPerc ? heightInf * sh : (heightInf <= 0 ? sh + heightInf : heightInf)));
			
			dispatchEvent(new StageLayoutEvent(StageLayoutEvent.RESIZE, this));
		}
		
		/**
		 * Stage instance.
		 */
		public function get stage():Stage { return _stage; }
		
		/**
		 * Current layout width.
		 */
		public function get width():Number { return _width; }	
		
		/**
		 * Current layout height.
		 */
		public function get height():Number { return _height; }	
		
		/**
		 * Layout x.
		 */
		public function get x():Number { return _x; }
		
		/**
		 * Layout y.
		 */
		public function get y():Number { return _y; }
		
		/**
		 * Layout minimum width.
		 */
		public function get minWidth():Number { return _minWidth; }
		
		/**
		 * Layout minimum height.
		 */
		public function get minHeight():Number { return _minHeight; }
	}
}