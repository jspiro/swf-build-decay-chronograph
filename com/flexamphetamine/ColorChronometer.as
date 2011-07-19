package com.flexamphetamine
{
import flash.display.Sprite;
import flash.events.Event;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

/**
 * Add this to the stage to track how long it's been since a given time.
 * Color changes as you drift further from the start time. 
 */
public class ColorChronometer extends Sprite
{
	[Embed(source="chronometer.css", mimeType="application/octet-stream")]
	private static const css:Class;
	
	private var gutter:int;
	private var bgColor:uint;
	private var colors:Vector.<uint>;
	
	private var delay:int;
	
	private var autoSize:Boolean;
	private var _width:int;
	private var _height:int;
	
	private var tf:TextField;
	
	private var _startTime:Date;
	private var _label:String;
	
	/**
	 * @expires (in seconds) expiration time elapsed since start
	 */
	public function ColorChronometer(startTime:Date, expires:uint,
	                                 label:String = '', autoSize:Boolean = true)
	{
		this._startTime = startTime;
		this.delay    = expires * 1000;
		this.label    = label;
		this.autoSize = autoSize;
		
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
		tf = new TextField();
		tf.styleSheet = styles;
		tf.wordWrap = false;
		tf.multiline = true;
		tf.selectable = false;
		tf.mouseWheelEnabled = false;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.gridFitType = GridFitType.SUBPIXEL;
		tf.antiAliasType = AntiAliasType.ADVANCED;
		addChild(tf);
		
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
		addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
	}
	
	protected function onRemoved(... whatever):void {
		removeEventListener(Event.REMOVED, onRemoved);
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(Event.ADDED, onAdded, false, 0, true);
	}
	
	protected function onEnterFrame(... whatever):void {
		if (!_startTime) return;
		
		const elapsed:int = ((new Date()).getTime() - _startTime.getTime());
		const progress:Number = Math.min(1, (elapsed / delay));
		
		// update label
		const s:int = Math.floor(elapsed / 1000);
		const m:int = Math.floor(s / 60);
		const h:int = Math.floor(m / 60);
		const d:int = Math.floor(h / 24);
		tf.htmlText =
			'<span class="time">' +
			(d ? d + 'd ' : '') +
			((h && !d) ? (h % 24) + 'h ' : '') +
			((m && !h) ? (m % 60) + 'm ' : '') +
			(!m ? (s % 60) + 's' : '') +
			'</span>' +
			'<br/>' +
			'<span class="label">' +
			_label +
			'</span>';
		tf.x = (width  - tf.width)  / 2;
		tf.y = (height - tf.height) / 2;
		
		if (autoSize) {
			_width  = (tf.width  + (4 * gutter));
			_height = (tf.height + (4 * gutter));
		}
		
		// draw background
		const colorsIndex:Number = ((colors.length - 1) * progress);
		const c0:uint = Math.floor(colorsIndex);
		const c1:uint = Math.ceil(colorsIndex);
		const c:uint = interpolate(colors[c0], colors[c1], (colorsIndex - c0));
		graphics.clear();
		graphics.beginFill(c);
		graphics.lineStyle(gutter, bgColor, 1, true);
		graphics.drawRoundRect(0, 0, _width, _height, 16);
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