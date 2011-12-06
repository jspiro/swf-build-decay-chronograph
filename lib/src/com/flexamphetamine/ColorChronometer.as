package com.flexamphetamine
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.Font;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

/**
 * Add this to the stage to track how long it's been since a given time.
 * Color changes as you drift further from the start time. 
 *
 * @author Jono Spiro
 */
public class ColorChronometer extends Sprite
{
	[Embed(source='../../../fonts/04b-24/04B-24.ttf', fontName="04B-24Embed", mimeType="application/x-font")]
	private static const F04B_24__Embed:Class;
	
	[Embed(source="chronometer.css", mimeType="application/octet-stream")]
	private static const css:Class;
	
	private var gutter:int;
	private var bgColor:uint;
	private var colors:Vector.<uint>;
	
	private var delay:int;
	private var timer:Timer;
	
	private var autoSize:Boolean;
	private var _width:int;
	private var _height:int;
	
	private var countdownTF:TextField;
	private var labelTF:TextField;
	
	private var _startTime:Date;
	private var _label:String;
	
	/**
	 * @expires (in seconds) expiration time elapsed since start
	 */
	public function ColorChronometer(startTime:Date, expires:uint,
									 label:String = '', autoSize:Boolean = true)
	{
		Font.registerFont(F04B_24__Embed);
		
		this._startTime = startTime;
		this.delay    = expires * 1000;
		this.label    = label;
		this.autoSize = autoSize;
		
		timer = new Timer(1000);
		timer.addEventListener(TimerEvent.TIMER, onTimer);
		
		// defaults
		_width  = 70;
		_height = 38;
		
		// load styles
		const styles:StyleSheet = new StyleSheet();
		styles.parseCSS(new css().toString());
		
		// parse styles
		const style:Object = styles.getStyle('.style');
		gutter  = Number(style.gutter);
		bgColor = Number(style.bgColor.replace('#', '0x'));
		
		// parse colors
		colors = new Vector.<uint>();
		const colorA:Array = style.colors.replace(/\[|\]/g, '').split(',');
		for each (var color:String in colorA) {
			colors.push(Number(color.replace('#', '0x')));
		}
		
		// prepare textfield
		labelTF = new TextField();
		labelTF.styleSheet = styles;
		labelTF.embedFonts = true;
		labelTF.wordWrap = false;
		labelTF.selectable = false;
		labelTF.mouseWheelEnabled = false;
		labelTF.autoSize = TextFieldAutoSize.LEFT;
		// not for pixel fonts
		//labelTF.gridFitType = GridFitType.SUBPIXEL;
		//labelTF.antiAliasType = AntiAliasType.ADVANCED;
		addChild(labelTF);
		
		countdownTF = new TextField();
		countdownTF.styleSheet = styles;
		countdownTF.embedFonts = true;
		countdownTF.wordWrap = false;
		countdownTF.selectable = false;
		countdownTF.mouseWheelEnabled = false;
		countdownTF.autoSize = TextFieldAutoSize.LEFT;
		// not for pixel fonts
		//countdownTF.gridFitType = GridFitType.SUBPIXEL;
		//countdownTF.antiAliasType = AntiAliasType.ADVANCED;
		addChild(countdownTF);
		
		addEventListener(Event.ADDED, onAdded, false, 0, true);
	}
	
	override public function get width():Number {
		return _width;
	}
	
	override public function set width(value:Number):void {
		_width = value;
	}
	
	override public function get height():Number {
		return _height;
	}
	
	override public function set height(value:Number):void {
		_height = value;
	}
	
	public function get startTime():Date {
		return _startTime;
	}
	
	public function set startTime(value:Date):void {
		_startTime = value;
	}
	
	public function get label():String {
		return _label;
	}
	
	public function set label(value:String):void {
		_label = value;
	}
	
	protected function onAdded(... whatever):void {
		removeEventListener(Event.ADDED, onAdded);
		addEventListener(Event.REMOVED, onRemoved, false, 0, true);
		timer.start();
		
		// kick off the first render
		onTimer();
	}
	
	protected function onRemoved(... whatever):void {
		removeEventListener(Event.REMOVED, onRemoved);
		addEventListener(Event.ADDED, onAdded, false, 0, true);
		timer.stop();
	}
	
	protected function onTimer(e:TimerEvent=null):void {
		if (!_startTime) return;
		
		const elapsed:int = ((new Date()).getTime() - _startTime.getTime());
		const progress:Number = Math.min(1, (elapsed / delay));
		
		// update label
		const s:int = Math.floor(elapsed / 1000);
		const m:int = Math.floor(s / 60);
		const h:int = Math.floor(m / 60);
		const d:int = Math.floor(h / 24);
		countdownTF.htmlText =
			'<span class="time">' +
			(d ? d + ' DAY' + ((d > 1) ? 'S' : '') : '') +
			((h && !d) ? (h % 24) + ' HOUR' + ((h > 1) ? 'S' : '') : '') +
			((m && !h) ? (m % 60) + ' MIN' + ((m > 1) ? 'S' : '') : '') +
			(!m ? (s % 60) + ' SEC' : '') +
			'</span>';
		
		labelTF.htmlText =
			'<span class="label">' +
			// upper case for pixel fonts
			_label.toUpperCase() +
			'</span>';
		
		if (autoSize) {
			_width  = Math.max(labelTF.width, countdownTF.width) + (2 * gutter);
			_height = gutter + countdownTF.textHeight + gutter + labelTF.height + gutter;
		}
		
		countdownTF.x = Math.round((_width - countdownTF.textWidth) / 2);
		countdownTF.y = gutter;
		
		labelTF.x = Math.round((_width - labelTF.textWidth) / 2);
		labelTF.y = countdownTF.y + gutter + countdownTF.textHeight;
		
		// draw background
		const colorsIndex:Number = ((colors.length - 1) * progress);
		const c0:uint = Math.floor(colorsIndex);
		const c1:uint = Math.ceil(colorsIndex);
		const c:uint = interpolate(colors[c0], colors[c1], (colorsIndex - c0));
		graphics.clear();
		graphics.beginFill(c);
		graphics.lineStyle(gutter, bgColor, 1, true);
		graphics.drawRect(0, 0, _width, _height);
	}
	
	/** Interpolate a color between two colors; assumes RGB */
	private static function interpolate(c0:uint, c1:uint, percent:Number):uint {
		const r0:int = (c0 >> 16);
		const g0:int = ((c0 >> 8) & 0xFF);
		const b0:int = ((c0) & 0xFF);
		
		const r1:int = (c1 >> 16);
		const g1:int = ((c1 >> 8) & 0xFF);
		const b1:int = (c1 & 0xFF);
		
		var color:uint = int(b0 + ((b1 - b0) * percent));
		color |= int(g0 + ((g1 - g0) * percent)) << 8;
		color |= int(r0 + ((r1 - r0) * percent)) << 16;
		
		return color;
	}
}
}
