package nl.diejongen.common.version
{
	import com.everythingflex.air.managers.UpdateManager;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;

	public class HoursUpdateManager extends UIComponent
	{
		[Bindable]
		public var url:String;
		
		public function checkForUpdate():void {
			var um:UpdateManager = new UpdateManager(url, false);
			um.checkForUpdate();
		}
		
	}
}