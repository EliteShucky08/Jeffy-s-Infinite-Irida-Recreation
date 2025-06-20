local defaultCamZoom
local defaultCamZoomingDecay
local camZoomingDecay
local customZoomActive = false

function onCreate()
    defaultCamZoom = getProperty('defaultCamZoom')
    defaultCamZoomingDecay = getProperty('camZoomingDecay')
    camZoomingDecay = defaultCamZoomingDecay
    setProperty('camZoomingMult', 0)
    setProperty('camZoomingDecay', 0)
end

function onEvent(eventName, value1, value2, strumTime)
    if eventName == 'Set Camera Zoom' then
        cancelTween('camZoom')

        -- If value1 is empty or "reset", restore default engine zoom
        if value1 == '' or string.lower(value1) == 'reset' then
            setProperty('defaultCamZoom', defaultCamZoom)
            setProperty('camZoomingDecay', defaultCamZoomingDecay)
            setProperty('camZoomingMult', 1)
            customZoomActive = false
            return
        end

        customZoomActive = true

        local zoomData = stringSplit(value1, ',')
        if zoomData[2] == 'stage' then
            targetZoom = tonumber(zoomData[1]) * defaultCamZoom
        else
            targetZoom = tonumber(zoomData[1])
        end

        if value2 == '' then
            setProperty('defaultCamZoom', targetZoom)
        else
            local tweenData = stringSplit(value2, ',')
            local duration = stepCrochet * tonumber(tweenData[1]) / 1000
            if tweenData[2] == nil then
                tweenData[2] = 'linear'
            end
            if version == '1.0' then
                tweenNameAdd = 'tween_'
            else
                tweenNameAdd = ''
            end
            startTween(tweenNameAdd..'camZoom', 'this', {defaultCamZoom = targetZoom}, duration, {ease = tweenData[2]})
        end
    end

    -- Compatibility for this event with the custom zoom behaviour
    if eventName == 'Add Camera Zoom' then
        if cameraZoomOnBeat == true and getProperty('camGame.zoom') < 1.35 then
            zoomAdd = tonumber(value1)
            if zoomAdd == nil then
                zoomAdd = 0.015
            end
            zoomMultiplier = zoomMultiplier + zoomAdd
        end
    end
end

zoomMultiplier = 1
cameraZoomRate = 4
cameraZoomMult = 1

function onBeatHit()
    if cameraZoomRate > 0 and cameraZoomOnBeat == true and not customZoomActive then
        if getProperty('camGame.zoom') < 1.35 and curBeat % cameraZoomRate == 0 then
            zoomMultiplier = zoomMultiplier + 0.015 * cameraZoomMult
            setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03 * cameraZoomMult)
        end
    end
end

function onUpdatePost(elapsed)
    if getProperty('inCutscene') == false and getProperty('endingSong') == false then 
        if cameraZoomRate > 0 then
            if customZoomActive then
                zoomMultiplier = math.lerp(1, zoomMultiplier, math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate))
                setProperty('camGame.zoom', getProperty('defaultCamZoom') * zoomMultiplier)
                setProperty('camHUD.zoom', math.lerp(1, getProperty('camHUD.zoom'), math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate)))
            end
            -- If not customZoomActive, the engine's default zoom logic will take over
        end
    end
end

function math.lerp(a, b, ratio)
    return a + ratio * (b - a)
end