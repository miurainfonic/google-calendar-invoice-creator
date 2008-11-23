package nl.diejongen.hours
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	
	import nl.diejongen.hours.data.RssData;
	
	public class SummaryHtmlCreator extends SummaryBase
	{
		
		/**
		 * returns a html formatted week summary
		 */
		public function getHtmlWeekSummary (invoiceLayout:String, 
											entries:ArrayCollection,
											rate:Number, 
											vat:Number, 
											currency:String,
											weekNumberOffset:Number,
											invoiceTableHeaders:String,
											dateFormat:String) : String {
			
			var weekSummary:String = "";
			
			var filledEntries:ArrayCollection = fillGaps(entries);
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = dateFormat;
			
			weekSummary += dateFormatter.format(firstWorkingDay) + ' - ' + dateFormatter.format(lastWorkingDay) + "<br/>";
			
			weekSummary += '<table borderColor="#dfdfdf" borderWidth="1" width="100%"><tr>';
			
			var hoursSummaryTag:String = getHoursSummaryTag(invoiceLayout);
			if(invoiceTableHeaders.indexOf('|') == -1){
				Alert.show("Invoice table headers string must be seperated with '|' character", "Error");
				return "";
			}
			var daysArr:Array = invoiceTableHeaders.split('|');
			if(daysArr.length != 9){
				Alert.show("Invoice table headers string must contain 9 elements in format: 'week|su|mo|tu|we|th|fr|sa|total'");
				return "";
			}
			
			for (var j:int = 0 ; j < daysArr.length ; j++) {
				weekSummary += '<th align="left">' + daysArr[j] + '</th>';
			}
			
			weekSummary += '</tr>';
			
			var i:int = 0;
			var weekTotal:Number = 0;
			var periodTotal:Number = 0;
			for each(var item:RssData in filledEntries) {
				
				if( i % 7 == 0) {
					weekSummary += '<tr><th align="left">' + (item.week + weekNumberOffset) + '</th>';
				}  
				
				weekSummary += '<td>' + item.totalTime + '</td>';
				weekTotal += item.totalTime;
				i++;
				if( i % 7 == 0) {
					weekSummary += '<th align="left">' + weekTotal +'</th></tr>';
					periodTotal += weekTotal;
					weekTotal = 0;
				}
			}
			//TODO: can't use colspan?
			weekSummary += '<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>';
			weekSummary += '<th align="left">'+periodTotal+'</th</tr></table><br/>';
			
			
			
			var formatter:CurrencyFormatter = new CurrencyFormatter();
			formatter.currencySymbol = currency;
			formatter.precision = 2;
			
			var nettoAmount:Number = Math.round(periodTotal * rate * 100)/100;
			var vatAmount:Number = Math.round(vat * nettoAmount)/100;
			var brutoAmount:Number = Math.round( (nettoAmount + vatAmount) * 100) / 100;
			
			invoiceLayout = replaceHoursSummaryTags(invoiceLayout, weekSummary);
			invoiceLayout = replaceEmptyTag(invoiceLayout, "TotalHours", String(periodTotal));
			invoiceLayout = replaceEmptyTag(invoiceLayout, "Rate", formatter.format(rate));
			invoiceLayout = replaceEmptyTag(invoiceLayout, "NettoAmount", formatter.format(nettoAmount));
			invoiceLayout = replaceEmptyTag(invoiceLayout, "Vat", String(vat));
			invoiceLayout = replaceEmptyTag(invoiceLayout, "VatAmount", formatter.format(vatAmount));
			invoiceLayout = replaceEmptyTag(invoiceLayout, "BrutoAmount", formatter.format(brutoAmount));
			return invoiceLayout;
		}

	}
}







