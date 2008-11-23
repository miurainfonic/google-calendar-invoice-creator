package nl.diejongen.hours
{
	
	import flash.html.HTMLLoader;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.TabNavigator;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.List;
	import mx.controls.NumericStepper;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.printing.FlexPrintJob;
	
	import nl.diejongen.common.controls.dialog.Dialog;
	import nl.diejongen.hours.data.PersistentConfigData;
	import nl.diejongen.hours.data.RssData;

	public class InvoiceView_cb extends VBox
	{
		
		public static const INVOICE_WIDTH:int = 612;
		public static const INVOICE_HEIGHT:int = 848;
		
		private static const NO_CLIENT:String = "--no selection--";
		
		private static const DAY_VIEW:int = 0;
		private static const WEEK_VIEW:int = 1;
		
		public static var SPACE:String = 'space';
		public static var TAB:String = 'tab';
		public static var COMMA:String = 'comma';
		
		
		
		public var currentView:int = WEEK_VIEW;
		
		[Bindable]
		public var hoursRoot:HOURS;
		[Bindable]
		public var projectDataProvider:ArrayCollection;
		[Bindable]
		public var projectSelector:List;
		[Bindable]
		public var totalHours:Number;
		[Bindable]
		public var rssParser:GoogleCalendarRssParser;
		[Bindable]
		public var monthSelector:ComboBox;
		[Bindable]
		public var separatorCombo:ComboBox;
		[Bindable]
		public var currencyCB:ComboBox;
		[Bindable]
		public var rateInput:TextInput;
		[Bindable]
		public var vatInput:TextInput;
		[Bindable]
		public var currencyInput:TextInput;
		[Bindable]
		public var startDate:DateField;
		[Bindable]
		public var endDate:DateField;
		[Bindable]
		public var htmlWrapper:UIComponent;
		[Bindable]
		public var layout:TextArea;
		[Bindable]
		public var invoiceEntries:ArrayCollection;
		[Bindable]
		public var invoiceLayout:String;
		[Bindable]
		public var invoiceTableHeaders:String;
		[Bindable]
		public var currency:String;
		[Bindable]
		public var currencyHtml:String;
		[Bindable]
		public var vat:Number;
		[Bindable]
		public var rate:Number;
		[Bindable]
		public var summaryText:String;
		[Bindable]
		public var currencyDP:ArrayCollection;
		[Bindable]
		public var weekNumberOffset:Number;
		[Bindable]
		public var weekNoOffsetStepper:NumericStepper;
		[Bindable]
		public var invoiceTableHeadersInput:TextInput;
		[Bindable]
		public var dateFormat:String;
		[Bindable]
		public var dateFormatInput:TextInput;
		[Bindable]
		public var invoiceViewOffset:Number;
		[Bindable]
		public var tabNavigator:TabNavigator;
		[Bindable]
		public var resolutionDP:ArrayCollection;
		[Bindable]
		public var resolutionCombo:ComboBox;
		[Bindable]
		public var resolutionValue:int;
		
		private var persistantData:PersistentConfigData = PersistentConfigData.getInstance();
		private var summary:SummaryCreator;
		private var summaryHtml:SummaryHtmlCreator;
		private var html:HTMLLoader;
		private var _entries:ArrayCollection;
		private var invoiceHtmlString:String;
		
		public function InvoiceView_cb() {
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			summary = new SummaryCreator();
			summaryHtml = new SummaryHtmlCreator();
			currencyDP = new ArrayCollection([{label:"$", html:"$&nbsp;"},
											  {label:"€", html:"&euro;&nbsp;"},
											  {label:"£", html:"&pound;&nbsp;"},
											  {label:"¥", html:"&yen;&nbsp;"}])
			resolutionDP = new ArrayCollection([{label:"72 dpi", data:1},
											  {label:"144 dpi", data:2},
											  {label:"216 dpi", data:3}])
		}
		public function updateView() : void {
			
			if(invoiceEntries != null){
				invoiceEntries.filterFunction = filterEntries;
				invoiceEntries.refresh();
				sortOnDateArrayCollection(invoiceEntries);
			}
			
			totalHours = calcTotalHours();
			
										
			invoiceHtmlString = summaryHtml.getHtmlWeekSummary(invoiceLayout,
														duplicate(invoiceEntries), 
														rate,
														vat,
														currencyHtml,
														weekNumberOffset,
														invoiceTableHeaders,
														dateFormat);
			
			html.loadString(invoiceHtmlString); 
			
			summaryText = summary.getWeekSummary(duplicate(invoiceEntries), 
														SPACE, 
														invoiceTableHeaders, 
														rate, 
														vat, 
														currency,
														dateFormat,
														weekNumberOffset);
			
		}	
		
		[Bindable]
		public function set entries(v:ArrayCollection) : void {
			_entries = v;
			if(v != null){
				invoiceEntries = duplicate(v);
			}
			updateView();
		}
		public function get entries():ArrayCollection {
			return _entries;
		}	
		
		protected function addClientSelectorHandler() : void {
			var dialog:IFlexDisplayObject = Dialog.showDialog(ProjectSelectorDialog, true);
			(dialog as ProjectSelectorDialog).callBack = addClientSelectorDialogHandler;
		}
		
		protected function updateLayoutString():void {
			invoiceLayout = layout.text;
			persistantData.setValue(PersistentConfigData.INVOICE_LAYOUT, invoiceLayout);
			updateView();
		}
		
		protected function removeClientSelectorHandler() : void {
			for each ( var obj:Object in projectSelector.selectedItems) {
				projectDataProvider.removeItemAt(projectDataProvider.getItemIndex(obj));
			}
			persistantData.setValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY, projectDataProvider.source);
			if(projectDataProvider.length == 0){
				projectDataProvider = new ArrayCollection([{label:NO_CLIENT}]);
				projectSelector.selectable = false;
				persistantData.removeValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY);
			}
			updateView();
		}
		
		protected function onProjectSelectorChanged():void {
			clearSelectedProjectDP();
			for each(var obj:Object in projectSelector.selectedItems){
				obj.selected = true;
			}
			persistantData.setValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY, projectDataProvider.source);
			updateView();
		}
		
		private function clearSelectedProjectDP():void {
			for each(var obj:Object in projectDataProvider) {
				obj.selected = false;
			}
		}
		
		protected function onMonthSelectorChanged (event:Event) : void {
			var now:Date = new Date();
			startDate.selectedDate = new Date(now.fullYear, monthSelector.selectedItem.month);
			endDate.selectedDate = new Date(now.fullYear, monthSelector.selectedItem.month + 1, 0);
			updateView();
		}
		
		protected function onCurrencyChanged():void {
			currency = currencyCB.selectedItem.label;
			currencyHtml = currencyCB.selectedItem.html;
			persistantData.setValue(PersistentConfigData.CURRENCY, currencyCB.selectedItem);
			updateView();
		}
		
		protected function onWeekNoOffsetChanged():void {
			weekNumberOffset = weekNoOffsetStepper.value;
			persistantData.setValue(PersistentConfigData.WEEK_NUMBER_OFFSET, weekNumberOffset);
			updateView();
		}
		
		protected function onDateFormatChanged():void {
			dateFormat = dateFormatInput.text;
			persistantData.setValue(PersistentConfigData.DATE_FORMAT, dateFormat);
			updateView();
		}
		
		protected function onInvoiceTableHeadersChanged():void {
			invoiceTableHeaders = invoiceTableHeadersInput.text;
			persistantData.setValue(PersistentConfigData.INVOICE_TABLE_HEADERS, invoiceTableHeaders);
			updateView();
		}
		
		protected function onInvoiceViewChanged():void {
			invoiceViewOffset = tabNavigator.selectedIndex;
			persistantData.setValue(PersistentConfigData.INVOICE_VIEW_OFFSET, invoiceViewOffset);
			updateView();
		}
		
		protected function onVatChanged():void {
			vat = Number(vatInput.text);
			persistantData.setValue(PersistentConfigData.VAT, vat);
			updateView()
		}
		
		protected function onRateChanged():void {
			rate = Number(rateInput.text);
			persistantData.setValue(PersistentConfigData.RATE, rate);
			updateView();
		}
		
		protected function onResetToDefaultLayout():void {
			Alert.show("Are you shure you want to reset the settings?", "Warning", 3, this, resetSettings);
		}
		
		protected function onResolutionChanged():void {
			resolutionValue = resolutionCombo.selectedItem.data;
			initHtmlControl();
			persistantData.setValue(PersistentConfigData.RESOLUTION_VALUE, resolutionValue);
			updateView()
		}
		
		private function resetSettings(event:CloseEvent):void {
			if(event.detail == Alert.YES){
				invoiceLayout=InvoiceLayout.getDefaultLayout(resolutionValue);
				persistantData.setValue(PersistentConfigData.INVOICE_LAYOUT, invoiceLayout);
				persistantData.setValue(PersistentConfigData.RESOLUTION_VALUE, resolutionValue);
				updateView();
			}
		}
		
		protected function onResetToDefaultValuesProjects():void {
			Alert.show("Reset layout properties to default values?", "Warning", 3, this, resetDefaultLayoutProperties);
		}
		
		private function resetDefaultLayoutProperties(event:CloseEvent):void {
			if(event.detail == Alert.YES) {
				weekNumberOffset = InvoiceLayout.getDefaultWeekNoOffset();
				dateFormat = InvoiceLayout.getDefaultDateFormat();
				invoiceTableHeaders = InvoiceLayout.getDefaultTableHeaders();
				updateView();
			}
		}
		
		protected function onPrintInvoice():void {
            
			var printJob:FlexPrintJob = new FlexPrintJob();
			if (printJob.start()) {
				printJob.addObject( htmlWrapper );
				printJob.send();
			}
		}
		

		
		/**
		 * filters the projects of the user
		 */
		private function filterProjects(item:RssData) : Boolean {
			
			if(projectSelector.selectedItems.length == 0) return true;
			
			for each(var selectedItem:Object in projectSelector.selectedItems){
				var t:String = (item.title as String);
				var i:String = (selectedItem.label as String);
				if (t.toLowerCase().indexOf(i.toLowerCase()) != -1) {
					return true;
				}
			}
			
			return false;
		}
		
		private function onCreationComplete(event:FlexEvent) : void {
			
			initPersistentData();
			initHtmlControl()
			updateView();
		}
		
		private function initPersistentData() : void {
			
			if(persistantData.hasValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY)){
				projectDataProvider = new ArrayCollection(persistantData.getValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY) as Array);
				var arr:Array  = new Array();
				for each(var obj:Object in projectDataProvider){
					if(obj.selected == true){
						arr.push(obj);
					}
				}
				projectSelector.selectedItems = arr;
				
			}else{
				projectDataProvider = getDefaultProjectsDP();
				projectSelector.selectable = true;
			}
			
			if(persistantData.hasValue(PersistentConfigData.INVOICE_LAYOUT)){
				invoiceLayout = persistantData.getValue(PersistentConfigData.INVOICE_LAYOUT) as String;
			}else{
				invoiceLayout = InvoiceLayout.getDefaultLayout();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.INVOICE_TABLE_HEADERS)){
				invoiceTableHeaders = persistantData.getValue(PersistentConfigData.INVOICE_TABLE_HEADERS) as String;
			}else{
				invoiceTableHeaders = InvoiceLayout.getDefaultTableHeaders();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.CURRENCY)){
				var curObj:Object = persistantData.getValue(PersistentConfigData.CURRENCY) as Object;
				
				currency = curObj.label;
				currencyHtml = curObj.html;
				for each(var o:Object in currencyDP){
					if(o.label == currency){
						currencyCB.selectedItem = o;
						break;
					}
				}
			}else{
				currency = InvoiceLayout.getDefaultCurrency();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.VAT)){
				vat = persistantData.getValue(PersistentConfigData.VAT) as Number;
			}else{
				vat = InvoiceLayout.getDefaultVat();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.RATE)){
				rate = persistantData.getValue(PersistentConfigData.RATE) as Number;
			}else{
				rate = InvoiceLayout.getDefaultRate();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.WEEK_NUMBER_OFFSET)){
				weekNumberOffset = persistantData.getValue(PersistentConfigData.WEEK_NUMBER_OFFSET) as Number;
			}else{
				weekNumberOffset = InvoiceLayout.getDefaultWeekNoOffset();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.DATE_FORMAT)){
				dateFormat = persistantData.getValue(PersistentConfigData.DATE_FORMAT) as String;
			}else{
				dateFormat = InvoiceLayout.getDefaultDateFormat();
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.INVOICE_VIEW_OFFSET)){
				invoiceViewOffset = persistantData.getValue(PersistentConfigData.INVOICE_VIEW_OFFSET) as Number;
				tabNavigator.selectedIndex = invoiceViewOffset;
			}else{
				invoiceViewOffset = 0;
			}
			
			
			if(persistantData.hasValue(PersistentConfigData.RESOLUTION_VALUE)){
				resolutionValue = persistantData.getValue(PersistentConfigData.RESOLUTION_VALUE) as Number;
				resolutionCombo.selectedIndex = resolutionValue;
			}else{
				resolutionValue = 2;
			}
			
			resolutionCombo.selectedIndex=resolutionValue - 1;
			
			
		}	
		
		private function getDefaultProjectsDP():ArrayCollection {
			var arr:ArrayCollection = new ArrayCollection();
			arr.addItem({label:"Project 1"});
			arr.addItem({label:"Project 2"});
			return arr;
		}
			
		private function initHtmlControl() : void {
			if(html != null){
				htmlWrapper.removeChild(html);
			}
			html = new HTMLLoader();
			html.scaleX = 1/resolutionValue;
			html.scaleY = 1/resolutionValue;
           	html.width = resolutionValue * INVOICE_WIDTH;
            html.height = resolutionValue * INVOICE_HEIGHT;
            
            htmlWrapper.addChild(html);
		}
		
		/**
		 * filters dataprovider based on user input of type of project and period
		 */
		private function filterEntries(item:Object):Boolean {
			
			if(projectSelector && projectSelector.selectedItems != null && (item as RssData).title != null){
				
				return filterProjects(item as RssData) && filterMonth(item as RssData);
			}
			
			return true;
		}
		
		private function addClientSelectorDialogHandler(v:String) : void {
			if(!projectSelector.selectable){
				projectSelector.selectable = true;
				projectDataProvider = new ArrayCollection();
			}
			clearSelectedProjectDP();
			var obj:Object = {label: v, selected: true};
			projectDataProvider.addItem(obj);
			persistantData.setValue(PersistentConfigData.CLIENT_SELECTOR_ARRAY, projectDataProvider.source);
			projectSelector.selectedItem = obj;
			updateView();
		}
		
		/**
		 * filters the timeperiode to be shown
		 */
		private function filterMonth(item:RssData) :Boolean {
			
			//if(monthSelector.selectedItem.month == -1) return true;
			if (startDate.selectedDate == null || endDate.selectedDate == null) return true;
			
			return item.date.time >= startDate.selectedDate.time && item.date.time <= endDate.selectedDate.time;
		}
		
		private function calcTotalHours():Number {
			//calc total time
			var tot:Number = 0;
			var item:Object;
			for each(item in invoiceEntries) {
				tot += item.totalTime as Number;
			}
			return tot;
		}
		
		private function duplicate(ac:ArrayCollection) : ArrayCollection {
			
			var coll:ArrayCollection = new ArrayCollection();
			for each(var item:Object in ac) {
				coll.addItem(item);
			}
			return coll;
		}
		
		private function sortOnDateArrayCollection(dp:ArrayCollection): void {
			//sort data provider
			var s:Sort = new Sort();
			s.fields = [new SortField("date", false)];
			dp.sort = s;
			dp.refresh();
		}
	}
}