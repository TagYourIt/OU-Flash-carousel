/**
 * @version 10/04/10
 * @author Adrian Bota, adrian@oxylus.ro
 */
package com.oxylusflash.events
{
	import flash.events.Event;
	import com.oxylusflash.utils.StageLayout;
	
	public class StageLayoutEvent extends Event
	{
		public static const RESIZE:String = "resize";		
		private var _stageLayout:StageLayout;
		
		public function StageLayoutEvent(type:String, stageLayoutRef:StageLayout)
		{
			super(type);			
			_stageLayout = stageLayoutRef;
		}
		
		/**
		 * StageLayout instance. 
		 */
		public function get stageLayout():StageLayout { return _stageLayout; }
		
		override public function clone():Event
		{
			return new StageLayoutEvent(type, _stageLayout);
		}
	}
}