package objects;  // WASTED AN ENTIRE FUCKING DAY FIXING THIS SHIT

import haxe.Json;
import openfl.utils.Assets;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import sys.FileSystem;
import sys.io.File;

enum Alignment
{
    LEFT;
    CENTERED;
    RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
    public var text(default, set):String;

    public var bold:Bool = false;
    public var letters:Array<AlphaCharacter> = [];

    public var isMenuItem:Bool = false;
    public var targetY:Int = 0;
    public var changeX:Bool = true;
    public var changeY:Bool = true;

    public var alignment(default, set):Alignment = LEFT;
    public var scaleX(default, set):Float = 1;
    public var scaleY(default, set):Float = 1;
    public var rows:Int = 0;

    public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);

    public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
    {
        super(x, y);

        this.startPosition.set(x, y);
        this.bold = bold;
        this.text = text;
    }

    public function setAlignmentFromString(align:String)
    {
        switch(align.toLowerCase().trim())
        {
            case 'right':
                alignment = RIGHT;
            case 'center', 'centered':
                alignment = CENTERED;
            default:
                alignment = LEFT;
        }
    }

    private function set_alignment(align:Alignment)
    {
        alignment = align;
        updateAlignment();
        return align;
    }

    private function updateAlignment()
    {
        for (letter in letters)
        {
            var newOffset:Float = switch (alignment)
            {
                case CENTERED: letter.rowWidth / 2;
                case RIGHT:    letter.rowWidth;
                default:       0;
            }

            letter.offset.x -= letter.alignOffset;
            letter.alignOffset = newOffset * scale.x;
            letter.offset.x += letter.alignOffset;
        }
    }

    private function set_text(newText:String)
    {
        newText = newText.replace('\\n', '\n');
        clearLetters();
        createLetters(newText);
        updateAlignment();
        this.text = newText;
        return newText;
    }

    public function clearLetters()
    {
        for (letter in letters)
        {
            if (letter != null) remove(letter, true);
        }
        letters.resize(0);
        rows = 0;
    }

    public function setScale(newX:Float, newY:Null<Float> = null)
    {
        if (newY == null) newY = newX;

        final lastX = scale.x;
        final lastY = scale.y;

        scaleX = newX;
        scaleY = newY;

        softReloadLetters(newX / lastX, newY / lastY);
    }

    private function set_scaleX(value:Float)
    {
        if (value == scaleX) return value;
        final ratio = value / scale.x;
        scale.x = value;
        scaleX   = value;
        softReloadLetters(ratio, 1);
        return value;
    }

    private function set_scaleY(value:Float)
    {
        if (value == scaleY) return value;
        final ratio = value / scale.y;
        scale.y = value;
        scaleY   = value;
        softReloadLetters(1, ratio);
        return value;
    }

    public function softReloadLetters(ratioX:Float = 1, ratioY:Null<Float> = null)
    {
        if (ratioY == null) ratioY = ratioX;

        for (letter in letters)
        {
            if (letter != null)
            {
                letter.setupAlphaCharacter(
                    (letter.x - x) * ratioX + x,
                    (letter.y - y) * ratioY + y
                );
            }
        }
    }

    override function update(elapsed:Float)
    {
        if (isMenuItem)
        {
            final lerpVal = Math.exp(-elapsed * 9.6);
            if (changeX) x = FlxMath.lerp((targetY * distancePerItem.x) + startPosition.x, x, lerpVal);
            if (changeY) y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y) + startPosition.y, y, lerpVal);
        }
        super.update(elapsed);
    }

    public function snapToPosition()
    {
        if (isMenuItem)
        {
            if (changeX) x = (targetY * distancePerItem.x) + startPosition.x;
            if (changeY) y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
        }
    }

    private static inline var Y_PER_ROW:Float = 85;

    private function createLetters(newText:String)
    {
        if (AlphaCharacter.allLetters == null)
            AlphaCharacter.loadAlphabetData();

        var consecutiveSpaces = 0;
        var xPos:Float = 0;
        var rowData:Array<Float> = [];
        rows = 0;

        for (i in 0...newText.length)
        {
            final character = newText.charAt(i);

            if (character != '\n')
            {
                final spaceChar = (character == " " || (bold && character == "_"));
                if (spaceChar) consecutiveSpaces++;

                if (AlphaCharacter.allLetters.exists(character.toLowerCase()) && (!bold || !spaceChar))
                {
                    if (consecutiveSpaces > 0)
                    {
                        xPos += 28 * consecutiveSpaces * scaleX;
                        rowData[rows] = xPos;
                        if (!bold && xPos >= FlxG.width * 0.65)
                        {
                            xPos = 0;
                            rows++;
                        }
                    }
                    consecutiveSpaces = 0;

                    final letter:AlphaCharacter = cast recycle(AlphaCharacter, true);
                    letter.scale.set(scaleX, scaleY);
                    letter.rowWidth = 0;

                    letter.setupAlphaCharacter(xPos, rows * Y_PER_ROW * scale.y, character, bold);
                    @:privateAccess letter.parent = this;

                    letter.row = rows;
                    final off = bold ? 0 : 2;
                    xPos += letter.width + (letter.letterOffset[0] + off) * scale.x;
                    rowData[rows] = xPos;

                    add(letter);
                    letters.push(letter);
                }
            }
            else
            {
                xPos = 0;
                rows++;
            }
        }

        for (letter in letters)
            letter.rowWidth = rowData[letter.row] / scale.x;

        if (letters.length > 0) rows++;
    }
}

// ===========================================================================
// AlphaCharacter
// ===========================================================================

