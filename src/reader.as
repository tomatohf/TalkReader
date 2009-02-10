import com.qiaobutang.talk.reader.Highlighter;

import flash.display.StageScaleMode;
import flash.events.ContextMenuEvent;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.setTimeout;

import mx.containers.TitleWindow;
import mx.controls.Label;
import mx.controls.Menu;
import mx.core.Application;
import mx.effects.AnimateProperty;
import mx.events.CloseEvent;
import mx.events.MenuEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.utils.StringUtil;

// configuratioin values
private var website:String = "http://qiaobutang.com";
[Bindable]
private var app_bar_gap:int = 1;

[Embed(source="resources/moving_hand_cursor.png")]private var moving_hand_cursor:Class;

[Embed(source="resources/more_icon.gif")]public var more_icon:Class;
[Embed(source="resources/comment_icon.gif")]public var comment_icon:Class;
[Embed(source="resources/share_icon.gif")]public var share_icon:Class;
[Embed(source="resources/embed_icon.gif")]public var embed_icon:Class;
[Embed(source="resources/help_icon.gif")]public var help_icon:Class;
[Embed(source="resources/about_icon.png")]public var about_icon:Class;


private var all_highlighter:Highlighter;
private var highlighter:Highlighter;

private var info_menu:Menu;

private var zoom_in_item:ContextMenuItem;
private var zoom_out_item:ContextMenuItem;
private var search_item:ContextMenuItem;
private var help_item:ContextMenuItem;

private var help_window:TitleWindow;


private function init_app():void {
	Application.application.stage.scaleMode = StageScaleMode.NO_SCALE;
	
	init_highlighter();
	init_menu();
	
	init_help_window();
	
	adjust_context_menu();
	
	observe_event();
	
	toggle_fullscreen_btn(false);
	
	load_content();
}

