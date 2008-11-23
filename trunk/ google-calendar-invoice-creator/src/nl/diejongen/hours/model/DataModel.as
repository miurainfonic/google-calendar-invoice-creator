package nl.diejongen.hours.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class DataModel 
	{
		private static var instance:DataModel = new DataModel;
		
		public var entries:ArrayCollection;
		
		public var projects:ArrayCollection;
		
		function DataModel() {
			if(instance) {
				throw new Error('create singlton with getInstance()');
			}
		}
		
		public static function getInstance() : DataModel {
			return instance;
		}
	}
}