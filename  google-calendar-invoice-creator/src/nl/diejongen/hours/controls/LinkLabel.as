package nl.diejongen.hours.controls
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	import mx.controls.Label;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;

	public class LinkLabel extends Label
	{
		public static const DEFAULT_BLINK_COLOR:uint = 0xe8b900;
		
		private var underlineTextField:TextField;
		private var defaultFormat:TextFormat;
		private var _canvas:Canvas;
		private var _mouseOverUnderline:Boolean = true;
		private var _mouseOutUnderline:Boolean = false;
		private var _useHandCursor:Boolean = true;
		private var initializeText:Boolean = true;
		private var blinkingTimer:Timer = new Timer(1000);
		
		public var currentIndex:int;
		public var type:String;
		public var blinkingColor:uint = DEFAULT_BLINK_COLOR;
		
		public function LinkLabel()
		{
			super();
			blinkingTimer.addEventListener(TimerEvent.TIMER, toggleColor, false, 0, true);
			addEventListener(	Event.REMOVED_FROM_STAGE, 
								function () : void {blinkingTimer.removeEventListener(TimerEvent.TIMER, toggleColor)}, 
								false, 0, false);
		}
		
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			if(!_canvas)
			{
				
				_canvas = new Canvas();
				this.addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
				_canvas.buttonMode = _useHandCursor;
				_canvas.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
				_canvas.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				addChild(_canvas);
			}
			selectable = false;
	
		}
		
		private var _underline:Boolean;
		[Bindable]
		public function set underline(v:Boolean):void {
			_underline = v;
			if(v){
				setStyle('textDecoration', "underline");
			}else{
				setStyle('textDecoration', "none");
			}
		}
		public function get underline():Boolean {
			return _underline;
		}
		
		public function set canvasWidth(v:uint):void
		{
			_canvas.width = v;
		}
		public function get canvasWidth():uint
		{
			return _canvas.width;
		}
		
		[Bindable]
		public function get mouseOverUnderline():Boolean
		{
			return _mouseOverUnderline;
		}
		public function set mouseOverUnderline(v:Boolean):void
		{
			_mouseOverUnderline = v;
		}
		
		[Bindable]
		public function get mouseOutUnderline():Boolean
		{
			return _mouseOutUnderline;
		}
		public function set mouseOutUnderline(v:Boolean):void
		{
			_mouseOutUnderline = v;
		}
		
		[Bindable]
		override public function get useHandCursor():Boolean
		{
			return _useHandCursor;
		}
		override public function set useHandCursor(v:Boolean):void
		{
			_useHandCursor = v;
		}
		
		private var _blinking:Boolean;
		[Bindable]
		public function set blinking(v:Boolean) : void {
			_blinking = v;
			if(blinking) {
				blinkingTimer.start();
			}else{
				blinkingTimer.stop();
			}
		}
		public function get blinking() : Boolean {
			return _blinking;
		}
		
		private function toggleColor(event:TimerEvent = null):void {
			
			getStyle('color') == blinkingColor ? setStyle('color', 0x000000) : setStyle('color', blinkingColor);
		}
		
		private function updateCompleteHandler(event:FlexEvent):void
		{
			_canvas.width = textField.measuredWidth;
			_canvas.height = textField.measuredHeight;
			if(_mouseOutUnderline && initializeText){
				setStyle('textDecoration', "underline");
			}
			initializeText = false
		}
		
		private function overHandler(event:MouseEvent):void
		{
			if(enabled){
				if(mouseOverUnderline)
				{
					if(getStyle('textDecoration') != "underline")
					{
						setStyle('textDecoration', "underline");
					}
				}
				else
				{
					if(getStyle('textDecoration') != "none")
					{
						setStyle('textDecoration', "none");
					}
				}
			}
		}
		
		private function outHandler(event:MouseEvent):void
		{
			if(enabled){
				if(mouseOutUnderline)
				{
					if(getStyle('textDecoration') != "underline")
					{
						setStyle('textDecoration', "underline");
					}
				}
				else
				{
					if(getStyle('textDecoration') != "none")
					{
						setStyle('textDecoration', "none");
					}
				}
			}
		}
		
		
	}
}