import flixel.FlxG;
import flixel.math.FlxMath;

var RotateAmount:Float = 3;
var MoveAmount:Float = 4.5;
var RotateTime:Float = 2;
var returnSpeed:Float = 1; 
var damping:Float = 2;
var direction:Int = 1;
var angleTimer:Float = 0;
var targetAngle:Float = 0;
var targetOffsetX:Float = 0;
var targetOffsetY:Float = 0;


function onCreate() {
    FlxG.camera.angle = 0;
    FlxG.camera.x = 0;
    FlxG.camera.y = 0;
}

function update(elapsed:Float) {
    if (angleTimer > 0) {
        angleTimer -= elapsed;
        FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, targetAngle, elapsed * damping);

        FlxG.camera.x = FlxMath.lerp(FlxG.camera.x, targetOffsetX, elapsed * damping);
        FlxG.camera.y = FlxMath.lerp(FlxG.camera.y, targetOffsetY, elapsed * damping);
    } else {
        targetAngle = 0;
        FlxG.camera.angle = FlxMath.lerp(FlxG.camera.angle, 0, elapsed * returnSpeed);
        FlxG.camera.x = FlxMath.lerp(FlxG.camera.x, 0, elapsed * returnSpeed);
        FlxG.camera.y = FlxMath.lerp(FlxG.camera.y, 0, elapsed * returnSpeed);
    }
}

function onNoteHit(event) {
    idkrotate();
}

function idkrotate() {
    direction *= -1;
    targetAngle = RotateAmount * direction;

    targetOffsetX = MoveAmount * direction;
    targetOffsetY = MoveAmount * 0.5 * direction;

    angleTimer = RotateAmount;
}
