package nl.diejongen.hours
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import nl.diejongen.hours.data.PersistentConfigData;

	public class RssView_cb extends VBox
	{
		public static const DEFAULT_RSS:String = "http://www.google.com/calendar/feeds/bj6lgkedmv08vp7e2ucdsvpma0%40group.calendar.google.com/public/basic";
		public static const DEFAULT_START_INDEX:Number = 1;
		public static const DEFAULT_MAX_RESULTS:Number = 200;
		public static const DEFAULT_BREAK_IDENTIFIER:String = "-";
		public static const DEFAULT_MONTH_PATTERN:String = "jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec";
		
		
		[Bindable]
		public var rssAddress:TextInput;
		[Bindable]
		public var startIndex:TextInput;
		[Bindable]
		public var maxResults:TextInput;
		[Bindable]
		public var brakeIdentifier:TextInput;
		[Bindable]
		public var monthPattern:TextInput;
		[Bindable]
		public var entries:ArrayCollection;
		[Bindable]
		public var totalHours:Number;
		[Bindable]
		public var rssParser:GoogleCalendarRssParser;
		[Bindable]
		public var totalTimeColumn:DataGridColumn
		[Bindable]
		public var dateColumn:DataGridColumn;
		[Bindable]
		public var hoursRoot:HOURS;
		
		private var persistantData:PersistentConfigData = PersistentConfigData.getInstance();
		
		private var changeWatchersArr:Array = new Array();
		private var requestTimer:Timer = new Timer(100, 1);
		
		public function RssView_cb() {
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(event:FlexEvent) : void {
			
			registerListeners();
			
			initPersistentData();
			
			setBindings();
			
		}
		
		private function registerListeners() : void {
			
			requestTimer.addEventListener(TimerEvent.TIMER_COMPLETE, loadRssData);
		}
		
		private function initPersistentData() : void {
			if(persistantData.hasValue(PersistentConfigData.RSS_ADDRESS)) {
				rssAddress.text = persistantData.getValue(PersistentConfigData.RSS_ADDRESS) as String;
			}else{
				rssAddress.text = DEFAULT_RSS;
			}
			
			if(persistantData.hasValue(PersistentConfigData.START_RESULTS)) {
				startIndex.text = persistantData.getValue(PersistentConfigData.START_RESULTS) as String;
			}else{
				startIndex.text = String(DEFAULT_START_INDEX);
			}
			
			if(persistantData.hasValue(PersistentConfigData.MAX_RESULTS)) {
				maxResults.text = persistantData.getValue(PersistentConfigData.MAX_RESULTS) as String;
			}else{
				maxResults.text = String(DEFAULT_MAX_RESULTS);
			}
			
			if(persistantData.hasValue(PersistentConfigData.BREAK_IDENTIFIER)) {
				brakeIdentifier.text = persistantData.getValue(PersistentConfigData.BREAK_IDENTIFIER) as String;
			}else{
				brakeIdentifier.text = DEFAULT_BREAK_IDENTIFIER;
			}
			
			/* if(persistantData.hasValue(PersistentConfigData.MONTH_STRING)) {
				monthPattern.text = persistantData.getValue(PersistentConfigData.MONTH_STRING) as String;
			}else{
				monthPattern.text = String(DEFAULT_MONTH_PATTERN);
			} */
			updateRSS();
		}
		
		
		private function setBindings() :  void {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
		}
		
		private function onRemovedFromStage(event:Event) : void {
			for each(var watcher:ChangeWatcher in changeWatchersArr) {
				watcher.unwatch();
			}
		}
		
		protected function onResetToDefaultValues():void {
			Alert.show("Are you shure you want to reset all your settings?", "Warning", 3, this, onResetSettings);
			
		}
		
		private function onResetSettings(event:CloseEvent):void {
			
			if (event.detail==Alert.YES){
				rssAddress.text = DEFAULT_RSS;
				startIndex.text = String(DEFAULT_START_INDEX);
				maxResults.text = String(DEFAULT_MAX_RESULTS);
				brakeIdentifier.text = DEFAULT_BREAK_IDENTIFIER;
				//monthPattern.text = persistantData.getValue(PersistentConfigData.MONTH_STRING) as String;
				monthPattern.text = String(DEFAULT_MONTH_PATTERN);
				updateRssAddress();
				updateStartEntry();
				updateMaxResults();
				updateBreakIdentifier();
				//updateMonthString();
				
				updateRSS();
			}
		}
		
		public function updateRSS(v:Object = null) : void {
			requestTimer.reset();
			requestTimer.start();
		}
		
		public function loadRssData(event:TimerEvent = null) : void {
			if(rssAddress.text != "" && startIndex.text != "" && maxResults.text != "" ) {
				rssParser.loadRssData(rssAddress.text, Number(startIndex.text), Number(maxResults.text));
				rssParser.rssAddress = rssAddress.text;
				rssParser.startIndex = Number(startIndex.text);
				rssParser.maxResults = Number(maxResults.text);
				rssParser.brakeIdentifier = brakeIdentifier.text;
				//rssParser.monthPattern = monthPattern.text;
			}
		}
		
		protected function updateRssAddress() : void {
			persistantData.setValue(PersistentConfigData.RSS_ADDRESS, rssAddress.text);
		}
		
		protected function updateStartEntry() : void {
			persistantData.setValue(PersistentConfigData.START_RESULTS, startIndex.text);
		}
		
		protected function updateMaxResults() : void {
			persistantData.setValue(PersistentConfigData.MAX_RESULTS, maxResults.text);
		}
		
		protected function updateBreakIdentifier() : void {
			persistantData.setValue(PersistentConfigData.BREAK_IDENTIFIER, brakeIdentifier.text);
		}
		
		/* protected function updateMonthString() : void {
			persistantData.setValue(PersistentConfigData.MONTH_STRING, monthPattern.text);
		} */
	}
}