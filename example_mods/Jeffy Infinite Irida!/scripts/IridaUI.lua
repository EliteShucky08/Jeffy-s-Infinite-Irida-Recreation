-- Separated UI Script: healthBarOverlay, scoreTxt, accuracyText

local origScoreY
local txtYOffset = 10
local arrowOrder = getObjectOrder(getPropertyFromGroup('strumLineNotes', 0, 'name'))

-- Only enable for these songs
local allowedSongs = {['execretion'] = true, ['irida'] = true}

function isAllowedSong()
    return allowedSongs[string.lower(songName)]
end

function onCreate()
     setProperty("skipCountdown", true)
end

function onCreatePost()
    if not isAllowedSong() then return end

    local healthBarPosX = getProperty('healthBar.x')
    local healthBarPosY = getProperty('healthBar.y')
    setProperty('showRating', false)

    makeLuaSprite('healthBarOverlay', 'iridaHealthBar', 46, 10)
    scaleObject('healthBarOverlay', 1.05, 0.95)
    setProperty('healthBarOverlay.x', healthBarPosX - 142)
    setProperty('healthBarOverlay.y', healthBarPosY - 85)
    addLuaSprite('healthBarOverlay', false)
    setObjectOrder('healthBarOverlay', arrowOrder + 1)
    addToGroup('uiGroup', 'healthBarOverlay')

    setTextFont('scoreTxt', 'Mario Font.ttf')
    setTextSize('scoreTxt', 20)
    setProperty('scoreTxt.color', getColorFromHex('8B0000'))
    setProperty('scoreTxt.borderColor', getColorFromHex('3E0408'))
    setTextBorder('scoreTxt', 1.5, '3E0408')
    setProperty('scoreTxt.x', 105)
    setProperty('scoreTxt.y', 675)

    makeLuaText('accuracyText', '', 650, 60, 665)
    setTextFont('accuracyText', 'Mario Font.ttf')
    setTextSize('accuracyText', 20)
    setProperty('accuracyText.color', getColorFromHex('8B0000'))
    setProperty('accuracyText.borderColor', getColorFromHex('3E0408'))
    addLuaText('accuracyText')
    addToGroup('uiGroup', 'accuracyText')

    -- Black vignette overlay for low-health effect
    makeLuaSprite('vignette', 'vignette', 0, 0)
    setObjectCamera('vignette', 'other')
    setProperty('vignette.alpha', 0)
    addLuaSprite('vignette', true)

    origScoreY = getProperty('scoreTxt.y')
end

function onUpdatePost()
    if not isAllowedSong() then return end

    setProperty('iconP1.x', screenWidth - 190)
    setProperty('iconP2.x', 45)
    setProperty('scoreTxt.y', origScoreY - txtYOffset)
    setProperty('scoreTxt.scale.x', 1)
    setProperty('scoreTxt.scale.y', 1)

    local missText  = "Misses: " .. getProperty('songMisses')
    local scoreText = "Score: "  .. getProperty('songScore')
    local gap       = string.rep(" ", 10)
    setTextString('scoreTxt', missText .. gap .. scoreText)

    local accPct = getProperty('ratingPercent') * 100
    local grade = 'D'
    if accPct >= 90 then grade = 'S'
    elseif accPct >= 80 then grade = 'A'
    elseif accPct >= 70 then grade = 'B'
    elseif accPct >= 60 then grade = 'C'
    elseif accPct >= 50 then grade = 'D' end

    setTextString('accuracyText',
        string.format("Accuracy: %.2f%% - %s", accPct, grade)
    )

    if getProperty("song.disableNoteRGB") then
        local count = getProperty("popGroup.length")
        for i = 0, count - 1 do
            setPropertyFromGroup("popGroup", i, "alpha", 1)
        end
    end

    -- Blackout effect: Increase vignette alpha as health gets lower
    local health    = getProperty('health')
    local maxAlpha  = 1.0
    local minAlpha  = 0.0
    local alpha     = maxAlpha - (health * maxAlpha)
    alpha = math.max(minAlpha, alpha)
    setProperty('vignette.alpha', alpha)
end

function onSongStart()
    if not isAllowedSong() then return end

    local healthBarOverlayOrder = getObjectOrder('uiGroup', 'healthBarOverlay')
    setObjectOrder('iconP1', healthBarOverlayOrder + 97, 'uiGroup')
    setObjectOrder('iconP2', healthBarOverlayOrder + 78, 'uiGroup')
    setObjectOrder('scoreTxt', healthBarOverlayOrder + 98, 'uiGroup')
end