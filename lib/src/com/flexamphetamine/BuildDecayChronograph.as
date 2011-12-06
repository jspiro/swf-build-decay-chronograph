package com.flexamphetamine
{
import flash.utils.ByteArray;

import org.igorcosta.hacks.SWF;

/**
 * Add this to the stage to track how long it's been since the last time an
 * MXMLC-comiled SWF was built.
 * 
 * Set the swfBytes property to switch which SWF is used.
 *
 * @author Jono Spiro
 */
public final class BuildDecayChronograph extends ColorChronometer
{
	/**
	 * @expires (in seconds) expiration time elapsed since last build (def: 5m)
	 */
	public function BuildDecayChronograph(expires:int = 5 * 60, label:String = '',
	                                      autoSize:Boolean = true)
	{
		super(null, expires, label, autoSize);
	}
	
	override protected function onAdded(...whatever):void {
		// use the stage's loaderInfo by default
		if (!startTime && stage) swfBytes = stage.loaderInfo.bytes;
		super.onAdded(whatever);
	}
	
	/** E.g., Loader.contentLoaderInfo.bytes */
	public function set swfBytes(bytes:ByteArray):void {
		startTime = SWF.readCompilationDate(SWF.readSerialNumber(bytes));
	}
}
}
