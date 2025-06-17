package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class TitleState extends MusicBeatState
{
    public static var muteKeys:Array<flixel.input.keyboard.FlxKey>   = [flixel.input.keyboard.FlxKey.ZERO];
    public static var volumeDownKeys:Array<flixel.input.keyboard.FlxKey> = [flixel.input.keyboard.FlxKey.NUMPADMINUS, flixel.input.keyboard.FlxKey.MINUS];
    public static var volumeUpKeys:Array<flixel.input.keyboard.FlxKey>   = [flixel.input.keyboard.FlxKey.NUMPADPLUS, flixel.input.keyboard.FlxKey.PLUS];
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    var bg1:FlxSprite;
    var bg2:FlxSprite;
    var top1:FlxSprite;
    var top2:FlxSprite;
    var bottom1:FlxSprite;
    var bottom2:FlxSprite;
    var logo:FlxSprite;
    var pressEnter:FlxSprite;
    var shade:FlxSprite;
    var shade2:FlxSprite;

    var transitioning:Bool = false;
    var introDone:Bool     = false;

    var logoBaseY:Float        = 0;
    var pressEnterBaseY:Float  = 0;
    var logoTargetX:Float      = 0;
    var pressEnterTargetX:Float = 0;

    var topBottomSpeed:Float = 40;
    var bgUpSpeed:Float      = 20;

    // Camera beat-zoom vars
    var lastBeat:Int        = -1;
    var baseCamZoom:Float   = 1.2;
    var beatZoomAmount:Float = 0.10;

    override public function create():Void
    {
        super.create();

        FlxG.camera.alpha = 1;

        /* -------------- background / decorations (unchanged) -------------- */
        bg1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/iridabg"));
        bg1.setGraphicSize(FlxG.width, FlxG.height);
        bg1.updateHitbox();
        bg1.antialiasing = false;
        bg1.x = 0; bg1.y = 0;
        add(bg1);

        bg2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/iridabg"));
        bg2.setGraphicSize(FlxG.width, FlxG.height);
        bg2.updateHitbox();
        bg2.antialiasing = false;
        bg2.x = 0; bg2.y = -bg2.height;
        add(bg2);

        shade = new FlxSprite(0,0).loadGraphic(Paths.image("IridaMenuAssets/shade"));
        shade.setGraphicSize(FlxG.width, FlxG.height);
        shade.updateHitbox();
        shade.scale.set(0.85,0.85);
        shade.antialiasing = false;
        shade.alpha = 1;
        add(shade);

        bottom1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/bottom"));
        bottom1.antialiasing = true;
        bottom1.x = 0; bottom1.y = FlxG.height;
        add(bottom1);

        bottom2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/bottom"));
        bottom2.antialiasing = true;
        bottom2.x = bottom1.width; bottom2.y = FlxG.height;
        add(bottom2);

        top1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/top"));
        top1.antialiasing = true;
        top1.x = 0; top1.y = -top1.height;
        add(top1);

        top2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/top"));
        top2.antialiasing = true;
        top2.x = top1.width; top2.y = -top2.height;
        add(top2);

        logo = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/Logo"));
        logo.antialiasing = true;
        logo.scale.set(0.75,0.75);
        logo.updateHitbox();
        logoTargetX = (FlxG.width - logo.width) / 2;
        logo.x = -logo.width; logo.y = 120;
        logoBaseY = logo.y;
        add(logo);

        pressEnter = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/enter"));
        pressEnter.antialiasing = true;
        pressEnter.scale.set(0.75,0.75);
        pressEnter.updateHitbox();
        pressEnterTargetX = (FlxG.width - pressEnter.width) / 2;
        pressEnter.x = FlxG.width; pressEnter.y = FlxG.height - pressEnter.height - 80;
        pressEnterBaseY = pressEnter.y;
        add(pressEnter);

        shade2 = new FlxSprite(0,0).loadGraphic(Paths.image("IridaMenuAssets/shade"));
        shade2.setGraphicSize(FlxG.width, FlxG.height);
        shade2.updateHitbox();
        shade2.scale.set(0.85,0.85);
        shade2.antialiasing = false;
        shade2.alpha = 1;
        add(shade2);

        /* -------------- music -------------- */
        if(FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.music("freakyMenu"), 0.7);

        /* -------------- initial camera zoom -------------- */
        FlxG.camera.zoom = baseCamZoom;

        /* -------------- intro tweens -------------- */
        FlxTween.tween(top1,     {y:0}, 0.8, {ease:FlxEase.cubeInOut});
        FlxTween.tween(top2,     {y:0}, 0.8, {ease:FlxEase.cubeInOut});
        FlxTween.tween(bottom1,  {y:FlxG.height-bottom1.height}, 1, {ease:FlxEase.cubeInOut});
        FlxTween.tween(bottom2,  {y:FlxG.height-bottom2.height}, 1, {
            ease:FlxEase.cubeInOut,
            onComplete: function(_) {
                FlxTween.tween(logo,        {x:logoTargetX},      0.7, {ease:FlxEase.quadInOut});
                FlxTween.tween(pressEnter,  {x:pressEnterTargetX},0.7, {
                    ease:FlxEase.quadInOut,
                    onComplete: function(_) {
                        introDone = true;
                    }
                });
            }
        });

        FlxTween.tween(FlxG.camera, {alpha:1}, 2, {ease:FlxEase.quadOut});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        /* --------- scrolling BG + borders (unchanged) --------- */
        bg1.y -= bgUpSpeed * elapsed;
        bg2.y -= bgUpSpeed * elapsed;
        if(bg1.y <= -bg1.height) bg1.y = bg2.y + bg2.height;
        if(bg2.y <= -bg2.height) bg2.y = bg1.y + bg1.height;

        top1.x += topBottomSpeed * elapsed;
        top2.x += topBottomSpeed * elapsed;
        if(top1.x >= FlxG.width) top1.x = top2.x - top1.width;
        if(top2.x >= FlxG.width) top2.x = top1.x - top2.width;

        bottom1.x += topBottomSpeed * elapsed;
        bottom2.x += topBottomSpeed * elapsed;
        if(bottom1.x >= FlxG.width) bottom1.x = bottom2.x - bottom1.width;
        if(bottom2.x >= FlxG.width) bottom2.x = bottom1.x - bottom2.width;

        /* --------- logo & pressEnter bop --------- */
        var bpm = 102;
        var songPos = (FlxG.sound.music != null) ? FlxG.sound.music.time : 0;
        var curBeat:Float = songPos / (60000 / bpm);
        var bop = Math.sin(curBeat * Math.PI) * 12;
        logo.y        = logoBaseY       + bop;
        pressEnter.y  = pressEnterBaseY + bop;

        /* --------- camera beat zoom --------- */
        var intBeat = Std.int(curBeat);
        if(intBeat != lastBeat)
        {
            lastBeat = intBeat;
            if(lastBeat % 3 != 0) // every 4th beat
                return;

            FlxTween.cancelTweensOf(FlxG.camera);
            FlxG.camera.zoom = baseCamZoom + beatZoomAmount;
            FlxTween.tween(FlxG.camera, {zoom:baseCamZoom}, 0.45, {ease:FlxEase.cubeOut});
        }

        /* --------- accept (ENTER) handling --------- */
        if(introDone && !transitioning)
        {
            var go:Bool = FlxG.keys.justPressed.ENTER;
            #if mobile
            for(t in FlxG.touches.list) if(t.justPressed) go = true;
            #end
            var gp:FlxGamepad = FlxG.gamepads.lastActive;
            if(gp != null && gp.justPressed.START) go = true;

            if(go)
            {
                transitioning = true;
                FlxG.sound.play(Paths.sound("confirmMenu"), 1);

                /* ---- NEW: quick camera punch-in ---- */
                FlxTween.cancelTweensOf(FlxG.camera);
                FlxTween.tween(FlxG.camera, {zoom:baseCamZoom + 0.25}, 0.12, {
                    ease:FlxEase.circOut,
                    onComplete: function(_) {
                        // Gradually return to original zoom while fading
                        FlxTween.tween(FlxG.camera, {zoom:baseCamZoom}, 0.4, {ease:FlxEase.quadOut});
                    }
                });

                /* ---- existing effects ---- */
                flickerSprite(pressEnter, 1.25, 0.06);
                FlxG.camera.flash(0xFFFF0000, 0.5, function() {
                    FlxG.camera.fade(FlxColor.BLACK, 0.8, false, function() {
                        MusicBeatState.switchState(new MainMenuState());
                    });
                });
            }
        }
    }

    /* ---------------------------------------------------------- */
    // Flicker helper
    function flickerSprite(spr:FlxSprite, duration:Float = 0.5, interval:Float = 0.06)
    {
        var elapsed = 0.0;
        function toggle() {
            spr.visible = !spr.visible;
            elapsed += interval;
            if(elapsed < duration)
                new FlxTimer().start(interval, function(_) toggle());
            else
                spr.visible = true;
        }
        toggle();
    }
}