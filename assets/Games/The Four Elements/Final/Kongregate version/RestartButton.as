﻿//par:Game
package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class RestartButton extends MovieClip {
		private var px:uint;
		private var py:uint;
		private var par:MovieClip;
		public function RestartButton(px:uint,py:uint):void {
			this.px = px;
			this.py = py;
			x = px;
			y = py;
			stop();
			buttonMode = true;
			addEventListener(Event.ADDED_TO_STAGE,onAdd);
		}
		private function onAdd(e:Event):void {
			par = MovieClip(parent);
			addEventListener(MouseEvent.CLICK,onClick);
			addEventListener(MouseEvent.ROLL_OVER,rollingIn);
			addEventListener(MouseEvent.ROLL_OUT,rollingOut);
			removeEventListener(Event.ADDED_TO_STAGE,onAdd);
		}
		
		//when clicked
		private function onClick(e:MouseEvent):void {
			par.resetBoard();
		}
		
		//when rolling in
		private function rollingIn(e:MouseEvent):void {
			gotoAndStop(2);
		}
		
		//when rolling out
		private function rollingOut(e:MouseEvent):void {
			gotoAndStop(1);
		}
	}
}
	