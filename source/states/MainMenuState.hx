package states;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import options.OptionsState;
import states.editors.MasterEditorMenu;

enum MainMenuColumn {
    CENTER;
    RIGHT;
}

class MainMenuState extends MusicBeatState
{
    public static var psychEngineVersion:String = '1.0.2h';
    public static var curColumn:MainMenuColumn = CENTER;
    var allowMouse:Bool = true;

    // Irida assets
    var bg1:FlxSprite;
    var bg2:FlxSprite;
    var shade:FlxSprite;
    var shade2:FlxSprite;
    var top1:FlxSprite;
    var top2:FlxSprite;
    var bottom1:FlxSprite;
    var bottom2:FlxSprite;

    var playText:FlxText;
    var playTextGlow:FlxText; // for yellow glow
    var rightItem:FlxSprite; // options logo

    var playBopTween:FlxTween = null;
    var playFadeTween:FlxTween = null;

    // Camera beat zoom vars
    var lastBeat:Int = -1;
    var baseCamZoom:Float = 1.0;
    var beatZoomAmount:Float = 0.10;

    static var showOutdatedWarning:Bool = true;

    override function create()
    {
        super.create();

        FlxG.camera.zoom = baseCamZoom;

        #if MODS_ALLOWED
        Mods.pushGlobalMods();
        #end
        Mods.loadTopMod();

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Menus", null);
        #end

        persistentUpdate = persistentDraw = true;

        // --- Irida BG and overlays ---
        bg1 = new FlxSprite(0, 0).loadGraphic(Paths.image('IridaMenuAssets/iridabg'));
        bg1.setGraphicSize(FlxG.width, FlxG.height);
        bg1.updateHitbox();
        bg1.antialiasing = ClientPrefs.data.antialiasing;
        add(bg1);

        bg2 = new FlxSprite(0, -FlxG.height).loadGraphic(Paths.image('IridaMenuAssets/iridabg'));
        bg2.setGraphicSize(FlxG.width, FlxG.height);
        bg2.updateHitbox();
        bg2.antialiasing = ClientPrefs.data.antialiasing;
        add(bg2);

        shade = new FlxSprite(0, 0).loadGraphic(Paths.image('IridaMenuAssets/shade'));
        shade.setGraphicSize(FlxG.width, FlxG.height);
        shade.updateHitbox();
        shade.antialiasing = ClientPrefs.data.antialiasing;
        add(shade);

        // Top overlays (cloned)
        top1 = new FlxSprite().loadGraphic(Paths.image('IridaMenuAssets/top'));
        top1.antialiasing = true;
        top1.y = 0;
        add(top1);

        top2 = new FlxSprite().loadGraphic(Paths.image('IridaMenuAssets/top'));
        top2.antialiasing = true;
        top2.x = top1.width;
        top2.y = 0;
        add(top2);

        // Bottom overlays (cloned)
        bottom1 = new FlxSprite().loadGraphic(Paths.image('IridaMenuAssets/bottom'));
        bottom1.antialiasing = true;
        bottom1.y = FlxG.height - bottom1.height;
        add(bottom1);

        bottom2 = new FlxSprite().loadGraphic(Paths.image('IridaMenuAssets/bottom'));
        bottom2.antialiasing = true;
        bottom2.x = bottom1.width;
        bottom2.y = FlxG.height - bottom2.height;
        add(bottom2);

        shade2 = new FlxSprite(0, 0).loadGraphic(Paths.image("IridaMenuAssets/shade"));
        shade2.setGraphicSize(FlxG.width, FlxG.height);
        shade2.updateHitbox();
        shade2.scale.set(1.01, 1.01);
        shade2.antialiasing = false;
        shade2.alpha = 1;
        add(shade2);

        // Add PLAY glow behind main text
        playTextGlow = new FlxText(0, 0, 0, "Confront Your Fears.", 40);
        playTextGlow.setFormat(Paths.font("Mario Font.ttf"), 40, 0xFFFFFF00, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFF00);
        playTextGlow.alpha = 0;
        playTextGlow.screenCenter();
        add(playTextGlow);

        // Add "PLAY" text in the center of the screen
        playText = new FlxText(0, 0, 0, "Confront Your Fears.", 40);
        playText.setFormat(Paths.font("Mario Font.ttf"), 40, 0xFFFFFF00, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF3E0408);
        playText.screenCenter();
        add(playText);

        // Add options icon to the right of PLAY, vertically centered
        rightItem = createMenuItem("options", 0, 0);
        rightItem.y = playText.y + (playText.height - rightItem.height) / 2;
        rightItem.x = playText.x + playText.width + 40;
        add(rightItem);

        var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Jeffy's Infinite Irida! " + psychEngineVersion, 12);
        psychVer.scrollFactor.set();
        psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(psychVer);
        var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
        fnfVer.scrollFactor.set();
        fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(fnfVer);

        changeItem();

        #if CHECK_FOR_UPDATES
        if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && substates.OutdatedSubState.updateVersion != psychEngineVersion) {
            persistentUpdate = false;
            showOutdatedWarning = false;
            openSubState(new substates.OutdatedSubState());
        }
        #end
    }

    function createMenuItem(name:String, x:Float, y:Float):FlxSprite
    {
        var menuItem:FlxSprite = new FlxSprite(x, y);
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
        menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
        menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
        menuItem.animation.play('idle');
        menuItem.updateHitbox();
        menuItem.antialiasing = ClientPrefs.data.antialiasing;
        menuItem.scrollFactor.set();
        return menuItem;
    }

    var selectedSomethin:Bool = false;
    var timeNotMoving:Float = 0;

    override function update(elapsed:Float)
    {
        // Move Irida bg up
        var bgScrollSpd = 20 * elapsed;
        bg1.y -= bgScrollSpd;
        bg2.y -= bgScrollSpd;
        if (bg1.y <= -bg1.height) bg1.y = bg2.y + bg2.height;
        if (bg2.y <= -bg2.height) bg2.y = bg1.y + bg1.height;

        var overlayScrollSpd = 40 * elapsed;
        top1.x += overlayScrollSpd;
        top2.x += overlayScrollSpd;
        bottom1.x += overlayScrollSpd;
        bottom2.x += overlayScrollSpd;
        if (top1.x >= FlxG.width) top1.x = top2.x - top1.width;
        if (top2.x >= FlxG.width) top2.x = top1.x - top2.width;
        if (bottom1.x >= FlxG.width) bottom1.x = bottom2.x - bottom1.width;
        if (bottom2.x >= FlxG.width) bottom2.x = bottom1.x - bottom2.width;

        if (FlxG.sound.music.volume < 0.8)
            FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

        // --- Camera zoom on every 4th beat ---
        var bpm = 102;
        var songPos = FlxG.sound.music != null ? FlxG.sound.music.time : 0;
        var curBeat:Float = (songPos / (60000 / bpm));
        var intBeat = Std.int(curBeat);
        if (intBeat != lastBeat)
        {
            lastBeat = intBeat;
            if (lastBeat % 3 == 0)
            {
                FlxTween.cancelTweensOf(FlxG.camera);
                FlxG.camera.zoom = baseCamZoom + beatZoomAmount;
                FlxTween.tween(FlxG.camera, {zoom: baseCamZoom}, 0.45, {ease: FlxEase.cubeOut});
            }
        }

        if (!selectedSomethin)
        {
            // Only two options: PLAY (center), OPTIONS (right)
            if (controls.UI_LEFT_P && curColumn == RIGHT)
            {
                curColumn = CENTER;
                changeItem();
            }
            else if (controls.UI_RIGHT_P && curColumn == CENTER)
            {
                curColumn = RIGHT;
                changeItem();
            }

            // === DEBUG KEY (7) ===
            if (FlxG.keys.justPressed.SEVEN)
            {
                selectedSomethin = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                MusicBeatState.switchState(new MasterEditorMenu());
                return;
            }

            if (controls.BACK)
            {
                selectedSomethin = true;
                FlxG.mouse.visible = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new TitleState());
            }

            if (controls.ACCEPT)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                selectedSomethin = true;
                FlxG.mouse.visible = false;

                // Red flash, then fade to black, then flicker and zoom, then switch state
                FlxG.camera.flash(0xFFFF0000, 0.5, function() {
                    FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function() {
                        var flickerObj = curColumn == CENTER ? playText : rightItem;
                        flickerAndZoom(flickerObj, function() {
                            switch (curColumn)
                            {
                                case CENTER:
                                    MusicBeatState.switchState(new FreeplayState());
                                case RIGHT:
                                    MusicBeatState.switchState(new OptionsState());
                                    OptionsState.onPlayState = false;
                                    if (PlayState.SONG != null)
                                    {
                                        PlayState.SONG.arrowSkin = null;
                                        PlayState.SONG.splashSkin = null;
                                        PlayState.stageUI = 'normal';
                                    }
                            }
                        });
                    });
                });
            }
        }

        super.update(elapsed);
    }

    // Flicker (fade in/out repeatedly) and zoom in the camera, then call onDone
    function flickerAndZoom(obj:FlxSprite, ?onDone:Void->Void)
    {
        var flickers:Int = 6;
        var flickerTime:Float = 0.08;
        var origAlpha:Float = obj.alpha;
        var flickerIndex = 0;

        // Zoom in camera
        var zoomAmount = baseCamZoom + 0.27; // You can adjust this amount
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxTween.tween(FlxG.camera, {zoom: zoomAmount}, flickerTime * flickers, {ease: FlxEase.cubeOut});

        function stepFlicker()
        {
            if (flickerIndex >= flickers)
            {
                obj.alpha = origAlpha;
                FlxTween.tween(FlxG.camera, {zoom: baseCamZoom}, 0.3, {ease: FlxEase.cubeIn});
                if (onDone != null) onDone();
                return;
            }
            flickerIndex++;
            FlxTween.tween(obj, {alpha: obj.alpha == 1 ? 0.3 : 1}, flickerTime, {
                ease: FlxEase.quadInOut,
                onComplete: function(_) stepFlicker()
            });
        }
        stepFlicker();
    }

    function changeItem()
    {
        playText.alpha = 1;
        rightItem.animation.play('idle');

        // Always yellow for playText
        playText.color = 0xFFFFFF00;
        playText.borderColor = 0xFF3E0408;

        if (curColumn == CENTER)
        {
            // --- Yellow glow ---
            playTextGlow.alpha = 1;
            playTextGlow.text = playText.text;
            playTextGlow.setFormat(Paths.font("Mario Font.ttf"), 40, 0xFFFFFF00, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFF00);
            playTextGlow.setPosition(playText.x, playText.y);

            rightItem.animation.play('idle');

            // --- Bop effect ---
            if (playBopTween != null) playBopTween.cancel();
            playText.scale.set(1, 1);
            playTextGlow.scale.set(1, 1);

            playBopTween = FlxTween.tween(playText.scale, {x: 1.14, y: 1.14}, 0.11, {ease: FlxEase.quadOut, onComplete: function(_){
                playBopTween = FlxTween.tween(playText.scale, {x: 1, y: 1}, 0.11, {ease: FlxEase.quadIn});
            }});
            FlxTween.tween(playTextGlow.scale, {x: 1.14, y: 1.14}, 0.11, {ease: FlxEase.quadOut, onComplete: function(_){
                FlxTween.tween(playTextGlow.scale, {x: 1, y: 1}, 0.11, {ease: FlxEase.quadIn});
            }});

            // --- Fade (pulse) effect for playText ---
            if (playFadeTween != null) playFadeTween.cancel();
            playText.alpha = 1;
            fadePlayText();
        }
        else if (curColumn == RIGHT)
        {
            rightItem.animation.play('selected');
            // Hide glow and reset scale
            playTextGlow.alpha = 0;
            playText.scale.set(1, 1);
            playTextGlow.scale.set(1, 1);
            if (playBopTween != null) playBopTween.cancel();

            // --- Stop fade (pulse) effect and reset ---
            if (playFadeTween != null) playFadeTween.cancel();
            playText.alpha = 1;
        }
    }

    // Helper function for pulsing fade in/out
    function fadePlayText(?toAlpha:Float = 0.3)
    {
        playFadeTween = FlxTween.tween(playText, {alpha: toAlpha}, 0.7, {
            ease: FlxEase.quadInOut,
            onComplete: function(_) {
                fadePlayText(toAlpha == 1 ? 0.3 : 1);
            }
        });
    }
}