private function init_highlighter():void {
	all_highlighter = new Highlighter(content_container, content, 0xFFFFFF00, 10, 10);
	highlighter = new Highlighter(content_container, content, 0xFF00FF00, 10, 10);
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

private function init_help_window():void {
	help_window = TitleWindow(PopUpManager.createPopUp(this, TitleWindow, false));
	
	help_window.title = "帮助信息";
	help_window.titleIcon = help_icon;
	
	help_window.showCloseButton = true;
	help_window.addEventListener(
		CloseEvent.CLOSE,
		function():void {
			handle_help();
		}
	);
	
	help_window.width = 200;
	help_window.height = 220;
	
	help_window.visible = false;
	help_window.includeInLayout = false;
	
	
	help_window.layout = "vertical";
	
	var keys_label:Label = new Label();
	keys_label.text = "快捷键操作:";
	keys_label.setStyle("fontSize", 12);
	help_window.addChild(keys_label);
	
	var fullscreen_key_label:Label = new Label();
	fullscreen_key_label.text = "F        设置/取消全屏";
	help_window.addChild(fullscreen_key_label);
	
	var scrolldown_key_label:Label = new Label();
	scrolldown_key_label.text = "J        向下滚动";
	help_window.addChild(scrolldown_key_label);
	
	var scrollup_key_label:Label = new Label();
	scrollup_key_label.text = "K        向上滚动";
	help_window.addChild(scrollup_key_label);
	
	var zoomin_key_label:Label = new Label();
	zoomin_key_label.text = "]        放大";
	help_window.addChild(zoomin_key_label);
	
	var zoomout_key_label:Label = new Label();
	zoomout_key_label.text = "[        缩小";
	help_window.addChild(zoomout_key_label);
	
	var help_key_label:Label = new Label();
	help_key_label.text = "H        打开/关闭帮助";
	help_window.addChild(help_key_label);
}

private function adjust_context_menu():void {
	var context_menu:ContextMenu = Application.application.contextMenu;
	
	context_menu.hideBuiltInItems()
	
	zoom_in_item = new ContextMenuItem("放大");
	zoom_in_item.addEventListener(
		ContextMenuEvent.MENU_ITEM_SELECT,
		function():void {
			scale_content(10);
		}
	)
	context_menu.customItems.push(zoom_in_item);
	
	zoom_out_item = new ContextMenuItem("缩小");
	zoom_out_item.addEventListener(
		ContextMenuEvent.MENU_ITEM_SELECT,
		function():void {
			scale_content(-10);
		}
	)
	context_menu.customItems.push(zoom_out_item);
	
	search_item = new ContextMenuItem("搜索", true);
	search_item.addEventListener(
		ContextMenuEvent.MENU_ITEM_SELECT,
		function():void {
			toggle_search_panel();
		}
	)
	context_menu.customItems.push(search_item);
	
	help_item = new ContextMenuItem("帮助", true);
	help_item.addEventListener(
		ContextMenuEvent.MENU_ITEM_SELECT,
		function():void {
			handle_help();
		}
	)
	context_menu.customItems.push(help_item);
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
	);
	
	
	var keyboard_handler:Function = function(event:KeyboardEvent):void {
		if(Application.application.focusManager.getFocus() != null &&
			search_panel.contains(Application.application.focusManager.getFocus())) {
			return;
		}
		
		switch(event.keyCode) {
			// F
			case 70:
				toggle_fullscreen();
				break;
			// J
			case 74:
				scroll_content(100);
				break;
			// K
			case 75:
				scroll_content(-100);
				break;
			// ]
			case 221:
				if(big_btn.enabled) {
					scale_content(10);
				}
				break;
			// [
			case 219:
				if(small_btn.enabled) {
					scale_content(-10);
				}
				break;
			// H
			case 72:
				handle_help();
				break;
			default:
				break;
		}
	}
	Application.application.stage.addEventListener(
		KeyboardEvent.KEY_DOWN,
		keyboard_handler
	);
	content_container.addEventListener(
		KeyboardEvent.KEY_DOWN,
		keyboard_handler
	);
	content.addEventListener(
		KeyboardEvent.KEY_DOWN,
		keyboard_handler
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
		//h += metrics.height + metrics.leading + 2;
		h += metrics.height;
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

private function scroll_content(delta:int):void {
	scroll_to(content_container.verticalScrollPosition + delta);
}

private function scale_content(step:int):void {
	content.scaleX += step / 100;
	content.scaleY = content.scaleX;
	
	big_btn.enabled = content.scaleX < 5;
	small_btn.enabled = content.scaleX > 0.2;
	
	zoom_in_item.enabled = big_btn.enabled;
	zoom_out_item.enabled = small_btn.enabled;
	
	highlighter.reset();
}

private function toggle_search_panel():void {
	if(search_panel.visible) {
		search_panel.visible = false;
		search_panel.includeInLayout = false;
		
		highlighter.reset();
		all_highlighter.reset();
	}
	else {
		search_panel.visible = true;
		search_panel.includeInLayout = true;
		
		search_box.setFocus();
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
		case 1:
			handle_comment();
			break;
		case 3:
			handle_share();
			break;
		case 4:
			handle_embed();
			break;
		case 6:
			handle_help();
			break;
		case 7:
			handle_about();
			break;
		default:
			// do nothing ...
			break;
	}
}

private function handle_more():void {
	content.text = "more is clicked ... " + content.text;
}

private function handle_comment():void {
	content.text = "comment is clicked ... " + content.text;
}

private function handle_share():void {
	content.text = "share is clicked ... " + content.text;
}

private function handle_embed():void {
	content.text = "embed is clicked ... " + content.text;
}

private function handle_help():void {
	if(help_window.visible) {
		help_window.visible = false;
		help_window.includeInLayout = false;
	}
	else {
		help_window.visible = true;
		help_window.includeInLayout = true;
		
		position_help_window();
	}
}

private function handle_about():void {
	content.text = "about is clicked ... " + content.text;
}

private function position_help_window():void {
	help_window.x = (Application.application.stage.stageWidth - help_window.width) / 2;
	help_window.y = (Application.application.stage.stageHeight - help_window.height) / 2;
}
