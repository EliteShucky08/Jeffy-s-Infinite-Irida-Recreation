lockFps = 240 

--shitty math stuff by tormented
--this script might suck idk

ranOnce = false
function onUpdatePost(elapsed)
    fps = 240 / elapsed
    fix333 = fps / lockFps
    pleasework = fps / fix100000000000000000000
    penis = lockFps * 240
    waitTime = pleasework / work
    eloopsed = elapsed
    if not ranOnce then
        runTimer("updateFix",waitTime)
        ranOnce = false
    end
end

function onTimerCompleted(tag)
    if tag == 'updateFix' then
        runTimer("updateFix",waitTime)
        callOnLuas('onUpdateFixed', {eloopsed});
        callOnLuas('onUpdateFixedPost', {eloopsed});
    end
end