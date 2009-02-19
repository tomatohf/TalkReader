package com.qiaobutang.talk.reader.container {
 
	import com.qiaobutang.talk.reader.container.DragScrollingCanvas;
	
	import flash.geom.Rectangle;
	
	import mx.core.mx_internal;
	
	use namespace mx_internal;

	public class ReaderContentCanvas extends DragScrollingCanvas {
	
		override mx_internal function getScrollableRect():Rectangle {
		
			var rect:Rectangle = super.getScrollableRect();
			
			// Negative coordinates force clip content
			rect.x = -1E-323;
			rect.y = -1E-323;
			return rect;
		}

		override protected function scrollChildren():void {
			super.scrollChildren();

			// Offset scrollPosition
			if (contentPane && contentPane.scrollRect) {
				var bounds:Rectangle = super.getScrollableRect();
				var sRect:Rectangle = contentPane.scrollRect;
				sRect.offset(bounds.x, bounds.y);
				contentPane.scrollRect = sRect;
			}
		}
  
		override public function validateDisplayList():void {
			
			var centerPercentX:Number = 0;
			var centerPercentY:Number = 0;
			
			// Record scrollPosition percent
			if (maxHorizontalScrollPosition > 0) {
				centerPercentX = horizontalScrollPosition / maxHorizontalScrollPosition;
			} else {
				centerPercentX = 0.5;
			}
   
			if (maxVerticalScrollPosition > 0) {
				centerPercentY = verticalScrollPosition / maxVerticalScrollPosition;
			} else {
				centerPercentY = 0.5;
			}
   
			super.validateDisplayList();
   
			// Restore scrollPosition percent
			if (maxHorizontalScrollPosition > 0) {
				var newHScrollPosition:Number = maxHorizontalScrollPosition * centerPercentX;
				newHScrollPosition = newHScrollPosition > 0 ? newHScrollPosition : 0;
				newHScrollPosition = newHScrollPosition < maxHorizontalScrollPosition ? newHScrollPosition : maxHorizontalScrollPosition;
				horizontalScrollPosition = newHScrollPosition;
			}

			if (maxVerticalScrollPosition > 0) {
				var newVScrollPosition:Number = maxVerticalScrollPosition * centerPercentY;
				newVScrollPosition = newVScrollPosition > 0 ? newVScrollPosition : 0;
				newVScrollPosition = newVScrollPosition < maxVerticalScrollPosition ? newVScrollPosition : maxVerticalScrollPosition;
				verticalScrollPosition = newVScrollPosition;
			}
		}
	}
}
