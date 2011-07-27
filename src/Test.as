package 
{
import com.flexamphetamine.BuildDecayChronograph;

import flash.display.Sprite;

[SWF(width="800", height="600", backgroundColor="#ffffff")]
public class Test extends Sprite
{
	public function Test()
	{
		const bdc:BuildDecayChronograph = new BuildDecayChronograph(30, 'label');
		bdc.x = 10;
		bdc.y = 10;
		addChild(bdc);
	}
}
}