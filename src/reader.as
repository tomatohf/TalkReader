import flash.display.StageScaleMode;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import mx.core.Application;
import mx.effects.AnimateProperty;

// configuratioin values
private var website:String = "http://qiaobutang.com";
[Bindable]
private var border_color:int = 808080;


private function init_app():void {
	Application.application.stage.scaleMode = StageScaleMode.NO_SCALE;
	
	content.width = Application.application.stage.width - 50;
	
	load_content();
}

private function load_content():void {
	content.htmlText = "1<br/>2<br/>3<br/>4<br/>5<br/>6<br/>7<br/>8<br/>9<br/>10<br/>" + 
			"11<br/>12<br/>13<br/>14<br/>15<br/>16<br/>17<br/>18<br/>19<br/>20<br/>" + 
			"31<br/>32<br/>33<br/>34<br/>35<br/>36<br/>37<br/>38<br/>39<br/>40<br/>";
	
	content.height = get_content_height() + 1000;
	
	setTimeout(scroll_to_top, 500);
}

private function logo_img_click():void {
	var url:URLRequest = new URLRequest(website + "/");
	navigateToURL(url, "_blank");
}

private function toggle_fullscreen():void {
	switch(Application.application.stage.displayState) {
		case StageDisplayState.FULL_SCREEN:
			Application.application.stage.displayState = StageDisplayState.NORMAL;
			fullscreen_btn.visible = true;
			fullscreen_btn.includeInLayout = true;
			normal_btn.visible = false;
			normal_btn.includeInLayout = false;
			break;
			
		default:
			Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;
			fullscreen_btn.visible = false;
			fullscreen_btn.includeInLayout = false;
			normal_btn.visible = true;
			normal_btn.includeInLayout = true;
			break;
	}
}

private function get_content_height():int {
	content.validateNow();
	
	var h:uint = 0;
	for(var i:int = 0; i < content.mx_internal::getTextField().numLines; i++) {
		var metrics:TextLineMetrics = content.mx_internal::getTextField().getLineMetrics(i);
		h += metrics.height + metrics.leading + 2;
	}
	
	return h;
}

private function scroll_to_top():void {
	var scroll:AnimateProperty = new AnimateProperty(content_container);
	scroll.property = "verticalScrollPosition";
	scroll.duration = 500;
	scroll.toValue = 0;
	scroll.play();
}

private function scale_content(step:int):void {
	content.scaleX += step / 100;
	content.scaleY += step / 100;
}
