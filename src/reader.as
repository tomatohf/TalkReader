import com.qiaobutang.talk.reader.Highlighter;

import flash.display.StageScaleMode;
import flash.events.ContextMenuEvent;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.navigateToURL;
import flash.text.StyleSheet;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.setTimeout;

import mx.containers.TitleWindow;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.LinkButton;
import mx.controls.Spacer;
import mx.core.Application;
import mx.effects.AnimateProperty;
import mx.events.CloseEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;

// configuratioin values
[Bindable]private var toolbar_gap:int = 2;

[Embed(source="resources/moving_hand_cursor.png")]private var moving_hand_cursor:Class;

[Bindable][Embed(source="resources/more_icon.gif")]public var more_icon:Class;
[Bindable][Embed(source="resources/comment_icon.gif")]public var comment_icon:Class;
[Bindable][Embed(source="resources/embed_icon.gif")]public var embed_icon:Class;
[Bindable][Embed(source="resources/help_icon.png")]public var help_icon:Class;
[Bindable][Embed(source="resources/about_icon.png")]public var about_icon:Class;


private var talk_id:uint = 0;

private var all_highlighter:Highlighter;
private var highlighter:Highlighter;

private var zoom_in_item:ContextMenuItem;
private var zoom_out_item:ContextMenuItem;
private var search_item:ContextMenuItem;
private var help_item:ContextMenuItem;

private var embed_window:TitleWindow = null;
private var help_window:TitleWindow = null;
private var about_window:TitleWindow = null;

private var loading_window:TitleWindow = null;


private function init_app():void {
	show_loading_window();
	
	Application.application.stage.scaleMode = StageScaleMode.NO_SCALE;
	
	update_content_height(1000);
	
	if(Application.application.loaderInfo.loaderURL.indexOf("file") == 0) {
		// local ...
		talk_show_service.endpoint = "http://localhost:3002/weborb";
		talk_id = 1001;
	}
	
	// handle_parameters
	if(application.parameters.talk != null){
		talk_id = application.parameters.talk;
	}
	if(talk_id <= 0){
		on_fault(null);
		return;
	}
	
	init_highlighter();
	
	adjust_context_menu();
	
	observe_event();
	
	toggle_fullscreen_btn(false);
	
	init_content_styles();
	
	load_content();
}

private function init_content_styles():void {
	var ss:StyleSheet = new StyleSheet();
	
	ss.setStyle(
		"a",
		{
			color: "#3B5998",
			textDecoration: "underline"
		}
	);
	
	ss.setStyle(
		"a:hover",
		{
			color: "#FF6600"
		}
	);
	
	ss.setStyle(
		"a:active",
		{
			textDecoration: "none"
		}
	);

	content.styleSheet = ss;
}

