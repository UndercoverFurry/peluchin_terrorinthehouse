﻿//Notes:
/*
- Kongregate API

- Inverse Button
- Brightness Slider (Sun, Moon)
- Inverse Button
- Gray Button
- RGB Sliders
- Reset Button
- Snapshot Button ("Snap!")
- Color Limiter

- Hide all buttons if mouse doesn't move for awhile
*/

package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	import fl.controls.Button;
	import fl.controls.Slider;
	import fl.controls.SliderDirection;
	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	import fl.events.SliderEvent;

	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	import flash.ui.Mouse;

	import flash.events.*;
	import flash.media.Camera;
	import flash.media.Video;

	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;

	[SWF(width="768", height="512")];//600 by 475 or 900 by 712
	public class Main extends Sprite {
		//Constants
		private const scale:uint=1;

		private const outsideBorder:uint=10;
		private const sliderWidth:uint=100;
		private const buttonSeparation:uint=20;

		private const mouseTimeOut:uint=30;
		private const fadeInSpeed:Number=.2;//0-1
		private const fadeOutSpeed:Number=.1;//0-1

		private const showSnapTime:uint=20;

		private const disabledAlpha:Number=.5;
		//Variables
		private var colorPalete:Array = new Array();
		private var colors:uint = 2;
		private var snapNumber:uint=0;
		private var showingSnap:uint=0;
		private var mouseTimer:uint=0;
		private var video:Video;
		private var camera:Camera;
		private var bd:BitmapData;
		private var bm:Bitmap;
		//Properties
		private var brightness:int=0;//-100 to 100
		private var limitedColors:Boolean=false;
		private var inverse:Boolean=false;
		private var gray:Boolean=false;
		private var r:uint=100;
		private var b:uint=100;
		private var g:uint=100;
		//Layers
		private var HUD:Sprite = new Sprite();
		private var webcam:Sprite = new Sprite();
		//Buttons and Sliders
		//private var snap:Button = new Button();
		private var redSlide:Slider = new Slider();
		private var greenSlide:Slider = new Slider();
		private var blueSlide:Slider = new Slider();
		private var grayify:Button = new Button();
		private var invert:Button = new Button();
		private var limitedColor = new Button();
		private var brightnessSlide:Slider = new Slider();
		private var reset:Button = new Button();
		
		private var plus:Button = new Button();
		private var minus:Button = new Button();
		
		private var colorPickers:Array = new Array();
		//Text
		private var redText:TextField = new TextField();
		private var greenText:TextField = new TextField();
		private var blueText:TextField = new TextField();
		//Pictures
		private var sun:Picture = new Picture();
		private var moon:Picture = new Picture();
		public function Main() {
			setColor();
			setVideo();
			setLayers();
			setButtons();
		}
		private function setColor():void {
			for(var a:uint = 0;a<8;a++){
				colorPalete[a]=Math.random()*0xFFFFFF;
			}
		}
		private function setVideo():void {
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			camera=Camera.getCamera();
			if (camera!=null) {
				camera.setQuality(10,100);
				camera.setMode(255,255,100);
				video=new Video(camera.width,camera.height);
				video.attachCamera(camera);
				addEventListener(Event.ENTER_FRAME,onLoop);
			}
		}
		private function setLayers():void {
			addChild(webcam);
			addChild(HUD);

			bd=new BitmapData(camera.width,camera.height);

			bm=new Bitmap(bd);
			bm.width*=3;
			bm.height*=2;
			bm.cacheAsBitmap=true;
			webcam.addChild(bm);
		}
		private function setButtons():void {
			//Red Slide
			redSlide.width=sliderWidth;
			redSlide.move(outsideBorder,outsideBorder+buttonSeparation);
			redSlide.liveDragging=true;
			redSlide.minimum=0;
			redSlide.maximum=100;
			redSlide.snapInterval=1;
			redSlide.tickInterval=10;
			redSlide.value=100;
			redSlide.addEventListener(SliderEvent.THUMB_DRAG,changeRed);
			HUD.addChild(redSlide);
			//Green Slide
			greenSlide.width=sliderWidth;
			greenSlide.move(outsideBorder,redSlide.y+(2*buttonSeparation));
			greenSlide.liveDragging=true;
			greenSlide.minimum=0;
			greenSlide.maximum=100;
			greenSlide.snapInterval=1;
			greenSlide.tickInterval=10;
			greenSlide.value=100;
			greenSlide.addEventListener(SliderEvent.THUMB_DRAG,changeGreen);
			HUD.addChild(greenSlide);
			//Blue Slide
			blueSlide.width=sliderWidth;
			blueSlide.move(outsideBorder,greenSlide.y+(2*buttonSeparation));
			blueSlide.liveDragging=true;
			blueSlide.minimum=0;
			blueSlide.maximum=100;
			blueSlide.snapInterval=1;
			blueSlide.tickInterval=10;
			blueSlide.value=100;
			blueSlide.addEventListener(SliderEvent.THUMB_DRAG,changeBlue);
			HUD.addChild(blueSlide);
			//Grayify
			grayify.label="Black & White";
			grayify.width=sliderWidth;
			grayify.move(outsideBorder,blueSlide.y+buttonSeparation);
			grayify.addEventListener(MouseEvent.CLICK,makeGray);
			HUD.addChild(grayify);
			//Invert
			invert.label="Inverse";
			invert.width=sliderWidth;
			invert.move(outsideBorder,grayify.y+(1.5*buttonSeparation));
			invert.addEventListener(MouseEvent.CLICK,makeInverse);
			HUD.addChild(invert);
			//Limited Color
			limitedColor.label="Limit Color";
			limitedColor.width=sliderWidth;
			limitedColor.move(outsideBorder,invert.y+(1.5*buttonSeparation));
			limitedColor.addEventListener(MouseEvent.CLICK,limitColor);
			HUD.addChild(limitedColor);
			//Reset
			reset.label="Reset";
			reset.width=sliderWidth;
			reset.move(outsideBorder,limitedColor.y+(1.5*buttonSeparation));
			reset.addEventListener(MouseEvent.CLICK,resetAll);
			HUD.addChild(reset);
			//Minus
			minus.label="-";
			minus.width=(sliderWidth-outsideBorder)/2;
			minus.move(outsideBorder,reset.y+(1.5*buttonSeparation));
			minus.addEventListener(MouseEvent.CLICK,minusColor);
			HUD.addChild(minus);
			//Plus
			plus.label="+";
			plus.width=(sliderWidth-outsideBorder)/2;
			plus.move(minus.x+minus.width+outsideBorder,reset.y+(1.5*buttonSeparation));
			plus.addEventListener(MouseEvent.CLICK,plusColor);
			HUD.addChild(plus);
			//Color Pickers
			
			for(var a:uint = 0;a<8;a++){
				colorPickers[a]=new ColorPicker();
				colorPickers[a].name=a;
			}
			
			//Cp1
			colorPickers[0].move(outsideBorder,plus.y+(1.5*buttonSeparation));
			//Cp2
			colorPickers[1].move(outsideBorder+(1*colorPickers[1].width),plus.y+(1.5*buttonSeparation));
			//Cp3
			colorPickers[2].move(outsideBorder+(2*colorPickers[1].width),plus.y+(1.5*buttonSeparation));
			//Cp4
			colorPickers[3].move(outsideBorder+(3*colorPickers[1].width),plus.y+(1.5*buttonSeparation));
			//Cp5
			colorPickers[4].move(outsideBorder,colorPickers[1].y+colorPickers[1].height);
			//Cp6
			colorPickers[5].move(outsideBorder+(1*colorPickers[1].width),colorPickers[1].y+colorPickers[1].height);
			//Cp7
			colorPickers[6].move(outsideBorder+(2*colorPickers[1].width),colorPickers[1].y+colorPickers[1].height);
			//Cp8
			colorPickers[7].move(outsideBorder+(3*colorPickers[1].width),colorPickers[1].y+colorPickers[1].height);
			//Add Color Pickers
			
			for(var b:uint = 0;b<8;b++){
				HUD.addChild(colorPickers[b]);
				colorPickers[b].selectedColor=colorPalete[b];
				colorPickers[b].addEventListener(ColorPickerEvent.CHANGE,onColorChange);
			}
			
			//Brightness Slide
			brightnessSlide.direction=SliderDirection.VERTICAL;
			brightnessSlide.height=sliderWidth*1.5;
			brightnessSlide.move(stage.stageWidth-outsideBorder,outsideBorder*3);
			brightnessSlide.liveDragging=true;
			brightnessSlide.minimum=-100;
			brightnessSlide.maximum=100;
			brightnessSlide.snapInterval=1;
			brightnessSlide.tickInterval=20;
			brightnessSlide.value=0;
			brightnessSlide.addEventListener(SliderEvent.THUMB_DRAG,changeBrightness);
			HUD.addChild(brightnessSlide);
			//Text
			var txtFormat:TextFormat = new TextFormat();
			txtFormat.bold=true;
			txtFormat.color=0xFFFFFF;
			txtFormat.font="Verdana";
			txtFormat.size=10;

			redText.defaultTextFormat=txtFormat;
			redText.x = outsideBorder-(sliderWidth/2);
			redText.y=redSlide.y-buttonSeparation;
			redText.autoSize=TextFieldAutoSize.CENTER;
			redText.selectable=false;
			redText.mouseEnabled=false;
			redText.width=sliderWidth;
			redText.height=10;
			redText.text="Red";
			HUD.addChild(redText);
			//greenText.move(outsideBorder,greenSlide.y);
			greenText.defaultTextFormat=txtFormat;
			greenText.x = outsideBorder-(sliderWidth/2);
			greenText.y=greenSlide.y-buttonSeparation;
			greenText.autoSize=TextFieldAutoSize.CENTER;
			greenText.selectable=false;
			greenText.mouseEnabled=false;
			greenText.width=sliderWidth;
			greenText.height=10;
			greenText.text="Green";
			HUD.addChild(greenText);
			//blueText.move(outsideBorder,blueSlide.y);
			blueText.defaultTextFormat=txtFormat;
			blueText.x = outsideBorder-(sliderWidth/2);
			blueText.y=blueSlide.y-buttonSeparation;
			blueText.autoSize=TextFieldAutoSize.CENTER;
			blueText.selectable=false;
			blueText.mouseEnabled=false;
			blueText.width=sliderWidth;
			blueText.height=10;
			blueText.text="Blue";
			HUD.addChild(blueText);
			//Pictures
			sun.gotoAndStop(1);
			sun.x=brightnessSlide.x-2;
			sun.y=brightnessSlide.y-8;
			sun.width=15;
			sun.height=15;
			HUD.addChild(sun);

			moon.gotoAndStop(2);
			moon.x=brightnessSlide.x-2;
			moon.y = brightnessSlide.y+(brightnessSlide.height*2);
			moon.width=10;
			moon.height=10;
			HUD.addChild(moon);
			//Events
			updateColor();
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoving);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseMoving);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseMoving);
			HUD.addEventListener(Event.ENTER_FRAME,mouseMoveCheck);
		}
		private function onAvatarComplete(success:Boolean) {
		}
		private function changeRed(e:SliderEvent):void {
			r=e.value;
		}
		private function changeGreen(e:SliderEvent):void {
			g=e.value;
		}
		private function changeBlue(e:SliderEvent):void {
			b=e.value;
		}
		private function makeGray(e:MouseEvent):void {
			gray=gray?false:true;
		}
		private function makeInverse(e:MouseEvent):void {
			inverse=inverse?false:true;
		}
		private function limitColor(e:MouseEvent):void {
			limitedColors=limitedColors?false:true;
		}
		private function minusColor(e:MouseEvent):void {
			if(colors>2){
				colors--;
				updateColor();
			}
		}
		private function plusColor(e:MouseEvent):void {
			if(colors<8){
				colors++;
				updateColor();
			}
		}
		private function updateColor():void {
			for(var a:uint = 0;a<8;a++){
				if(a+1<=colors){
					colorPickers[a].alpha = 1;
					colorPickers[a].enabled=true;
				} else {
					colorPickers[a].alpha = disabledAlpha;
					colorPickers[a].enabled=false;
				}
			}
		}
		private function onColorChange(e:ColorPickerEvent):void {
			colorPalete[e.target.name]=e.target.selectedColor;
		}
		private function changeBrightness(e:SliderEvent):void {
			brightness=e.value;
		}
		private function resetAll(e:MouseEvent):void {
			redSlide.value=100;
			greenSlide.value=100;
			blueSlide.value=100;
			brightnessSlide.value=0;
			r=100;
			g=100;
			b=100;
			brightness=0;
			inverse=false;
			gray=false;
			limitedColors=false;
		}
		private function mouseMoving(e:MouseEvent):void {
			mouseTimer=0;
			if (camera.muted) {
				Security.showSettings(SecurityPanel.PRIVACY);
			}
		}
		private function mouseMoveCheck(e:Event):void {
			if (mouseTimer===mouseTimeOut) {//timed out
				if (HUD.alpha>0) {
					HUD.alpha-=fadeOutSpeed;
					Mouse.hide();
				}
			} else {
				mouseTimer++;
				if (HUD.alpha<1) {
					HUD.alpha+=fadeInSpeed;
					Mouse.show();
				}
			}
		}
		private function onLoop(e:Event):void {
			if (showingSnap===0) {
				bd.draw(video);

				for (var a:uint = 0; a<bd.width; a++) {
					for (var c:uint = 0; c<bd.height; c++) {
						var red:uint=Math.ceil(bd.getPixel(a,c)>>16);
						var green:uint = Math.ceil((bd.getPixel(a,c)-(red<<16))>>8);
						var blue:uint = bd.getPixel(a,c)-(red<<16)-(green<<8);
						if (brightness!=0) {
							if (brightness>0) {
								var dred:uint=255-red;
								var dgreen:uint=255-green;
								var dblue:uint=255-blue;
								red += dred*(brightness/100);
								green += dgreen*(brightness/100);
								blue += dblue*(brightness/100);
							} else {
								red += red*(brightness/100);
								green += green*(brightness/100);
								blue += blue*(brightness/100);
							}
						}
						if (inverse) {
							red=Math.abs(red-255);
							green=Math.abs(green-255);
							blue=Math.abs(blue-255);
						}
						red*=(r/100);
						green*=(g/100);
						blue*=(b/100);
						if (limitedColors) {
							//Prevents glitch
							if (r==0) {
								r=1;
							}
							if (g==0) {
								g=1;
							}
							if (b==0) {
								b=1;
							}
							var difference:Array = new Array();
							for (var d:uint = 0; d<colors; d++) {
								var cred:uint=Math.ceil(colorPalete[d]>>16);
								var cgreen:uint = Math.ceil((colorPalete[d]-(cred<<16))>>8);
								var cblue:uint = colorPalete[d]-(cred<<16)-(cgreen<<8);
								var diff:uint=0;
								diff+=Math.abs(red-cred);
								diff+=Math.abs(green-cgreen);
								diff+=Math.abs(blue-cblue);
								difference[d]=diff;
							}
							var end:uint=0;
							var code:uint=difference[0];
							for (var f:uint = 0; f<difference.length; f++) {
								if (difference[f]<code) {
									end=f;
									code=difference[f];
								}
							}
							red=Math.ceil(colorPalete[end]>>16);
							green=Math.ceil((colorPalete[end]-(red<<16))>>8);
							blue=colorPalete[end]-(red<<16)-(green<<8);
						}
						if (gray) {
							//Prevents glitch
							if (r==0) {
								r=1;
							}
							if (g==0) {
								g=1;
							}
							if (b==0) {
								b=1;
							}
							var grey:uint = Math.round((red+green+blue)/3);
							red=grey;
							green=grey;
							blue=grey;
						}
						var finalColor:uint=0;
						if (r) {
							finalColor+=(red<<16);
						}
						if (g) {
							finalColor+=(green<<8);
						}
						if (b) {
							finalColor+=blue;
						}

						bd.setPixel(a,c,finalColor);
					}
				}
			} else {
				if (showingSnap==1) {
					enableAll();
				}
				showingSnap--;
			}
		}
		private function enableAll():void {
			//snap.enabled=true;
			redSlide.enabled=true;
			greenSlide.enabled=true;
			blueSlide.enabled=true;
			grayify.enabled=true;
			invert.enabled=true;
			brightnessSlide.enabled=true;
		}
		private function disableAll():void {
			//snap.enabled=false;
			redSlide.enabled=false;
			greenSlide.enabled=false;
			blueSlide.enabled=false;
			grayify.enabled=false;
			invert.enabled=false;
			brightnessSlide.enabled=false;
		}
	}
}