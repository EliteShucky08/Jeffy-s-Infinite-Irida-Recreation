package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import states.StoryMenuState;
import states.FreeplayState;

class PauseSubState extends MusicBeatSubstate
{
    public static var songName:String = null;

    var curSelected:Int = 0;

    // Overlays
    var pauseOverlayLeft:FlxSprite;
    var pauseOverlayBottom:FlxSprite;
    var pauseOverlayRight:FlxSprite;
    var pauseOverlayTop:FlxSprite;

    // Button Sprites
    var pauseMenuButtons:Array<FlxSprite> = [];
    var pauseMenuButtonLabels:Array<FlxText> = [];
    var buttonBaseXs:Array<Float> = [];
    var buttonMenuNames:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];

    // For displaying timestamp/duration
    var timeText:FlxText;

    // Optional pause menu music
    var pauseMenuMusic:FlxSound;

    // For timer that keeps counting while paused
    var songPauseTime:Float = 0;
    var pauseStartTime:Float = 0;

    override function create()
    {
        // Optional: play pause menu jingle/music as a sound (not as FlxG.sound.music)
        pauseMenuMusic = new FlxSound();
        pauseMenuMusic.loadEmbedded(Paths.music('freakyMenu'), true, true);
        pauseMenuMusic.volume = 0.5;
        pauseMenuMusic.play();

        FlxG.sound.list.add(pauseMenuMusic);

        var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        // --- Overlays in order: left, right, top, (song render goes here), buttons, bottom ---
        pauseOverlayLeft = new FlxSprite(-128, 0).loadGraphic(Paths.image('pausemenuassets/left'));
        pauseOverlayLeft.setGraphicSize(128, FlxG.height);
        pauseOverlayLeft.antialiasing = true;
        pauseOverlayLeft.updateHitbox();
        add(pauseOverlayLeft);
        FlxTween.tween(pauseOverlayLeft, {x: 0}, 0.5, {ease: FlxEase.quadOut});

        pauseOverlayRight = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('pausemenuassets/right'));
        pauseOverlayRight.scale.set(1, 1.1);
        pauseOverlayRight.antialiasing = true;
        pauseOverlayRight.angle = 8;
        pauseOverlayRight.updateHitbox();
        add(pauseOverlayRight);
        FlxTween.tween(
            pauseOverlayRight,
            {x: FlxG.width - pauseOverlayRight.width + 30, y: -40},
            0.5,
            {ease: FlxEase.quadOut}
        );

        // --- Song Render Sprite ---
        var songId:String = (PlayState.SONG != null ? PlayState.SONG.song : '');
        var songIdLower = songId.toLowerCase();
        if (['shucks', 'execretion', 'irida'].contains(songIdLower)) {
            var renderPath = 'pausemenuassets/renders/' + songId;
            var songRender:FlxSprite = new FlxSprite(FlxG.width, 0);
            songRender.antialiasing = true;
            try {
                songRender.loadGraphic(Paths.image(renderPath));
                // Larger scale for execretion and irida
                if (songIdLower == 'execretion' || songIdLower == 'irida') {
                    songRender.setGraphicSize(Std.int(songRender.width * 1.0));
                } else {
                    songRender.setGraphicSize(Std.int(songRender.width * 0.7));
                }
                songRender.updateHitbox();

                var targetX = FlxG.width - songRender.width - 10;
                songRender.y = FlxG.height - songRender.height - 14;

                add(songRender);

                FlxTween.tween(songRender, {x: targetX}, 0.5, {ease: FlxEase.quadOut});
            } catch(e:Dynamic) {}
        }

        pauseOverlayTop = new FlxSprite(0, -64).loadGraphic(Paths.image('pausemenuassets/top'));
        pauseOverlayTop.setGraphicSize(FlxG.width, 64);
        pauseOverlayTop.antialiasing = true;
        pauseOverlayTop.updateHitbox();
        add(pauseOverlayTop);
        FlxTween.tween(pauseOverlayTop, {y: 0}, 0.5, {ease: FlxEase.quadOut});

        // --- Buttons (still at far left) ---
        pauseMenuButtons = [];
        pauseMenuButtonLabels = [];
        buttonBaseXs = [];
        var buttonData:Array<Dynamic> = [
            {x: 0,  y: 95,  text: "RESUME"},
            {x: 0,  y: 265, text: "RESTART SONG"},
            {x: 0,  y: 435, text: "EXIT TO MENU"}
        ];
        for(i in 0...buttonData.length)
        {
            var btn = new FlxSprite(buttonData[i].x, buttonData[i].y).loadGraphic(Paths.image('pausemenuassets/button'));
            btn.setGraphicSize(600, 90);
            btn.angle = 0;
            btn.updateHitbox();
            btn.antialiasing = true;
            add(btn);
            pauseMenuButtons.push(btn);
            buttonBaseXs.push(btn.x);

            var labelColor = (i == 0) ? FlxColor.RED : 0xFFD8D8D8;
            var txt = new FlxText(0, 0, btn.width, buttonData[i].text, 48);
            txt.setFormat(Paths.font("vcr.ttf"), 48, labelColor, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            txt.x = btn.x;
            txt.y = btn.y + (btn.height - txt.height) / 2 - 6;
            txt.angle = 0;
            txt.antialiasing = true;
            add(txt);
            pauseMenuButtonLabels.push(txt);
        }

        // --- Bottom overlay on top ---
        pauseOverlayBottom = new FlxSprite(500, FlxG.height).loadGraphic(Paths.image('pausemenuassets/bottom'));
        pauseOverlayBottom.scale.set(1, 1);
        pauseOverlayBottom.antialiasing = true;
        pauseOverlayBottom.updateHitbox();
        add(pauseOverlayBottom);
        FlxTween.tween(pauseOverlayBottom, {y: FlxG.height - 94}, 0.5, {ease: FlxEase.quadOut});

        // --- Song name and time text on bottom overlay ---
        var songDisplayName:String = (PlayState.SONG != null ? PlayState.SONG.song : "Unknown Song");
        songDisplayName = songDisplayName.toUpperCase();

        // Song name text (left side)
        var songNameText = new FlxText(0, 0, 600, songDisplayName, 32);
        songNameText.setFormat(Paths.font("pixel-latin.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        songNameText.x = 700; // Padding from left
        songNameText.y = FlxG.height - 94 + (pauseOverlayBottom.height - songNameText.height) / 2;
        songNameText.antialiasing = true;
        add(songNameText);

        // Time text (right side)
        var timeTextWidth = 250;
        timeText = new FlxText(FlxG.width - timeTextWidth - 30, songNameText.y, timeTextWidth, '', 32);
        timeText.setFormat(Paths.font("pixel-latin.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        timeText.antialiasing = true;
        add(timeText);

        changeSelection();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
        super.create();

        // Store pause time and pause menu start time for timer
        if (PlayState.instance != null && PlayState.instance.inst != null)
            songPauseTime = PlayState.instance.inst.time;
        pauseStartTime = haxe.Timer.stamp();
    }

    var cantUnpause:Float = 0.1;
    override function update(elapsed:Float)
    {
        cantUnpause -= elapsed;

        super.update(elapsed);

        if (controls.BACK)
        {
            close();
            return;
        }
        if (controls.UI_UP_P) changeSelection(-1);
        if (controls.UI_DOWN_P) changeSelection(1);

        if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
        {
            switch (curSelected)
            {
                case 0: // Resume
                    close();
                case 1: // Restart Song
                    restartSong();
                case 2: // Exit to menu
                    #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                    PlayState.deathCounter = 0;
                    PlayState.seenCutscene = false;
                    PlayState.instance.canResync = false;
                    Mods.loadTopMod();
                    if(PlayState.isStoryMode)
                        MusicBeatState.switchState(new StoryMenuState());
                    else 
                        MusicBeatState.switchState(new FreeplayState());
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    PlayState.changedDifficulty = false;
                    PlayState.chartingMode = false;
                    FlxG.camera.followLerp = 0;
            }
        }

        // --- Update time display: continues counting up while paused
        if (timeText != null && PlayState.instance != null && PlayState.instance.inst != null)
        {
            var realTime = songPauseTime + ((haxe.Timer.stamp() - pauseStartTime) * 1000);
            var curSec = Std.int(realTime / 1000);
            var maxSec = Std.int(PlayState.instance.inst.length / 1000);

            var curMinStr = Std.string(Std.int(curSec / 60));
            var curSecStr = StringTools.lpad(Std.string(curSec % 60), "0", 2);
            var maxMinStr = Std.string(Std.int(maxSec / 60));
            var maxSecStr = StringTools.lpad(Std.string(maxSec % 60), "0", 2);

            timeText.text = curMinStr + ":" + curSecStr + " - " + maxMinStr + ":" + maxSecStr;
        }
    }

    public static function restartSong(noTrans:Bool = false)
    {
        PlayState.instance.paused = true;
        FlxG.sound.music.volume = 0;
        PlayState.instance.vocals.volume = 0;
        if(noTrans)
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
        }
        MusicBeatState.resetState();
    }

    override function destroy()
    {
        if (pauseMenuMusic != null) pauseMenuMusic.stop();
        super.destroy();
    }

    override function close()
    {
        // Stop pause menu music
        if (pauseMenuMusic != null) pauseMenuMusic.stop();
        super.close();
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, pauseMenuButtonLabels.length - 1);
        for(i in 0...pauseMenuButtonLabels.length)
        {
            pauseMenuButtonLabels[i].color = (curSelected == i) ? FlxColor.RED : 0xFFD8D8D8;
        }
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
    }
}