private function init_highlighter():void {
	all_highlighter = new Highlighter(content_container, content, 0xFFFFFF00, 30, 10);
	highlighter = new Highlighter(content_container, content, 0xFF00FF00, 30, 10);
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
	help_window.height = 300;
	
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
	
	var scrolltop_key_label:Label = new Label();
	scrolltop_key_label.text = "T        滚动到顶";
	help_window.addChild(scrolltop_key_label);
	
	var scrollbottom_key_label:Label = new Label();
	scrollbottom_key_label.text = "B        滚动到底";
	help_window.addChild(scrollbottom_key_label);
	
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

private function init_about_window():void {
	about_window = TitleWindow(PopUpManager.createPopUp(this, TitleWindow, true));
	
	about_window.title = "关于乔布堂周三访谈录";
	about_window.titleIcon = about_icon;
	
	about_window.showCloseButton = true;
	about_window.addEventListener(
		CloseEvent.CLOSE,
		function():void {
			handle_about();
		}
	);
	
	about_window.width = 250;
	about_window.height = 300;
	
	about_window.visible = false;
	about_window.includeInLayout = false;
	
	
	about_window.layout = "vertical";
	
	var logo_image:Image = new Image();
	logo_image.source = logo_img.source;
	about_window.addChild(logo_image);
	
	var qiaobutang_talk_link_url:String = "talks.qiaobutang.com";
	var qiaobutang_talk_link:LinkButton = new LinkButton();
	qiaobutang_talk_link.label = qiaobutang_talk_link_url;
	qiaobutang_talk_link.addEventListener(
		MouseEvent.CLICK,
		function():void {
			navigateToURL(new URLRequest("http://" + qiaobutang_talk_link_url), "_blank");
		}
	);
	about_window.addChild(qiaobutang_talk_link);
	
	var space:Spacer = new Spacer();
	space.height = 20;
	about_window.addChild(space);
	
	var qiaobutang_label:Label = new Label();
	qiaobutang_label.text = "乔布堂";
	about_window.addChild(qiaobutang_label);
	
	var qiaobutang_link_url:String = "www.qiaobutang.com";
	var qiaobutang_link:LinkButton = new LinkButton();
	qiaobutang_link.label = qiaobutang_link_url;
	qiaobutang_link.addEventListener(
		MouseEvent.CLICK,
		function():void {
			navigateToURL(new URLRequest("http://" + qiaobutang_link_url), "_blank");
		}
	);
	about_window.addChild(qiaobutang_link);
	
	var qiaobuquan_label:Label = new Label();
	qiaobuquan_label.text = "乔布圈";
	about_window.addChild(qiaobuquan_label);
	
	var qiaobuquan_link_url:String = "www.qiaobuquan.com";
	var qiaobuquan_link:LinkButton = new LinkButton();
	qiaobuquan_link.label = qiaobuquan_link_url;
	qiaobuquan_link.addEventListener(
		MouseEvent.CLICK,
		function():void {
			navigateToURL(new URLRequest("http://" + qiaobuquan_link_url), "_blank");
		}
	);
	about_window.addChild(qiaobuquan_link);
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
			// T
			case 84:
				set_scroll_position(0);
				break;
			// B
			case 66:
				set_scroll_position(content_container.maxVerticalScrollPosition);
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
	talk_show_service.show(talk_id);
}

private function on_got_content(event:ResultEvent):void {
	hide_loading_window();
	
	
	if(event.result == "") {
		return on_fault(null);
	}
	
	layout_content(event.result);
	
	update_content_height();
	
	setTimeout(scroll_to, 500, 0);
}

private function layout_content(talk_content:Object):void {
	content.htmlText = "";
	
	// add title
	content.htmlText += paragraph_text(bold_text(font_text(talk_content.title, 20)), "center");
	content.htmlText += "<br />";
	
	// add desc
	content.htmlText += paragraph_text(italic_text(font_text("写在前面:", 12, "#555555")));
	content.htmlText += "<br />";
	var descs:Array = multiple_lines(talk_content.desc);
	for(var desc_i:int = 0; desc_i < descs.length; desc_i++) {
		content.htmlText += paragraph_text("    " + font_text(descs[desc_i], 12, "#555555", "黑体"));
	}
	
	
	var talkers:Object = talk_content.talkers;
	var categories:Object = talk_content.categories;
	
	var current_category:Object = new Object();
	var questions:Array = talk_content.questions;
	for(var i:int = 0; i < questions.length; i++) {
		var question:Object = questions[i];
		
		if(question.category_id != current_category.id) {
			// should handle category
			var category:Object = categories["category_" + question.category_id];
			if(category != null) {
				// should display category info
				content.htmlText += "<br /><br />";

				content.htmlText += paragraph_text(bold_text(font_text(category.name, 18)));
				
				var category_descs:Array = multiple_lines(category.desc);
				for(var category_desc_i:int = 0; category_desc_i < category_descs.length; category_desc_i++) {
					content.htmlText += list_text(italic_text(font_text(category_descs[category_desc_i], 0, "#555555")));
				}
				
				content.htmlText += "<br />";
			}
			
			current_category = category;
		}
		
		// add question
		content.htmlText += paragraph_text(font_text(bold_text("乔布堂:" + "  " + question.question), 0, "#FF6600"));
		
		// add answers
		var answers:Array = question.answers;
		for(var j:int = 0; j < answers.length; j++) {
			var answer:Object = answers[j];
			
			// add answer
			content.htmlText += paragraph_text(
				bold_text(talkers["talker_" + answer.talker_id].name + ":") + 
				"  " + 
				answer.answer
			);
		}
		
		//content.htmlText += "<br />";
	}
	
	
	// add end icon
	content.htmlText += image_content("http://localhost:3002/images/index/talk_icon.png");
	
	
	// add publish time
	content.htmlText += "<br />";
	content.htmlText += paragraph_text(
		italic_text(
			font_text(talk_content.publish_time + " 发布", 10)
		),
		"right"
	);
	
	
	// add copyright
	content.htmlText += "<br />";
	content.htmlText += paragraph_text(
		font_text(
			"Copyright © " + 
			link_text(
				font_text("乔布堂", 12),
				"http://www.qiaobutang.com"
			),
			10
		),
		"right"
	);
	content.htmlText += paragraph_text(
		font_text(
			"All rights reserved",
			10
		),
		"right"
	);
}

private function multiple_lines(text:String):Array {
	var results:Array = new Array();
	
	if(text != null && text != "") {
		var lines:Array = text.split("\n");
		for(var k:int = 0; k < lines.length; k++) {
			var line:String = StringUtil.trim(lines[k]);
			if(line != null && line != "") {
				results.push(line);
			}
		}
	}
	
	return results;
}

private function bold_text(text:String):String {
	return "<b>" +
				text +  
			"</b>";
}

private function italic_text(text:String):String {
	return "<i>" +
				text +  
			"</i>";
}

private function link_text(text:String, href:String):String {
	return "<a" +
			" href='" + href + "'" + 
			" target='_blank'" + 
			">" +
				text +  
			"</a>";
}

private function list_text(text:String):String {
	return "<li>" +
				text +  
			"</li>";
}

private function paragraph_text(text:String, align:String = null):String {
	return "<p" +
			((align == null) ? "" : " align='" + align + "'") + 
			">" +
				text +  
			"</p>";
}

private function font_text(text:String, size:int = 0, color:String = null, face:String = null):String {
	return "<font" +
			((size == 0) ? "" : " size='" + size + "'") + 
			((color == null) ? "" : " color='" + color + "'") +
			((face == null) ? "" : " face='" + face + "'") + 
			">" +
				text +  
			"</font>";
}

private function image_content(src:String, align:String = null, id:String = null, vspace:String = null, hspace:String = null):String {
	return "<img" +
			" src='" + src + "'" + 	
			((align == null) ? "" : " align='" + align + "'") +
			((id == null) ? "" : " id='" + id + "'") + 
			((vspace == null) ? "" : " vspace='" + vspace + "'") +
			((hspace == null) ? "" : " hspace='" + hspace + "'") + 
			" />";
}

private function show_loading_window():void {
	if(loading_window == null) {
		loading_window = TitleWindow(PopUpManager.createPopUp(this, TitleWindow, true));
		
		loading_window.showCloseButton = false;
		
		loading_window.width = Application.application.stage.stageWidth;
		loading_window.title = "正在读取访谈录 ...";
		
		loading_window.setStyle("cornerRadius", 0);
		loading_window.setStyle("backgroundColor", "#FFFDC0");
		loading_window.setStyle("borderColor", "#FFFDC0");
		loading_window.setStyle("borderAlpha", 1.0);
	}

	loading_window.includeInLayout = true;
	loading_window.visible = true;
}

private function hide_loading_window():void {
	loading_window.visible = false;
	loading_window.includeInLayout = false;
}

private function on_fault(event:FaultEvent):void {
	hide_loading_window();
	
	
	var fault_window:TitleWindow = TitleWindow(PopUpManager.createPopUp(this, TitleWindow, true));
	
	fault_window.showCloseButton = false;
	
	fault_window.width = Application.application.stage.stageWidth;
	fault_window.title = "发生错误, 读取数据失败 ...";
	
	fault_window.setStyle("cornerRadius", 0);
	fault_window.setStyle("backgroundColor", "red");
	fault_window.setStyle("borderColor", "red");
	fault_window.setStyle("borderAlpha", 1.0);
}

private function logo_img_click():void {
	var url:URLRequest = new URLRequest("http://talks.qiaobutang.com");
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
	
	toolbar_gap = is_full ? 20 : 2;
	search_box.width = is_full ? 300 : 75;
	
	content.width = (Application.application.stage.stageWidth - content_container.verticalScrollBar.width) / 1.1;
	
	update_content_height();
}

private function update_content_height(height:int = 0):void {
	if(height <= 0) {
		height = get_content_height();
	}
	
	content.height = height * content.scaleY + 1000;
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

private function set_scroll_position(position:int):void {
	content_container.verticalScrollPosition = position;
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
	
	toggle_highlight_all_btn.selected = false;
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

private function handle_more():void {
	var url:URLRequest = new URLRequest("http://talks.qiaobutang.com");
	navigateToURL(url, "_blank");
}

private function handle_comment():void {
	var url:URLRequest = new URLRequest("http://www.qiaobutang.com/talks/" + talk_id + "#comment_list");
	navigateToURL(url, "_blank");
}

private function handle_embed():void {
	if(embed_window == null) {
		embed_window = TitleWindow(PopUpManager.createPopUp(this, TitleWindow, true));
	
		embed_window.title = "引用和转载的嵌入代码";
		embed_window.titleIcon = embed_icon;
		
		embed_window.showCloseButton = true;
		embed_window.addEventListener(
			CloseEvent.CLOSE,
			function():void {
				handle_embed();
			}
		);
	
		embed_window.width = 250;
		embed_window.height = 380;
	
		embed_window.visible = false;
		embed_window.includeInLayout = false;
	
	
		embed_window.layout = "vertical";
		
		var flash_address_label:Label = new Label();
		flash_address_label.text = "flash 地址:";
		flash_address_label.setStyle("fontWeight", "bold");
		embed_window.addChild(flash_address_label);
		
		var flash_address_text:TextArea = new TextArea();
		flash_address_text.text = "http://www.qiaobutang.com/swf/TalkReader.swf?talk=" + talk_id;
		flash_address_text.width = 210;
		flash_address_text.height = 50;
		flash_address_text.editable = false;
		flash_address_text.wordWrap = true;
		flash_address_text.addEventListener(MouseEvent.CLICK,
			function():void {
				flash_address_text.setSelection(0, flash_address_text.text.length);
			}
		);
		embed_window.addChild(flash_address_text);
		
		var html_code_label:Label = new Label();
		html_code_label.text = "html 代码:";
		html_code_label.setStyle("fontWeight", "bold");
		embed_window.addChild(html_code_label);
		
		var html_code_text:TextArea = new TextArea();
		html_code_text.text = "<embed src=\"" +
			"http://www.qiaobutang.com/swf/TalkReader.swf?talk=" + talk_id + 
			"\" quality=\"high\"" + 
			" bgcolor=\"#b2b2b2\"" + 
			" width=\"100%\"" + 
			" height=\"" + Application.application.stage.stageHeight + "\"" + 
			" align=\"middle\"" + 
			//" allowScriptAccess=\"sameDomain\"" +
			" allowFullScreen=\"true\"" + 
			" type=\"application/x-shockwave-flash\">" + 
			"</embed>";
		html_code_text.width = 210;
		html_code_text.height = 190;
		html_code_text.editable = false;
		html_code_text.wordWrap = true;
		html_code_text.addEventListener(MouseEvent.CLICK,
			function():void {
				html_code_text.setSelection(0, html_code_text.text.length);
			}
		);
		embed_window.addChild(html_code_text);
	}
	
	if(embed_window.visible) {
		embed_window.visible = false;
		embed_window.includeInLayout = false;
	}
	else {
		embed_window.visible = true;
		embed_window.includeInLayout = true;
		
		position_window(embed_window);
	}
}

private function handle_help():void {
	if(help_window == null) {
		init_help_window();
	}
	
	if(help_window.visible) {
		help_window.visible = false;
		help_window.includeInLayout = false;
	}
	else {
		help_window.visible = true;
		help_window.includeInLayout = true;
		
		position_window(help_window);
	}
}

private function handle_about():void {
	if(about_window == null) {
		init_about_window();
	}
	
	if(about_window.visible) {
		about_window.visible = false;
		about_window.includeInLayout = false;
	}
	else {
		about_window.visible = true;
		about_window.includeInLayout = true;
		
		position_window(about_window);
	}
}

private function position_window(window:TitleWindow):void {
	window.x = (Application.application.stage.stageWidth - window.width) / 2;
	window.y = (Application.application.stage.stageHeight - window.height) / 2;
}
