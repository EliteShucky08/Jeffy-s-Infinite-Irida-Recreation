local allowedSongs = {['execretion'] = true, ['irida'] = true}
function isAllowedSong()
    return allowedSongs[string.lower(songName)]
end

local origScoreY
local txtYOffset = 10
local arrowOrder = getObjectOrder(getPropertyFromGroup('strumLineNotes', 0, 'name'))

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
    setProperty('scoreTxt.x', -30)
    setProperty('scoreTxt.y', 675)
    
    origScoreY = getProperty('scoreTxt.y')

    -- VIGNETTE (unchanged)
    makeLuaSprite('vignette', 'vignette', 0, 0)
    setObjectCamera('vignette', 'other')
    setProperty('vignette.alpha', 0)
    addLuaSprite('vignette', true)
end

function onUpdatePost()
    if not isAllowedSong() then return end

    setProperty('iconP1.x', screenWidth - 190)
    setProperty('iconP2.x', 45)
    setProperty('scoreTxt.y', origScoreY - txtYOffset)
    setProperty('scoreTxt.scale.x', 1)
    setProperty('scoreTxt.scale.y', 1)

    -- Custom scoreTxt formatting
    local accPct = getProperty('ratingPercent') * 100
    local grade = 'D'
    if accPct >= 90 then grade = 'S'
    elseif accPct >= 80 then grade = 'A'
    elseif accPct >= 70 then grade = 'B'
    elseif accPct >= 60 then grade = 'C'
    elseif accPct >= 50 then grade = 'D' end

    local accStr   = string.format('Accuracy: %.2f%% - %s', accPct, grade)
    local missStr  = 'Misses: ' .. getProperty('songMisses')
    local scoreStr = 'Score: ' .. getProperty('songScore')

    -- Increased spaces for wider appearance
    local gapL = '          '  -- (10 spaces)
    local gapR = '          '  -- (10 spaces)

    setTextString('scoreTxt', accStr .. gapL .. missStr .. gapR .. scoreStr)

    -- Keep positions relative to health bar
    local healthBarPosX = getProperty('healthBar.x')
    local healthBarPosY = getProperty('healthBar.y')
    setProperty('scoreTxt.x', healthBarPosX - 160) -- moved further right
    setProperty('scoreTxt.y', healthBarPosY + 20)

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