package com.qiaobutang.talk.reader.control {

	import flash.events.MouseEvent;
	import mx.controls.LinkButton;

	public class Link extends LinkButton {

		public function Link(){
			super();
			super.alpha = 0.0;
			super.setStyle("color", "0x3B5998");
		}
		
		override protected function rollOverHandler(event:MouseEvent):void {
			super.rollOverHandler(event);
			super.setStyle("textDecoration", "underline");
			super.setStyle("textRollOverColor", "0x0000BB");
		}
		
		override protected function rollOutHandler(event:MouseEvent):void {
			super.rollOutHandler(event);
			super.setStyle("textDecoration", "normal");
		}
	}
}


