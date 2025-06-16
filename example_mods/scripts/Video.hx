import hxvlc.flixel.FlxVideoSprite;
import flixel.FlxG;

var introVideo:FlxVideoSprite;
var toldyouVideo:FlxVideoSprite;
var faultVideo:FlxVideoSprite;

var allowVideos:Bool = false;

function onCreate() {
    if (PlayState.SONG != null && PlayState.SONG.song.toLowerCase() == "shucks") {
        allowVideos = true;

        // ─── Intro video ─────────────────────────────
        introVideo = new FlxVideoSprite();
        introVideo.cameras = [game.camOther];
        if (introVideo.load(Paths.video("intro"))) {
            try {
                introVideo.frameRate = 60;
            } catch(e:Dynamic) {}
            add(introVideo);
            introVideo.bitmap.onEndReached.add(function():Void {
                introVideo.destroy();
            });
        } else {
            FlxG.log.error("Intro video not found: " + Paths.video("intro"));
        }

        // ─── ToldYou video (step 435) ────────────────
        toldyouVideo = new FlxVideoSprite();
        toldyouVideo.cameras = [game.camOther];
        if (toldyouVideo.load(Paths.video("toldyou"))) {
            try {
                toldyouVideo.frameRate = 60;
            } catch(e:Dynamic) {}
            add(toldyouVideo);
            toldyouVideo.bitmap.onEndReached.add(function():Void {
                toldyouVideo.destroy();
            });
        } else {
            FlxG.log.error("ToldYou video not found: " + Paths.video("toldyou"));
        }

        // ─── Fault video (step 3188) ─────────────────
        faultVideo = new FlxVideoSprite();
        faultVideo.cameras = [game.camOther];
        if (faultVideo.load(Paths.video("fault"))) {
            try {
                faultVideo.frameRate = 60;
            } catch(e:Dynamic) {}
            add(faultVideo);
            faultVideo.bitmap.onEndReached.add(function():Void {
                faultVideo.destroy();
            });
        } else {
            FlxG.log.error("Fault video not found: " + Paths.video("fault"));
        }
    }
}

function onSongStart() {
    if (!allowVideos) return;
    if (introVideo != null) introVideo.play(); // ▶️ Play intro when the song starts
}

function onStepHit() {
    if (!allowVideos) return;

    if (curStep == 435 && toldyouVideo != null) {
        toldyouVideo.play();
    }
    if (curStep == 3188 && faultVideo != null) {
        faultVideo.play();
    }
}

function onPause():Void {
    if (!allowVideos) return;

    if (introVideo   != null) introVideo.pause();
    if (toldyouVideo != null) toldyouVideo.pause();
    if (faultVideo   != null) faultVideo.pause();
}

function onResume():Void {
    if (!allowVideos) return;

    if (introVideo   != null) introVideo.resume();
    if (toldyouVideo != null) toldyouVideo.resume();
    if (faultVideo   != null) faultVideo.resume();
}
