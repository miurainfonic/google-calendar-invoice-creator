package nl.diejongen.common.util
{
	import flash.utils.getQualifiedClassName;
	
	public class Logger
	{
		private static const IDRIVE:String = "FLEX";
		public static const ERROR:String = "ERROR";
		public static const INFO:String = "INFO";
		public static const WARNING:String = "WARNING";
		
		public static function log(type:String, cl:Object, message:String):void {
			
			var className:String = getQualifiedClassName(cl).replace("::", ".");
			var arr:Array = className.split(".");
			trace( IDRIVE + " " + type + ", " + arr[arr.length-1] + ", message: " + message + ", path: " + className); 
			
		}
		
	}
}