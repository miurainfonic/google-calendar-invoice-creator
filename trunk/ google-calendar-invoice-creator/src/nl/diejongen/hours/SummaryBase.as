package nl.diejongen.hours
{
	import mx.collections.ArrayCollection;
	import nl.diejongen.hours.data.RssData;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	
	public class SummaryBase
	{
		public static var SUNDAY:int = 0;
		public static var MONDAY:int = 1;
		
		public var firstDayOfWeek:int = SUNDAY;
		
		protected var firstWorkingDay:Date;
		protected var lastWorkingDay:Date;
		
		/**
		 * creates a list of days in a week
		 */
		protected function fillGaps(entries:ArrayCollection) : ArrayCollection {
			
			var mergedEntries:ArrayCollection = createEmpty(entries);
			var i:int = 0;
			var l:int = mergedEntries.length;
			for each( var item:RssData in mergedEntries ) {
				var regData:RssData = new RssData();
				regData.date = item.date;
				regData.week = item.week;
				regData.totalTime = 0;
				for each (var entry:RssData in entries) {
					var iDate:Date = new Date(item.date.fullYear, item.date.month, item.date.date);
					var eDate:Date = new Date(entry.date.fullYear, entry.date.month, entry.date.date);
					if(iDate.time == eDate.time) {
						regData.totalTime += entry.totalTime;
						mergedEntries.setItemAt(regData, i);
					}
				}
				i++;
			}
			return mergedEntries;
		}

		protected function createEmpty(entries:ArrayCollection):ArrayCollection {
			
			sortOnDateArrayCollection(entries);
			var emptyDates:ArrayCollection = new ArrayCollection;
			
			if(entries.length > 0){
				var startDate:Date = firstWorkingDay = (entries.getItemAt(0) as RssData).date;
				var endDate:Date = lastWorkingDay = (entries.getItemAt(entries.length-1) as RssData).date;
				
				
				if(firstDayOfWeek == SUNDAY){
					var firstSunday : Date = new Date(startDate.fullYear, startDate.month, startDate.date - startDate.day);
					var lastSaturday: Date = new Date(endDate.fullYear, endDate.month, endDate.date + (6 - endDate.day));
					startDate = firstSunday;
					endDate = lastSaturday;
				}else{
					var dayCorrection:int = startDate.day == 0 ? -6 : 1 - startDate.day;
					var firstMonday : Date = new Date(startDate.fullYear, startDate.month, startDate.date + dayCorrection);
					var lastSunday: Date = new Date(endDate.fullYear, endDate.month, endDate.date + (7 - endDate.day));
					startDate = firstMonday;
					endDate = lastSunday;
				}
				
				var currentDate:Date = startDate;
				while(currentDate.time <= endDate.time) {
					var weekDate:Date = new Date(currentDate.fullYear, currentDate.month, currentDate.date);
					var Jan1:Date = new Date(currentDate.fullYear, 0, 1);
					var week:int = (weekDate.time - Jan1.time) / (7 * 24 * 60 * 60 * 1000) + 2;//TODO: waarom moet ik er 2 bij optellen?
					var regData:RssData = new RssData();
					regData.date = currentDate;
					regData.totalTime = 0;
					regData.week = week;
					emptyDates.addItem(regData);
					currentDate = new Date(currentDate.fullYear, currentDate.month, currentDate.date + 1);
				}
			}
			return emptyDates;
		}
		
		protected function sortOnDateArrayCollection(dp:ArrayCollection): void {
			//sort data provider
			var s:Sort = new Sort();
			s.fields = [new SortField("date", false)];
			dp.sort = s;
			dp.refresh();
		}
		
		protected function getSpaces (numb:int) :String {
			var spaces:String = "";
			if(numb <= 0) return spaces;
			while (numb--) {
				spaces += " ";
			}
			return spaces;
		}
		
		protected function getDayNamesArray(input:String):Array {
			var reg:RegExp = /days=(".*?"|'.*?')/;
			var arr:Array = input.match(reg);
			if(arr == null){
				//Alert.show("Could not find days attribute in <hours:summary/> tag");
				return null;
			}
			var temp:String = arr[0];
			reg = /(".*?"|'.*?')/;
			temp = temp.match(reg)[0];
			temp = temp.substring(1, temp.length - 1);
			arr = temp.split('|');
			if(arr.length != 7) {
				//Alert.show("Day prop in <hours:summary obliged. Days prop must have 7 days devided with a '|' character: days='su|mo|tu|we|th|fr|sa'.");
				return null;
			}else{
				return arr;
			}
		}
		
		protected function getAttribute(input:String, prop:String):String {
			var reg:RegExp = new RegExp(prop + "=(\".*?\"|'.*?')","");
			var arr:Array = input.match(reg);
			if(arr == null){
				return null;
			}
			var attribute:String = arr[0];
			reg = /(".*?"|'.*?')/;
			attribute = attribute.match(reg)[0];
			return attribute.substring(1, attribute.length - 1);
		}
		
		protected function getHoursSummaryTag(input:String):String {
			var reg:RegExp = /<hours:Summary.*\/>/;
			return input.match(reg)[0];
		}
		
		protected function replaceEmptyTag(input:String, tagName:String, replaceString:String):String {
			var reg:RegExp = new RegExp('<hours:' + tagName + '(( )*/>| .*?/>)', 'g');
			input = input.replace(reg, replaceString);
			return input;
		}
		
		protected function replaceHoursSummaryTags(input:String, hoursSummary:String):String{
			
			var reg:RegExp = /<hours:Summary.*?\/>/g;
			input = input.replace(reg, hoursSummary);			
			return input;
		}
	}
}