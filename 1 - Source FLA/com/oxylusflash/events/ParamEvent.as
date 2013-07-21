/**
 * @version 10/04/10
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.events
{
	import flash.events.Event;
	
	public class ParamEvent extends Event
	{
		public static const RESIZE:String = "resize";		
		private var _params:Object;
		
		/**
		 * Event with parameters.
		 * @param	type	Event type.
		 * @param	p		Parameters object.
		 */
		public function ParamEvent(type:String, p:Object)
		{
			super(type);			
			_params = p;
		}
		
		/**
		 * Event params. 
		 */
		public function get params():Object { return _params; }
		
		override public function clone():Event
		{
			return new ParamEvent(type, _params);
		}
	}
}