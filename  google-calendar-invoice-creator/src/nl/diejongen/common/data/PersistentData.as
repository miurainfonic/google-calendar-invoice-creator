package nl.diejongen.common.data
{
	import flash.net.SharedObject;
	import flash.events.ErrorEvent;
	
	public class PersistentData
	{
		private var name:String;
		private var so:SharedObject;
		
		public function PersistentData(name:String):void
		{
			if(name != ''){
				this.name = name;
				init();
			}else{
				throw new Error("Can not retrieve nameless SO.");
			}
		}
		
		private function init():void
		{
			so = SharedObject.getLocal(name);
		}
		
		public function setValue(name:String, value:Object):void
		{
			so.data[name] = value;
			so.flush();
		}
		
		public function getValue(name:String):Object
		{
			return so.data[name];
		}
		
		public function removeValue(name:String):Boolean
		{
			if(hasValue(name)){
				delete so.data[name];
				so.flush();
				return true;
			}else{
				return false;
			}
		}
		
		public function hasValue(name:String):Boolean
		{
			return (so.data[name] != undefined);
		}
	
		
	}
}