typedef Letter =
{
    ?anim:Null<String>,
    ?offsets:Array<Float>,
    ?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
    public var image(default, set):String;
    public static var allLetters:Map<String, Null<Letter>>;

    // ---------------------------------------------------------------------
    // Utility – safe lookup
    // ONLY FALL BACK TO '?' IF KEY IS MISSING!
    // ---------------------------------------------------------------------
    private static inline function getSafeLetter(ch:String):Letter
    {
        if (allLetters == null) loadAlphabetData();
        if (allLetters.exists(ch))
            return allLetters[ch]; // can be null, that's OK! (means use default frame)
        if (!allLetters.exists('?'))
            allLetters.set('?', { anim:'question' });
        return allLetters['?'];
    }

    public static function loadAlphabetData(request:String = 'alphabet')
    {
        var path = Paths.getPath('images/$request.json');
        #if MODS_ALLOWED
        if (!FileSystem.exists(path))
        #else
        if (!Assets.exists(path, TEXT))
        #end
            path = Paths.getPath('images/alphabet.json');

        allLetters = new Map<String, Null<Letter>>();

        try
        {
            #if MODS_ALLOWED
            final data:Dynamic = Json.parse(File.getContent(path));
            #else
            final data:Dynamic = Json.parse(Assets.getText(path));
            #end

            if (data.allowed != null && data.allowed.length > 0)
            {
                for (i in 0...data.allowed.length)
                {
                    final ch = data.allowed.charAt(i);
                    if (ch != ' ') allLetters.set(ch.toLowerCase(), null);
                }
            }

            if (data.characters != null)
            {
                for (char in Reflect.fields(data.characters))
                {
                    final letterData = Reflect.field(data.characters, char);
                    final c = char.toLowerCase().substr(0, 1);
                    if ((letterData.animation != null || letterData.normal != null || letterData.bold != null)
                        && allLetters.exists(c))
                    {
                        allLetters[c] = {
                            anim       : letterData.animation,
                            offsets    : letterData.normal,
                            offsetsBold: letterData.bold
                        };
                    }
                }
            }
            trace('Reloaded letters successfully ($path)!');
        }
        catch (e:Dynamic)
        {
            FlxG.log.error('Error loading alphabet data: $e');
        }

        if (!allLetters.exists('?'))
            allLetters.set('?', { anim:'question' });
    }

    var parent:Alphabet;
    public var alignOffset:Float = 0;
    public var letterOffset:Array<Float> = [0, 0];
    public var row:Int = 0;
    public var rowWidth:Float = 0;
    public var character:String = '?';
    public var curLetter:Letter = null;

    public function new()
    {
        super();
        image = 'alphabet';
        antialiasing = ClientPrefs.data.antialiasing;
    }

    public function setupAlphaCharacter(x:Float, y:Float, ?character:String = null, ?bold:Null<Bool> = null)
    {
        if (allLetters == null) loadAlphabetData();

        this.x = x;
        this.y = y;

        if (parent != null)
        {
            if (bold == null) bold = parent.bold;
            scale.set(parent.scaleX, parent.scaleY);
        }

        if (character != null)
        {
            this.character = character;
            final lowercase = character.toLowerCase();

            curLetter = getSafeLetter(lowercase);

            var postfix = '';
            if (!bold)
            {
                if (isTypeAlphabet(lowercase))
                    postfix = (lowercase != character) ? ' uppercase' : ' lowercase';
                else
                    postfix = ' normal';
            }
            else
                postfix = ' bold';

            var alphaAnim = (curLetter != null && curLetter.anim != null) ? curLetter.anim : lowercase;
            var animName  = alphaAnim + postfix;

            animation.addByPrefix(animName, animName, 24);
            animation.play(animName, true);

            if (animation.curAnim == null)
            {
                if (postfix != ' bold') postfix = ' normal';
                animName = 'question' + postfix;
                animation.addByPrefix(animName, animName, 24);
                animation.play(animName, true);
            }
        }
        updateHitbox();
    }

    public static inline function isTypeAlphabet(c:String)
    {
        final ascii = StringTools.fastCodeAt(c, 0);
        return (ascii >= 65 && ascii <= 90)
            || (ascii >= 97 && ascii <= 122)
            || (ascii >= 192 && ascii <= 214)
            || (ascii >= 216 && ascii <= 246)
            || (ascii >= 248 && ascii <= 255);
    }

    private function set_image(name:String)
    {
        if (frames == null)
        {
            image  = name;
            frames = Paths.getSparrowAtlas(name);
            return name;
        }

        final lastAnim = (animation != null) ? animation.name : null;

        image  = name;
        frames = Paths.getSparrowAtlas(name);
        if (parent != null) scale.set(parent.scaleX, parent.scaleY);
        alignOffset = 0;

        if (lastAnim != null)
        {
            animation.addByPrefix(lastAnim, lastAnim, 24);
            animation.play(lastAnim, true);
            updateHitbox();
        }
        return name;
    }

    public function updateLetterOffset()
    {
        if (animation.curAnim == null) return;

        var add:Float = animation.curAnim.name.endsWith('bold') ? 70 : 110;

        if (animation.curAnim.name.endsWith('bold'))
        {
            if (curLetter != null && curLetter.offsetsBold != null)
                letterOffset = curLetter.offsetsBold.copy();
        }
        else if (curLetter != null && curLetter.offsets != null)
        {
            letterOffset = curLetter.offsets.copy();
        }

        add *= scale.y;
        offset.x += letterOffset[0] * scale.x;
        offset.y += letterOffset[1] * scale.y - (add - height);
    }

    override public function updateHitbox()
    {
        super.updateHitbox();
        updateLetterOffset();
    }
}