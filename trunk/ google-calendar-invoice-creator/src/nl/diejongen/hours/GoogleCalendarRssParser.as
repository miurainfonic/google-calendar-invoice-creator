package nl.diejongen.hours
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import nl.diejongen.hours.data.RssData;
	import nl.diejongen.hours.model.DataModel;
	
	[Event(name="rssDataChanged",type="flash.events.Event")]
	[Event(name="successLoading",type="flash.events.Event")]
	[Event(name="errorLoading",type="flash.events.Event")]
	public class GoogleCalendarRssParser extends UIComponent
	{
		
		[Bindable]
		public var entries:ArrayCollection;
		[Bindable]
		public var months:Array;
		[Bindable]
		public var autoUpdate:Boolean = true;
		
		private var loader:URLLoader;
		private var uren:XML;
		private var requestTimer:Timer = new Timer(100, 1);
		private var model:DataModel = DataModel.getInstance();
		
		private var _rssAddress:String;
		[Bindable]
		public function set rssAddress(v:String) : void {
			_rssAddress = v
			tryLoadRssData();
		}
		public function get rssAddress() : String {
			return _rssAddress;
		}
		
		private var _startIndex:int;
		[Bindable]
		public function set startIndex(v:int) : void {
			_startIndex = v;
			if (autoUpdate) tryLoadRssData();
		}
		public function get startIndex() : int {
			return _startIndex;
		}
		
		private var _maxResults:int;
		[Bindable]
		public function set maxResults(v:int) : void{
			_maxResults = v;
			if (autoUpdate) tryLoadRssData();
		}
		public function get maxResults() : int {
			return _maxResults;
		}
		
		private var _brakeIdentifier:String;
		[Bindable]
		public function set brakeIdentifier(v:String) : void {
			_brakeIdentifier = v;
			if (autoUpdate) tryLoadRssData();
		}
		public function get brakeIdentifier() : String {
			return _brakeIdentifier;
		}
		
		public function GoogleCalendarRssParser() {
			super();
			requestTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _loadRssData);
		}
		
		private function tryLoadRssData() : void {
			if(rssAddress != "" && startIndex > 0 && maxResults > 0) {
				requestTimer.reset();
				requestTimer.start();
			}
		}
		
		public function loadRssData(rssAddress:String = null, startIndex:Number = 1, maxResults:Number = 100) : void {
				
				if(rssAddress) this.rssAddress = rssAddress;
				this.startIndex = startIndex;
				this.maxResults = maxResults;
				tryLoadRssData();
				
		}
		
		
		private function _loadRssData(event:TimerEvent) : void {
			entries = new ArrayCollection();
			model.entries = entries;
			
			var service:HTTPService = new HTTPService();
			service.resultFormat = HTTPService.RESULT_FORMAT_OBJECT;
			service.makeObjectsBindable = true;
			
			/**
			 * rss verandert mbv reg expr
			 * van http://www.google.com/calendar/feeds/.../public/basic
			 * naar http://www.google.com/calendar/feeds/.../public/full
			 */
			
			var regExp:RegExp = /http:\/\/www.google.com\/calendar\/feeds\//g;
			if(rssAddress.search(regExp) == -1){
				Alert.show("Rss should start with 'http://www.google.com/calendar/feeds/'");
				return;
			}
			
			regExp = /\/public\/basic/g;
			if(rssAddress.search(regExp) != -1){
				rssAddress = rssAddress.replace(regExp, "/public/full");
			}
			 
			service.url = rssAddress + "?start-index=" + startIndex + "&max-results=" + maxResults;
			service.send();
			service.addEventListener(ResultEvent.RESULT, _onDataLoaded, false, 0, true);
			service.addEventListener(FaultEvent.FAULT, onServiceFault);
		}
		
		/**
		 * Creates an ArrayCollection with RegistratorData objects that holds relevant props of the RSS request 
		 * to Google's Calendar app. 
		 * Reads xml feed
		 * <feed ...>
		 *   <entry>
		 *     <gd:when startTime="2008-08-11T09:00:00.000+02:00" endTime="2008-08-11T18:00:00.000+02:00"/>
		 *   </entry>
		 * </feed>
		 * Dispatches an event when ready.
		 */
		private var errorDetected:Boolean;
		private function _onDataLoaded(event:ResultEvent):void 
		{
			errorDetected = false;
			if(event.result is String) {
				Alert.show("Could not load RSS service, check the RSS address.\nMessage: "+ event.result);
				return;
			}
			var parseE:ArrayCollection = ArrayCollection(event.result.feed.entry);
			var entriesArr:Array = new Array();
			for each( var chNode:Object in parseE) 
			{
				var obj:RssData = new RssData();
				obj.title = chNode.title;
				//obj.date = findDateString(chNode.when.startTime);
				
				if(chNode.when)
				{
					var regExp:RegExp = /\d\d\d\d-\d\d-\d\d/;
					var i:int;
					var startTime:String = chNode.when.startTime as String;
					var stopTime:String = chNode.when.endTime as String;
					if((i = startTime.search(regExp)) != -1)
					{
						var year:String = startTime.substr(i, 4);
						var month:String = startTime.substr(i + 5, 2);
						var day:String = startTime.substr(i + 8, 2);
						obj.date = new Date(int(year), int(month) - 1, int(day));
					}
					else 
					{
						Alert.show("Could not retrieve date from node with title: " + chNode.title , "Warning");
						errorDetected = true;
						break;
					}
					
						
					regExp = /T\d\d:\d\d/;
					//find start time
					if((i = startTime.search(regExp)) != -1)
					{
						obj.startTime = startTime.substr(i + 1, 5);
					}
					
					//find stop time
					if((i = stopTime.search(regExp)) != -1)
					{
						obj.endTime = stopTime.substr(i + 1, 5);
						obj.endTime = obj.endTime == "00:00" ? "24:00" : obj.endTime;
					}
					
						
					//only calculate time if it has a start and endtime and break time
					if(obj.startTime && obj.endTime){
						
						//get start date (for time)
						var startDate:Date = new Date(0);
						var time24Arr:Array = obj.startTime.split(":");
						startDate.hours = time24Arr[0];
						startDate.minutes = time24Arr[1];
						
						//get end date (for time)
						var endDate:Date = new Date(0);
						time24Arr = obj.endTime.split(":");
						endDate.hours = time24Arr[0];
						endDate.minutes = time24Arr[1];
						
						//calculate the brake time
						var brakeArr:Array = getBreakValues(chNode.title, brakeIdentifier);
						var num:Number = 0;
						for each(var n:String in brakeArr) {
							num += Number(n);
						}
						
						//calculate total time
						obj.totalTime = (endDate.time - startDate.time) / (1000 * 60 * 60) - num;
						
						//create summary
						obj.summary = obj.title + " D" + obj.date.fullYear + "-" + obj.date.month + 1 + "-" + obj.date.date + 
											" T" + obj.startTime + "-" + obj.endTime + " B" + num;
						
						//add RssData to array
						entriesArr.push(obj);
					}else{
						trace("Skipped node with title: " + obj.title + " " + obj.date);
					} 
				}
				else
				{
					if(chNode.recurrence){
						var msg:String = "Hours doesn't support recurrency momentarily, and will ignore the repeated events with title: " + chNode.title;
						Alert.show(msg);
						trace(msg + "\n" + chNode.recurrence);
					}
				}
			}
			entries = new ArrayCollection(entriesArr);
			
			dispatchEvent(new Event("rssDataChanged"));
			
			if(entries.length > 0){
				if(!errorDetected){
					var t:Timer = new Timer(1000, 1);
					t.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void { dispatchEvent(new Event("successLoading")); },false, 0 , false);
					t.start();
				}
			}
			model.entries = entries;
			
		}
		
		/**
		 * show alert when not be able to load service
		 */
		private function onServiceFault(event:FaultEvent):void {
			
			Alert.show("Could not load service. Check your internet connection and your RSS address.");
			dispatchEvent(new Event("errorLoading"));
			
		}
		
		/**
		 * gets the values of a break taken in a period of work, so it can be subtracted from the day total
		 * @param input String: the title string of Google's Calendar entry
		 * @param breakIdentifier String: the character(s) that preceed the break value to indicate it's 
		 * the duration of a break notated. Default '-'.
		 */
		private function getBreakValues(input:String, brakeIdentifier:String = "-") : Array {
			var patternStr:String = brakeIdentifier + "((\\d+\\.\\d+)|([0-9]+)|(\\.\\d+))";
			var pattern:RegExp = new RegExp(patternStr, "g")
			var resultArr:Array = new Array()
			var result:Array;
			while(result = pattern.exec(input)) {
				resultArr.push((result[0] as String).substr(1));
			}
			return resultArr;
		}
		
	}
}