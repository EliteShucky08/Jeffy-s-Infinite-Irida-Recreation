package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class TitleState extends FlxState
{
    public static var muteKeys:Array<flixel.input.keyboard.FlxKey> = [flixel.input.keyboard.FlxKey.ZERO];
    public static var volumeDownKeys:Array<flixel.input.keyboard.FlxKey> = [flixel.input.keyboard.FlxKey.NUMPADMINUS, flixel.input.keyboard.FlxKey.MINUS];
    public static var volumeUpKeys:Array<flixel.input.keyboard.FlxKey> = [flixel.input.keyboard.FlxKey.NUMPADPLUS, flixel.input.keyboard.FlxKey.PLUS];
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    // DOUBLE SPRITES for seamless scrolling
    var bg1:FlxSprite;
    var bg2:FlxSprite;
    var top1:FlxSprite;
    var top2:FlxSprite;
    var bottom1:FlxSprite;
    var bottom2:FlxSprite;
    var logo:FlxSprite;
    var pressEnter:FlxSprite;
    var shade:FlxSprite;

    var redCover:FlxSprite; // Our red screen overlay
    var transitioning:Bool = false; // To prevent double transitions
    var introDone:Bool = false; // Controls input

    // Bop base Y positions
    var logoBaseY:Float = 0;
    var pressEnterBaseY:Float = 0;
    var logoTargetX:Float = 0;
    var pressEnterTargetX:Float = 0;

    // Animation speeds
    var topBottomSpeed:Float = 40; // pixels per second
    var bgUpSpeed:Float = 20;      // pixels per second

    override public function create():Void
{
    super.create();

    FlxG.camera.alpha = 0; // Start the camera invisible

    // 1) Backgrounds (vertical tiling)
    bg1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/iridabg"));
    bg1.setGraphicSize(FlxG.width, FlxG.height);
    bg1.updateHitbox();
    bg1.antialiasing = false;
    bg1.x = 0;
    bg1.y = 0;
    add(bg1);

    bg2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/iridabg"));
    bg2.setGraphicSize(FlxG.width, FlxG.height);
    bg2.updateHitbox();
    bg2.antialiasing = false;
    bg2.x = 0;
    bg2.y = -bg2.height;
    add(bg2);

    // 2) Shade overlay (full screen, fades out) -- IN FRONT OF BGs, BEHIND BORDERS/LOGO/ENTER
    shade = new FlxSprite(0, 0).loadGraphic(Paths.image("IridaMenuAssets/shade"));
    shade.setGraphicSize(FlxG.width, FlxG.height);
    shade.updateHitbox();
    shade.scale.set(0.85, 0.85); // Scale to 75%
    shade.antialiasing = false;
    shade.alpha = 1;
    add(shade);

    // 3) Bottom borders (horizontal tiling) -- Start off-screen (bottom)
    bottom1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/bottom"));
    bottom1.antialiasing = true;
    bottom1.x = 0;
    bottom1.y = FlxG.height; // Start off-screen
    add(bottom1);

    bottom2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/bottom"));
    bottom2.antialiasing = true;
    bottom2.x = bottom1.width;
    bottom2.y = FlxG.height; // Start off-screen
    add(bottom2);

    // 4) Top borders (horizontal tiling) -- Start off-screen (top)
    top1 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/top"));
    top1.antialiasing = true;
    top1.x = 0;
    top1.y = -top1.height; // Start off-screen
    add(top1);

    top2 = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/top"));
    top2.antialiasing = true;
    top2.x = top1.width;
    top2.y = -top2.height; // Start off-screen
    add(top2);

    // 5) Logo -- from the left
    logo = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/Logo"));
    logo.antialiasing = true;
    logo.scale.set(0.75, 0.75); // Scale to 75%
    logo.updateHitbox();
    logoTargetX = (FlxG.width - logo.width) / 2;
    logo.x = -logo.width; // Start off-screen left
    logo.y = 120;
    logoBaseY = logo.y;
    add(logo);

    // 6) "Press Enter" -- from the right
    pressEnter = new FlxSprite().loadGraphic(Paths.image("IridaMenuAssets/enter"));
    pressEnter.antialiasing = true;
    pressEnter.scale.set(0.75, 0.75); // Scale to 75%
    pressEnter.updateHitbox();
    pressEnterTargetX = (FlxG.width - pressEnter.width) / 2;
    pressEnter.x = FlxG.width; // Start off-screen right
    pressEnter.y = FlxG.height - pressEnter.height - 80;
    pressEnterBaseY = pressEnter.y;
    add(pressEnter);

    // 7) RED COVER SPRITE, always on top
    redCover = new FlxSprite(0, 0);
    redCover.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    redCover.scrollFactor.set(0, 0); // Stays fixed over screen even if camera moves
    redCover.alpha = 0; // Invisible at start
    add(redCover);

    // Music (optional, comment out if not needed)
    if (FlxG.sound.music == null)
        FlxG.sound.playMusic(Paths.music("freakyMenu"), 0.7);

    // --- Camera zoom ---
    FlxG.camera.zoom = 1.2;

    // --- Intro Tweens ---

    // Move top and bottom bars into position
    FlxTween.tween(top1, {y: 0}, 0.8, {ease: flixel.tweens.FlxEase.cubeInOut});
    FlxTween.tween(top2, {y: 0}, 0.8, {ease: flixel.tweens.FlxEase.cubeInOut});
    FlxTween.tween(bottom1, {y: FlxG.height - bottom1.height}, 1, {ease: flixel.tweens.FlxEase.cubeInOut});
    FlxTween.tween(bottom2, {y: FlxG.height - bottom2.height}, 1, {
        ease: flixel.tweens.FlxEase.cubeInOut,
        onComplete: function(_) {
            // Now move in the logo and enter
            FlxTween.tween(logo, {x: logoTargetX}, 0.7, {ease: flixel.tweens.FlxEase.quadInOut});
            FlxTween.tween(pressEnter, {x: pressEnterTargetX}, 0.7, {
                ease: flixel.tweens.FlxEase.quadInOut,
                onComplete: function(_) { introDone = true; }
            });
        }
    });

    // FADE IN CAMERA at the very end
    FlxTween.tween(FlxG.camera, {alpha: 1}, 2, {ease: flixel.tweens.FlxEase.quadOut});
}

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // --- Animate backgrounds upward, looping ---
        bg1.y -= bgUpSpeed * elapsed;
        bg2.y -= bgUpSpeed * elapsed;
        if (bg1.y <= -bg1.height) bg1.y = bg2.y + bg2.height;
        if (bg2.y <= -bg2.height) bg2.y = bg1.y + bg1.height;

        // --- Animate top borders right, looping ---
        top1.x += topBottomSpeed * elapsed;
        top2.x += topBottomSpeed * elapsed;
        if (top1.x >= FlxG.width) top1.x = top2.x - top1.width;
        if (top2.x >= FlxG.width) top2.x = top1.x - top2.width;

        // --- Animate bottom borders right, looping ---
        bottom1.x += topBottomSpeed * elapsed;
        bottom2.x += topBottomSpeed * elapsed;
        if (bottom1.x >= FlxG.width) bottom1.x = bottom2.x - bottom1.width;
        if (bottom2.x >= FlxG.width) bottom2.x = bottom1.x - bottom2.width;

        // --- Bop logo and pressEnter to the beat! ---
        var bpm = 102; // Set to your menu song's real BPM!
        var songPos = FlxG.sound.music != null ? FlxG.sound.music.time : 0;
        var curBeat = (songPos / (60000 / bpm));
        var bopAmount = Math.sin(curBeat * Math.PI) * 12;
        if (logo != null)        logo.y = logoBaseY + bopAmount;
        if (pressEnter != null)  pressEnter.y = pressEnterBaseY + bopAmount;

        // --- Normal input logic (only after intro) ---
        if (introDone && !transitioning)
        {
            var go:Bool = FlxG.keys.justPressed.ENTER;

            #if mobile
            for (t in FlxG.touches.list) if (t.justPressed) go = true;
            #end

            var gp:FlxGamepad = FlxG.gamepads.lastActive;
            if (gp != null && gp.justPressed.START) go = true;

            if (go)
            {
                transitioning = true;
                FlxTween.tween(redCover, {alpha: 1}, 0.25, {
                    onComplete: function(_)
                    {
                        var sound = FlxG.sound.play(Paths.sound("confirmMenu"), 1);
                        FlxTween.num(0, 1, sound.length / 1000, {
                            onComplete: function(_)
                            {
                                FlxG.switchState(new MainMenuState());
                            }
                        });
                    }
                });
            }
        }
    }
}