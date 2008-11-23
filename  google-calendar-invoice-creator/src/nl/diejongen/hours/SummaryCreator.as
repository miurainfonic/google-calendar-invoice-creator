package nl.diejongen.hours
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	
	import nl.diejongen.hours.data.RssData;
	
	public class SummaryCreator extends SummaryBase
	{

		
		public function getSummaryRow(entries:ArrayCollection, totalHours:Number):String {
			
			
			var summaryTxt:String;
			//init summaryArea text
			summaryTxt = "dag\turen\n";
			
			//sort data provider
			var s:Sort = new Sort();
			s.fields = [new SortField("date", false)];
			entries.sort = s;
			entries.refresh();
			
			//collect day totals
			var prevD:Date;
			var dayTot:Number;
			var dateArr:Array = new Array();
			var item:Object;
			for each(item in entries) {
				
				var d:Date = item.date;
				if(prevD && prevD.time == d.time){
					dayTot += item.totalTime;
					dateArr[dateArr.length - 1] = d.date + "/" + (d.month + 1) + ":\t" + dayTot + "\n";
				}else if(d){
					dayTot = item.totalTime;
					dateArr.push(d.date + "/" + (d.month + 1) + ":\t" + dayTot + "\n");
				}
				prevD = d
			}
			
			for each(var str:String in dateArr) {
				summaryTxt += str;
			}
			
			summaryTxt += "-------------+\n";
			summaryTxt += "totaal:\t" + totalHours + "\n";
			
			return summaryTxt;
		}
		
		public function getWeekSummary (entries:ArrayCollection, 
										separator:String, 
										daysOfWeek:String, 
										rate:Number, 
										vat:Number, 
										currency:String, 
										dateFormat:String, 
										weekNumberOffset:Number) : String {
										
			//currency = "€";
			var weekSummary:String = "";
			
			var filledEntries:ArrayCollection = fillGaps(entries);
			
			var daysArr:Array = daysOfWeek.split('|');
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = dateFormat;
			
			weekSummary += dateFormatter.format(firstWorkingDay) + ' - ' + dateFormatter.format(lastWorkingDay) + '\n\n';
			
			
			for (var i:int = 0 ; i < daysArr.length ; i++) {
				weekSummary += daysArr[i];
				if(separator == InvoiceView_cb.SPACE){
					weekSummary += getSpaces(5 - (daysArr[i] as String).length);
				}else if(separator == InvoiceView_cb.TAB){
					weekSummary += "\t";
				}else{
					weekSummary += ",";
				} 
			} 
			weekSummary += "\n";
			
			i = 0;
			var weekTotal:Number = 0;
			var periodTotal:Number = 0;
			for each(var item:RssData in filledEntries) {
				
				if( i % 7 == 0) {
					weekSummary += (item.week + weekNumberOffset);
					if(separator == InvoiceView_cb.SPACE){
						weekSummary += getSpaces(3);
					}else if(separator == InvoiceView_cb.TAB){
						weekSummary += "\t";
					}else{
						weekSummary += ",";
					}
				}  
				
				weekSummary += item.totalTime;
				weekTotal += item.totalTime;
				if(separator == InvoiceView_cb.SPACE){
					var spaceLength:int = (4 - item.totalTime.toString().length);
					while(spaceLength-- >= 0) {
						weekSummary += " ";
					}
				}else if(separator == InvoiceView_cb.TAB){
					weekSummary += "\t";
				}else{
					weekSummary += ",";
				}
				i++;
				if( i % 7 == 0) {
					weekSummary += weekTotal + "\n";
					periodTotal += weekTotal;
					weekTotal = 0;
				}
			} 
			if(separator == InvoiceView_cb.SPACE){
				var line:String = "--------------------------------------------"
				weekSummary += line + "\n";
				for (var j:int = 0; j < line.length - periodTotal.toString().length; j++ ){
					weekSummary += " ";
				}
			}
			
			weekSummary += periodTotal + "\n\n";
			
			
			var formatter:CurrencyFormatter = new CurrencyFormatter();
			formatter.currencySymbol = currency;
			formatter.precision = 2;
			
			var nettoAmount:Number = Math.round(periodTotal * rate * 100)/100;
			weekSummary += periodTotal + " * " + formatter.format(rate) + " = " + formatter.format(nettoAmount) + "\n";
			var vatAmount:Number = Math.round(vat * nettoAmount)/100;
			weekSummary += vat + "% * " + formatter.format(nettoAmount) + " = " + formatter.format(vatAmount) + "\n";
			var total:Number = Math.round( (nettoAmount + vatAmount) * 100) / 100;
			weekSummary += daysArr[8] + ": " + formatter.format(total);
			return weekSummary;
		}
		

	}
}







