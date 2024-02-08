package backend.data;

import flixel.math.FlxMath;

/**
 * Score Container, counts score, accuracy, and everything in between,
 * this is instantiable in case you need more than one container for, say, two players for example.
**/
class ScoreContainer {
    // -- FNF STUFF -- //
    public var score: Int = 0;
    public var combo: Int = 0;
    // -- -- -- -- -- //

    // -- FOREVER ADDITIONS -- //
    public var misses: Int = 0;
    public var rank: String = "N/A";

    public var totalNotesHit: Int = 0;
    public var totalPlayed: Float = 0.00;
    public var accuracy(get, never): Float;

    public var judgementHits: Dictionary<String, Int>;
     // -- -- -- -- -- -- -- -- //

    public function new() {
        // TODO: Judgement System.
        judgementHits = new Dictionary<String, Int>();
    }

    public var scoreDivider: String = " • ";

    public dynamic function makeScoreText() {
        final scoreText: String =  'Score: $score'
            + scoreDivider + 'Accuracy: ${FlxMath.roundDecimal(accuracy, 2)}%'
            + scoreDivider + 'Combo Breaks: $misses' // Misses + Shits
            + scoreDivider + 'Rank: N/A';
        return '< $scoreText >';
    }

    public function get_accuracy() {
        return totalNotesHit == 0 ? 0.00 : Math.abs(totalPlayed / (totalNotesHit + misses));
    }
}