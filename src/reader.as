import flash.display.StageScaleMode;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import flexlib.controls.Highlighter;

import mx.core.Application;
import mx.effects.AnimateProperty;
import mx.managers.CursorManager;
import mx.utils.StringUtil;

// configuratioin values
private var website:String = "http://qiaobutang.com";
[Bindable]
private var app_bar_gap:int = 1;
[Embed(source="resources/moving_hand_cursor.png")]private var moving_hand_cursor:Class;


public var all_highlighter:Highlighter;
public var highlighter:Highlighter;


private function init_app():void {
	Application.application.stage.scaleMode = StageScaleMode.NO_SCALE;
	
	all_highlighter = new Highlighter(content.mx_internal::getTextField(), 0xFFFFFF00, 10, 10);
	highlighter = new Highlighter(content.mx_internal::getTextField(), 0xFF00FF00, 10, 10);
	
	observe_event();
	
	toggle_fullscreen_btn(false);
	
	load_content();
}

private function observe_event():void {
	Application.application.stage.addEventListener(
		FullScreenEvent.FULL_SCREEN,
		function(event:FullScreenEvent):void {
			toggle_fullscreen_btn(event.fullScreen);
		}
	);
	
	var mouse_wheel_handler:Function = function(event:MouseEvent):void {
		content_container.verticalScrollPosition -= event.delta * 10;
	}
	Application.application.stage.addEventListener(
		MouseEvent.MOUSE_WHEEL,
		mouse_wheel_handler
	);
	content_container.addEventListener(
		MouseEvent.MOUSE_WHEEL,
		mouse_wheel_handler
	);
	content.addEventListener(
		MouseEvent.MOUSE_WHEEL,
		mouse_wheel_handler
	);
	
	var double_handler:Function = function():void {
		toggle_fullscreen();
	}
	content_container.addEventListener(
		MouseEvent.DOUBLE_CLICK,
		double_handler
	);
	
	content_container.addEventListener(
		MouseEvent.MOUSE_DOWN,
		function():void {
			CursorManager.setCursor(moving_hand_cursor, 2, -8, -8);
		}
	);
	content_container.addEventListener(
		MouseEvent.MOUSE_UP,
		function():void {
			CursorManager.removeAllCursors();
		}
	);
}

private function load_content():void {
	content.htmlText = "1<br/>2<br/>3<br/>4<br/>5<br/>6<br/>7<br/>8<br/>9<br/>10<br/>" + 
			"11<br/>12<br/>13<br/>14<br/>15<br/>16<br/>17<br/>18<br/>19<br/>20<br/>" + 
			"<img src='http://qiaobutang.com/images/index/qiaobuquan_logo.png' />" + 
			"31<br/><font size='26'>32</font><br/>33<br/>34<br/>35<br/>36<br/>37<br/>38<br/>39<br/>40<br/>";
	
	content.height = get_content_height();
	
	setTimeout(scroll_to, 500, 0);
}

private function logo_img_click():void {
	var url:URLRequest = new URLRequest(website + "/");
	navigateToURL(url, "_blank");
}

private function toggle_fullscreen():void {
	switch(Application.application.stage.displayState) {
		case StageDisplayState.FULL_SCREEN:
			Application.application.stage.displayState = StageDisplayState.NORMAL;
			break;
			
		default:
			Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;
			break;
	}
}

private function toggle_fullscreen_btn(is_full:Boolean):void {
	fullscreen_btn.visible = !is_full;
	fullscreen_btn.includeInLayout = !is_full;
	normal_btn.visible = is_full;
	normal_btn.includeInLayout = is_full;
	
	content.width = (Application.application.stage.stageWidth - content_container.verticalScrollBar.width) / 1.1;
	
	app_bar_gap = is_full ? 10 : 1;
	search_box.width = is_full ? 300 : 75;
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

private function scroll_to(dest:int):void {
	var scroll:AnimateProperty = new AnimateProperty(content_container);
	scroll.property = "verticalScrollPosition";
	scroll.duration = 500;
	scroll.toValue = dest;
	scroll.play();
}

private function scale_content(step:int):void {
	content.scaleX += step / 100;
	content.scaleY = content.scaleX;
	
	big_btn.enabled = content.scaleX < 5;
	small_btn.enabled = content.scaleX > 0.2;
	
	highlighter.reset();
}

private function toggle_search_panel():void {
	if(search_panel.visible) {
		search_panel.visible = false;
		search_panel.includeInLayout = false;
	}
	else {
		search_panel.visible = true;
		search_panel.includeInLayout = true;
	}
}

private function search_next():void {
	var text:String = search_box.text;
	text = StringUtil.trim(text);
	
	highlighter.highlightNext(text, false);
}

private function search_pre():void {
	var text:String = search_box.text;
	text = StringUtil.trim(text);
	
	highlighter.highlightPrevious(text, false);
}

private function toggle_highlight_all():void {
	if(toggle_highlight_all_btn.selected){
		var text:String = search_box.text;
		text = StringUtil.trim(text);
	
		all_highlighter.highlightWordInstances(text, false);
	}
	else {
		all_highlighter.reset();
	}
}
