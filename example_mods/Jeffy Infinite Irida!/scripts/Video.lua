--------------------------------------------------------------------
--  Extra-videos for the song “Shucks” (Psych Engine FunkinLua)   --
--  intro  → at song start                                         --
--  toldyou → at step  435                                         --
--  fault   → at step 3188                                         --
--------------------------------------------------------------------

-- keep references so we can pause / resume / destroy them
local introVideo, toldyouVideo, faultVideo = nil, nil, nil

local allowVideos = false      -- true only for the wanted chart


---------------------------------------------------------------
-- called as soon as the Lua is created                       --
---------------------------------------------------------------
function onCreate()
    -- only enable this script for the chart “shucks”
    if songName:lower() == 'shucks' then
        allowVideos = true
    end
end


---------------------------------------------------------------
-- INTRO : plays right after the countdown                    --
---------------------------------------------------------------
function onSongStart()
    if not allowVideos or introVideo then return end

    --  startVideo(name, forMidSong, canSkip, loop, playOnLoad)
    introVideo = startVideo('intro', true, true, false, true)

    if introVideo then
        introVideo.finishCallback = function() introVideo = nil end
    else
        debugPrint('Intro video not found! ('..Paths.video('intro')..')')
    end
end


---------------------------------------------------------------
-- MID-SONG videos                                             --
---------------------------------------------------------------
function onStepHit()
    if not allowVideos then return end

    -- ToldYou (step 435)
    if curStep == 435 and not toldyouVideo then
        toldyouVideo = startVideo('toldyou', true, true, false, true)
        if toldyouVideo then
            toldyouVideo.finishCallback = function() toldyouVideo = nil end
        else
            debugPrint('ToldYou video not found! ('..Paths.video('toldyou')..')')
        end
    end

    -- Fault (step 3188)
    if curStep == 3187 and not faultVideo then
        faultVideo = startVideo('fault', true, true, false, true)
        if faultVideo then
            -- Make arrows (strumLineNotes) appear in front of the video:
            -- Get the order of strumLineNotes, set video just behind it
            runHaxeCode([[
                var vidName = "]] .. faultVideo.name .. [[";
                if (game.modchartSprites.exists(vidName)) {
                    game.modchartSprites.get(vidName).cameras = [game.camOther];
                    game.setObjectOrder(vidName, game.getObjectOrder('strumLineNotes') - 1);
                }
            ]])
            faultVideo.finishCallback = function() faultVideo = nil end
        else
            debugPrint('Fault video not found! ('..Paths.video('fault')..')')
        end
    end
end


---------------------------------------------------------------
-- Pause / Resume handling                                     --
---------------------------------------------------------------
function onPause()
    if not allowVideos then return end
    if introVideo   then introVideo:pause()   end
    if toldyouVideo then toldyouVideo:pause() end
    if faultVideo   then faultVideo:pause()   end
end

function onResume()
    if not allowVideos then return end
    if introVideo   then introVideo:resume()   end
    if toldyouVideo then toldyouVideo:resume() end
    if faultVideo   then faultVideo:resume()   end
end