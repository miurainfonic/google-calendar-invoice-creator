package nl.diejongen.hours.data
{
	import nl.diejongen.common.data.PersistentData;
	
	public class PersistentConfigData extends PersistentData
	{
		private static var instance:PersistentConfigData;
		
		public static const RSS_ADDRESS:String = "rssAddress";
		public static const BREAK_IDENTIFIER:String = "brakeIdentifier";
		public static const START_RESULTS:String = "startResults";
		public static const MAX_RESULTS:String = "maxResults";
		//public static const MONTH_STRING:String = "monthString";
		public static const CLIENT_SELECTOR_ARRAY:String = "clientSelectorArray";
		public static const BROWSER_URL:String = "browserUrl";
		public static const INVOICE_LAYOUT:String = "invoiceLayout";
		public static const INVOICE_TABLE_HEADERS:String = "invoiceTableHeaders";
		public static const CURRENCY:String = "currency";
		public static const VAT:String = "vat";
		public static const RATE:String = "rate";
		public static const WEEK_NUMBER_OFFSET:String = "weekNumberOffset";
		public static const HOURS_TABLE_STRING:String = "hoursTableString";
		public static const DATE_FORMAT:String = "dateFormat";
		public static const INVOICE_VIEW_OFFSET:String = "invoiceViewOffset";
		public static const RESOLUTION_VALUE:String = "resolutionValue";
		public static const AUTO_CHECK_UPDATE:String = "autoCheckUpdate";
		public static const WINDOW_RECTANGLE:String = "windowRectangle";
		public static const MAXIMIZED:String = "maximized";
		
		public function PersistentConfigData()
		{
			super("ConfigData");
			if ( instance != null ){
				throw new Error( "Class not created as singleton.", "PersistentConfigData" );
			}
			instance = this;
		}
		
		public static function getInstance() : PersistentConfigData {
			if ( instance == null ) {
				new PersistentConfigData();
			}
			return instance;
		}
		
	}
}