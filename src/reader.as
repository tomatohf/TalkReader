import flash.display.StageScaleMode;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import flexlib.controls.Highlighter;

import mx.controls.Menu;
import mx.core.Application;
import mx.effects.AnimateProperty;
import mx.events.MenuEvent;
import mx.managers.CursorManager;
import mx.utils.StringUtil;

// configuratioin values
private var website:String = "http://qiaobutang.com";
[Bindable]
private var app_bar_gap:int = 1;

[Embed(source="resources/moving_hand_cursor.png")]private var moving_hand_cursor:Class;

[Embed(source="resources/more_icon.gif")]public var more_icon:Class;
[Embed(source="resources/share_icon.gif")]public var share_icon:Class;
[Embed(source="resources/embed_icon.gif")]public var embed_icon:Class;
[Embed(source="resources/help_icon.gif")]public var help_icon:Class;
[Embed(source="resources/about_icon.png")]public var about_icon:Class;


private var all_highlighter:Highlighter;
private var highlighter:Highlighter;

private var info_menu:Menu;


private function init_app():void {
	Application.application.stage.scaleMode = StageScaleMode.NO_SCALE;
	
	init_highlighter();
	init_menu();
	
	observe_event();
	
	toggle_fullscreen_btn(false);
	
	load_content();
}

private function init_highlighter():void {
	all_highlighter = new Highlighter(content.mx_internal::getTextField(), 0xFFFFFF00, 10, 10);
	highlighter = new Highlighter(content.mx_internal::getTextField(), 0xFF00FF00, 10, 10);
}

private function init_menu():void {
	info_menu = Menu.createMenu(null, info_menu_provider, false);
	
	info_menu.labelField = "@label";
	info_menu.iconField = "@icon";
	info_menu.variableRowHeight = true;
	
	info_menu.setStyle("fontSize", 12);
	info_menu.setStyle("backgroundColor", "#DDDDDD");
	info_menu.setStyle("openDuration", 150);
	info_menu.setStyle("themeColor", "black");
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
	
	info_menu.addEventListener(
		MenuEvent.ITEM_CLICK,
		function(event:MenuEvent):void {
			handle_info_menu_item(event.index);
		}
	)
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

private function show_info_menu():void {
	info_menu.show(info_menu_btn.x - 30, info_menu_btn.y + info_menu_btn.height + 5);
}

private function handle_info_menu_item(item_index:int):void {
	switch(item_index) {
		case 0:
			handle_more();
			break;
		case 2:
			handle_share();
			break;
		case 3:
			handle_embed();
			break;
		case 5:
			handle_help();
			break;
		case 6:
			handle_about();
			break;
		default:
			// do nothing ...
			break;
	}
}

private function handle_more():void {
	content.text += "more is clicked ... ";
}

private function handle_share():void {
	content.text += "share is clicked ... ";
}

private function handle_embed():void {
	content.text += "embed is clicked ... ";
}

private function handle_help():void {
	content.text += "help is clicked ... ";
}

private function handle_about():void {
	content.text += "about is clicked ... ";
}
