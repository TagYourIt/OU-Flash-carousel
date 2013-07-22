package {
   
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Timer;   

   public class test extends Sprite {
      
      private var xml:XML;
      private var xl:XMLList;
      private var l:URLLoader;
      private var r:URLRequest;
      private var timer:Timer;
      private var vars:URLVariables;;
      
      public function test() {
         l =  new URLLoader();
         r = new URLRequest("test.xml");
         vars = new URLVariables();
         timer = new Timer(15000);
         timer.addEventListener(TimerEvent.TIMER, loadXML);
         timer.start();
         loadXML();
      }
      
      private function loadXML(te:TimerEvent = null):void {
         xl = new XMLList();
         vars.antiCache = Math.round(Math.random()*999999);
         r.data = vars;
         r.method = URLRequestMethod.POST;
         l.addEventListener(Event.COMPLETE, xmlLoaded);
         l.load(r);
      }
      
      private function xmlLoaded(e:Event):void {
         xml = XML(e.target.data);
         xl = xml.yourNode;
         trace(xml);
      }
   }
}