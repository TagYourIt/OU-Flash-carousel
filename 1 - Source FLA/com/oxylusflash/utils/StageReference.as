package com.oxylusflash.utils 
{
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Adrian Bota, adrian@oxylus.ro
	 */
	public class StageReference
	{
		public static var stage:Stage;		
		public function StageReference() { throw new Error("StageReference class cannot be instantiated !"); }
		public static function init(stageRef:Stage):void { stage = stageRef; }		
	}

}