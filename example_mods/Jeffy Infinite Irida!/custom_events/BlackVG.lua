local blackCreated = false

function onEvent(name, value1, value2)
    if name == 'BlackVG' then
        -- create the sprite once
        if not blackCreated then
            makeLuaSprite('black', 'blacksonk', 0, 0)
            setObjectCamera('black', 'hud')  -- draws even during pause
            scaleObject('black', 1.05, 1)
            setObjectOrder('black', 5)
            addLuaSprite('black', true)
            setProperty('black.alpha', 0)
            blackCreated = true
        end

        -- fade in to 40% over `value1` seconds
        if value1 ~= '' then
            local tIn = tonumber(value1)
            if tIn then
                doTweenAlpha('blackFadeIn', 'black', 1, tIn, 'quadInOut')
            end
        end

        -- fade out to 0% over `value2` seconds
        if value2 ~= '' then
            local tOut = tonumber(value2)
            if tOut then
                doTweenAlpha('blackFadeOut', 'black', 0, tOut, 'quadInOut')
            end
        end
    end
end
