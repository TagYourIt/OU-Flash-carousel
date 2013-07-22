//load classes
import fl.controls.dataGridClasses.DataGridColumn;
import fl.data.DataProvider;
import flash.net.*;
import flash.events.*;
import fl.controls.ScrollPolicy; 
import flash.utils.Timer;

//setup variables for XML load
var request:URLRequest = new URLRequest("states2.xml");
var loader:URLLoader = new URLLoader;

//import XML file data
loader.load(request);
loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);

//Setup Timer
var myTimer:Timer = new Timer(10000,1);
myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, loadXMLdata);
myTimer.start();

//Function to refresh data load
function loadXMLdata(event:Event):void {
    loader.load(request);
    myTimer.start();
}

//process setlist into datagrid component                                                
function loaderCompleteHandler(event:Event):void {
    
    var setlistXML:XML = new XML(loader.data);

    var trackCol:DataGridColumn = new DataGridColumn("track");
    trackCol.headerText = "ID";
    trackCol.width = 30;    
    var nameCol:DataGridColumn = new DataGridColumn("name");
    nameCol.headerText = "Song";
    nameCol.width = 260;
    
    var myDP:DataProvider = new DataProvider(setlistXML);
    songGrid.dataProvider = myDP;
    
    songGrid.columns = [trackCol, nameCol];
    songGrid.verticalScrollPolicy = ScrollPolicy.AUTO;
    
}