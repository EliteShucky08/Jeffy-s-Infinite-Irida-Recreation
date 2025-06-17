package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import flixel.util.FlxStringUtil; // For formatBytes

class FPSCounter extends TextField
{
    public var currentFPS(default, null):Int;
    public var memoryMegas(get, never):Float;

    @:noCompletion private var times:Array<Float>;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFFFF)
    {
        super();

        this.x = x;
        this.y = y;

        currentFPS = 0;
        selectable = false;
        mouseEnabled = false;
        // Use VCR font for the default format (for fallback)
        defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 22, color, true);
        autoSize = LEFT;
        multiline = true;
        text = "FPS: ";

        times = [];
    }

    var deltaTimeout:Float = 0.0;

    private override function __enterFrame(deltaTime:Float):Void
    {
        final now:Float = haxe.Timer.stamp() * 1000;
        times.push(now);
        while (times[0] < now - 1000) times.shift();
        if (deltaTimeout < 50) {
            deltaTimeout += deltaTime;
            return;
        }

        currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
        updateText();
        deltaTimeout = 0.0;
    }

    public dynamic function updateText():Void {
        var font = Paths.font("vcr.ttf");
        // FPS line: big number, small "FPS" next to it
        var fpsString = '<font face="$font" size="32"><b>${currentFPS}</b></font><font face="$font" size="15"> FPS</font>';

        // Memory: used only, MB, 2 decimals, faded duplicate after /
        var used:Float = memoryMegas / (1024 * 1024);
        var memMB = (Math.round(used * 100) / 100) + 'MB';
        var memString =
            '<font face="$font" size="15">' + memMB + 
            '</font><font face="$font" size="15"> / </font>' +
            '<font face="$font" size="15" color="#888888">' + memMB + '</font>';

        // Engine name
        var engineString = '<font face="$font" size="15">Jeffy\'s Infinite Irida</font>';

        htmlText = fpsString + "<br>" + memString + "<br>" + engineString;
        textColor = 0xFFFFFFFF;
    }

    inline function get_memoryMegas():Float
        return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}