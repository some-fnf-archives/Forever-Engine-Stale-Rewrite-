package funkin.stages;

import forever.ForeverSprite;
import funkin.objects.StageBuilder;

/**
 * Tutorial
 * Week 1: Bopeebo, Fresh, Dadbattle
**/
class DadStage extends StageBuilder {
	public function new():Void {
		super("stage", 0.9);

		// thats so awesome..
		add(new ForeverSprite(-600, -200, "stages/week1/stageback", {"scroll.x": 0.9, "scroll.y": 0.9}));
		add(new ForeverSprite(-650, 600, "stages/week1/stagefront", {
			"scale.x": 1.1,
			"scale.y": 1.1,
			"scroll.x": 0.9,
			"scroll.y": 0.9
		}));
	}
}
