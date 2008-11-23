package nl.diejongen.hours
{
	import flash.text.FontStyle;
	
	public class InvoiceLayout
	{
		private static var fontSize:Array = [11,22,33];
		private static var padding:Array = [50,100,150];
		
		public static function getDefaultTableHeaders():String {
			
			return 'week|su|mo|tu|we|th|fr|sa|total';
		}
		
		
		public static function getDefaultCurrency():String {
			
			return '$';
		}
		
		public static function getDefaultLayout(resolutionValue:int = 2):String {
			return '<html>\n' +
					'<heading>\n' + 
					
						'\t<style type="text/css">\n' + 
						'\tbody{\n' + 
						'\tmargin:0;\n' + 
						'\tpadding:' + padding[resolutionValue - 1]+';\n' + 
						'\tfont-size:' + fontSize[resolutionValue - 1] + ';\n' + 
						'\tfont-family:sans-serif,Arial,Verdana;\n' + 
						'\t}\n' + 
						'\tdiv{\n' + 
						'\tposition:absolute;\n' + 
						'\tbottom:' + padding[resolutionValue - 1]+';\n' + 
						'\tright:' + padding[resolutionValue - 1]+';\n' + 
						'\tleft:' + padding[resolutionValue - 1]+';\n' + 
						'\ttext-align:center;\n' + 
						'\t}\n' + 
						'\ttable{\n' + 
						'\tfont-size:' + fontSize[resolutionValue - 1] + ';\n' + 
						'\t}\n' + 
						'\t</style>\n' + 

					'</heading>\n' +
					'<body>\n' +
						
						'\t<br/><br/><br/><br/><br/><br/><br/><br/>\n' +
						'\tCompany Name<br/>\n' +
						'\tAddress<br/>\n' +
						'\tCity, Zip<br/>\n' +
						'\t<h1>Invoice</h1>\n' +
						'\tnumber: Invoice number<br/>\n' +
						'\tdate: Invoice date<br/>\n' +
						'\t<br/><br/>\n' +
						'\t<hours:Summary/><br/>\n' +
						'\t<hours:TotalHours/> hours * <hours:Rate/> = <hours:NettoAmount/><br/>\n' +
						'\t<hours:Vat/>% over <hours:NettoAmount/> = <hours:VatAmount/><br/>\n' +
						'\tTOTAL: <hours:BrutoAmount/>\n' +
						'\t<br/><br/>\n' +
						'\t<div align="center">\n' +
							
								'\t\tAdditional Information: Address, Account number, Sales, Conditions of Sale, Warranty Information or other policies can be mentioned here.\n' +
							
						'\t</div>\n' +
					
					'</body>\n' +
					'</html>\n'
		}
		
		public static function getDefaultRate():Number {
			return 65;
		}
		
		public static function getDefaultVat():Number {
			return 19;
		}
		
		public static function getDefaultWeekNoOffset():Number {
			return 0;
		}
		
		public static function getDefaultDateFormat():String {
			return "MM/DD/YYYY";
		}
	}
}