package nl.diejongen.common.controls.dialog
{
	import mx.containers.TitleWindow;
	import flash.events.Event;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.effects.Fade;
	import mx.managers.PopUpManager;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import flash.display.DisplayObject;
	import mx.effects.Resize;
	import mx.effects.Move;
	import mx.core.Application;

	public class Dialog extends TitleWindow
	{
		
		public function Dialog() {
			showCloseButton = true;
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			addEventListener(Event.CLOSE, closeDialog);
		}
		
		public function onCreationComplete(event:FlexEvent):void {
			fadeIn();
		}
		
		private function fadeIn():void {
			var fadeIn:Fade = new Fade(this);
			fadeIn.alphaFrom = 0.5;
			fadeIn.duration = 500;
			
			fadeIn.alphaTo = 1;
			fadeIn.play(); 
		}
		
		public function closeDialog(event:Event):void {
			fadeOut();
		}
		
		private function fadeOut():void {
			var fadeOut:Fade = new Fade(this);
			fadeOut.alphaFrom = 1;
			fadeOut.alphaTo = 0.5;
			fadeOut.addEventListener(EffectEvent.EFFECT_END, removePopup);
			fadeOut.play();
		}
		
		private function removePopup(event:Event):void {
			PopUpManager.removePopUp(this);
		}
		
		
		public static function showDialog(dialog:Class, modal:Boolean, target:DisplayObject = null):IFlexDisplayObject {
			if (target == null) target = Application.application as DisplayObject;
			var popup:IFlexDisplayObject =  PopUpManager.createPopUp( target , dialog, modal);
			PopUpManager.centerPopUp(popup);
			return popup;
		}
	}
}