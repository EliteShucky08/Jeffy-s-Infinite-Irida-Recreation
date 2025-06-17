-- =============================================================
-- Variables
-- =============================================================
local sectionThresholdBeat = 3456 / 4  -- i know very unorganised but hey it works!
local origScoreY  
local origScoreX  
local txtYOffset       = 10  
local logoTweenTime    = 1    
local logoDisplayDur   = 4   
local targetCamX       = nil
local targetCamY       = nil
local arrowOrder = getObjectOrder(getPropertyFromGroup('strumLineNotes', 0, 'name'))


-- =============================================================
-- onCreate: Initial setup before the song starts
-- =============================================================
function onCreate()
    -- Camera and background setup
    setScrollFactor('gfGroup', 1, 1)
    setProperty('camGame.bgColor', getColorFromHex('000000'))
    setProperty('dad.alpha', 0)
    setProperty('camZoomingMult', 0)
    setProperty('showComboNum', false)

    -- Create and position background sprites (initially hidden)
    makeLuaSprite('iridaShuck', 'iridaShuck', -1250, -330)
    scaleObject('iridaShuck', 0.73, 0.73)
    addLuaSprite('iridaShuck', false)

    makeLuaSprite('shuckfront', 'shuckfront', -1500, -200)
    setScrollFactor('shuckfront', 0.8, 0.8)
    scaleObject('shuckfront', 0.75, 0.85)

    makeLuaSprite('ShucksChains', 'ShucksChains', -650, -140)
    setScrollFactor('ShucksChains', 1, 1)
    scaleObject('ShucksChains', 0.6, 0.7)

    makeLuaSprite('ShucksHook', 'ShucksHook', -850, -250)
    setScrollFactor('ShucksHook', 1, 1)
    scaleObject('ShucksHook', 0.6, 0.7)

    makeLuaSprite('ShucksIlumination', 'ShucksIlumination', -1200, -390)
    setScrollFactor('ShucksIlumination', 0.62, 0.62)
    scaleObject('ShucksIlumination', 0.6, 0.7)

    makeLuaSprite('shuckchairbg', 'bg', 200, -100)
    scaleObject('shuckchairbg', 2.5, 2.5)

    makeLuaSprite('shuckchairfg', 'shuckchairfg', -130, -75)
    scaleObject('shuckchairfg', 0.85, 0.85)

    makeLuaSprite('shuckchairchains', 'ShuckChains', -600, -100)
    scaleObject('shuckchairchains', 2.5, 2.5)

    -- Add all background sprites (visibility toggled later)
    addLuaSprite('iridaShuck', false)
    addLuaSprite('shuckfront', true)
    addLuaSprite('ShucksChains', true)
    addLuaSprite('ShucksHook', true)
    addLuaSprite('ShucksIlumination', true)
    addLuaSprite('shuckchairbg', false)
    addLuaSprite('shuckchairfg', true)
    addLuaSprite('shuckchairchains', true)

    -- Hide background sprites initially
    setProperty('iridaShuck.visible', false)
    setProperty('shuckfront.visible', false)
    setProperty('ShucksChains.visible', false)
    setProperty('ShucksHook.visible', false)
    setProperty('ShucksIlumination.visible', false)
    setProperty('shuckchairbg.visible', false)
    setProperty('shuckchairfg.visible', false)
    setProperty('shuckchairchains.visible', false)

    -- Logo (HUD)
    makeLuaSprite('logo', 'shuck', -500, screenHeight / 2 - 300)
    setObjectCamera('logo', 'hud')
    scaleObject('logo', 0.2, 0.2)
    addLuaSprite('logo', true)
    setProperty('logo.visible', false)

    -- Vignette overlay (OTHER camera)
    makeLuaSprite('vignette', 'vignette', 0, 0)
    setObjectCamera('vignette', 'other')
    setProperty('vignette.alpha', 0)
    addLuaSprite('vignette', true)

    -- White background static (GAME camera)
    makeAnimatedLuaSprite('whitebg', 'SMMStatic', 0, 0)
    addAnimationByPrefix('whitebg', 'idle', 'damfstatic', 26, true)
    scaleObject('whitebg', 5, 5)
    screenCenter('whitebg', 'xy')
    setObjectCamera('whitebg', 'game')
    setScrollFactor('whitebg', 0, 0)

    -- Red overlay (GAME camera) - initially hidden
    makeLuaSprite('red thing', 'red')
    scaleObject('red thing', 1.5, 1.5)
    screenCenter('red thing', 'xy')
    setObjectCamera('red thing', 'game')
    addLuaSprite('red thing', true)
    setProperty('red thing.visible', false)
    setProperty('red thing.alpha', 0)

    -- Blood overlay (HUD camera)
    makeLuaSprite('blood', 'blood')
    scaleObject('blood', 1, 1)
    screenCenter('blood', 'xy')
    setObjectCamera('blood', 'hud')
    setProperty('blood.alpha', 0)

    -- Shuck text (HUD camera), initially invisible
    makeLuaSprite('shucktext', 'shucktext', -125, 100)
    setObjectCamera('shucktext', 'hud')
    scaleObject('shucktext', 0.8, 0.8)
    setProperty('shucktext.alpha', 0)
    addLuaSprite('shucktext', true)

    -- Momento Peak animated BG (GAME camera)
    makeAnimatedLuaSprite('momento peak', 'evilBG', -1500, -850)
    addAnimationByPrefix('momento peak', 'idle', 'evil', 26, true)
    scaleObject('momento peak', 5, 5)
    setObjectCamera('momento peak', 'hud')
    setScrollFactor('momento peak', 0, 0)
end


-- =============================================================
-- onCreatePost: UI and HUD adjustments
-- =============================================================
function onCreatePost()
    -- Health bar overlay (UI)
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

    -- Score text styling
    setTextFont('scoreTxt', 'Mario Font.ttf')
    setTextSize('scoreTxt', 20)
    setProperty('scoreTxt.color', getColorFromHex('8B0000'))
    setProperty('scoreTxt.borderColor', getColorFromHex('3E0408'))
    setTextBorder('scoreTxt', 1.5, '3E0408')
    setProperty('scoreTxt.x', 130)
    setProperty('scoreTxt.y', 675)

    -- Accuracy text (UI), initially invisible
    makeLuaText('accuracyText', '', 650, 60, 665)
    setTextFont('accuracyText', 'Mario Font.ttf')
    setTextSize('accuracyText', 20)
    setProperty('accuracyText.color', getColorFromHex('8B0000'))
    setProperty('accuracyText.borderColor', getColorFromHex('3E0408'))
    addLuaText('accuracyText')
    addToGroup('uiGroup', 'accuracyText')
    setProperty('accuracyText.alpha', 0)

    -- Store original Y position for scoreTxt
    origScoreY = getProperty('scoreTxt.y')
end


-- =============================================================
-- onSongStart: Order HUD elements
-- =============================================================
function onSongStart()
    local healthBarOverlayOrder = getObjectOrder('uiGroup', 'healthBarOverlay')
    setObjectOrder('iconP1', healthBarOverlayOrder + 97, 'uiGroup')
    setObjectOrder('iconP2', healthBarOverlayOrder + 78, 'uiGroup')
    setObjectOrder('scoreTxt', healthBarOverlayOrder + 98, 'uiGroup')

    setProperty('healthBarOverlay.alpha', 0)
    setProperty('healthBar.alpha',          0)
    setProperty('scoreTxt.alpha',           0)
    setProperty('iconP1.alpha',             0)
    setProperty('iconP2.alpha',             0)
end


-- =============================================================
-- onEvent: Custom animation triggers
-- =============================================================
function onEvent(name, value1, value2)
    if name == 'Play Animation' then
        if value1 == '1' then 
            setProperty('iridaShuck.visible',      true)
            setProperty('shuckfront.visible',      true)
            setProperty('ShucksChains.visible',    true)
            setProperty('ShucksHook.visible',      true)
            setProperty('ShucksIlumination.visible', true)
        end

        if value1 == '2' then 
            removeLuaSprite('iridaShuck')
            removeLuaSprite('shuckfront')
            removeLuaSprite('ShuckChains')
            removeLuaSprite('ShucksHoops')
            removeLuaSprite('ShucksIlumination')

            setProperty('shuckchairbg.visible',    true)
            setProperty('shuckchairfg.visible',    true)
            setProperty('shuckchairchains.visible', true)
        end
    end
end


-- =============================================================
-- onUpdate: Update per frame
-- =============================================================
function onUpdate(elapsed)
    setTextString('botplayTxt', 'Yesnt')
    updateVignetteAlpha()
end


-- =============================================================
-- onUpdatePost: HUD element positions and score/accuracy updates
-- =============================================================
function onUpdatePost()
    -- Move player icons and adjust score text position
    setProperty('iconP1.x', screenWidth - 190)
    setProperty('iconP2.x', 45)
    setProperty('scoreTxt.y', origScoreY - txtYOffset)
    setProperty('scoreTxt.scale.x', 1)
    setProperty('scoreTxt.scale.y', 1)

    -- Build and display "Misses:  X     Score:  Y"
    local missText  = "Misses: " .. getProperty('songMisses')
    local scoreText = "Score: "  .. getProperty('songScore')
    local gap       = string.rep(" ", 10)
    setTextString('scoreTxt', missText .. gap .. scoreText)

    -- Display "Accuracy: XX.XX% - Grade"
    local accPct = getProperty('ratingPercent') * 100
    local grade  = 'D'
    if accPct >= 90 then    grade = 'S'
    elseif accPct >= 80 then grade = 'A'
    elseif accPct >= 70 then grade = 'B'
    elseif accPct >= 60 then grade = 'C' 
    elseif accPct >= 50 then grade = 'D' end

    setTextString('accuracyText',
        string.format("Accuracy: %.2f%% - %s", accPct, grade)
    )

    -- Ensure note pop-ups are visible if note RGB is disabled
    if getProperty("song.disableNoteRGB") then
        local count = getProperty("popGroup.length")
        for i = 0, count - 1 do
            setPropertyFromGroup("popGroup", i, "alpha", 1)
        end
    end
end


-- =============================================================
-- Helper: Update vignette alpha based on health
-- =============================================================
function updateVignetteAlpha()
    local health    = getProperty('health')
    local maxAlpha  = 1.0  
    local minAlpha  = 0.0  
    local alpha     = maxAlpha - (health * maxAlpha)
    alpha = math.max(minAlpha, alpha)
    setProperty('vignette.alpha', alpha)
end


-- =============================================================
-- onStepHit: Step-based events
-- =============================================================
function onStepHit()
    -- Fade in Dad
    if curStep == 156 then
        doTweenAlpha('dadFadeIn', 'dad', 1, 1, 'linear')
    end

    -- Fade in Health Bar Overlay
    if curStep == 504 then
        doTweenAlpha('healthBarOverlayFadeIn', 'healthBarOverlay', 1, 1, 'linear')
    end

    -- Fade in Accuracy Text
    if curStep == 512 then
        doTweenAlpha('accuracyTextFadeIn', 'accuracyText', 0.3, 0.3, 'linear')
    end

    -- Logo introduction at step 768
    if curStep == 768 then
        setProperty('logo.visible', true)
        local logoW   = getProperty('logo.width')
        local targetX = (screenWidth / 2) - (logoW / 2)
        doTweenX('logoIn', 'logo', targetX, logoTweenTime, 'sineInOut')
        runTimer('logoOutTimer', logoDisplayDur, 1)
        doTweenAlpha('accuracyTextFadeIn', 'accuracyText', 1, 0.3, 'linear')
    end

    -- White flash and introduce Momento Peak + red overlay at step 1536
    if curStep == 1536 then
        setProperty('ShucksChains.visible', false)
        setProperty('ShucksHook.visible',   false)
        addLuaSprite('whitebg')
        doTweenAlpha('whitebgFadeIn', 'whitebg', 0.9, 0.7, 'linear')
        addLuaSprite('momento peak')
        setProperty('red thing.visible', true)
        setProperty('red thing.alpha', 1)
    end

    -- End white flash and remove Momento Peak at step 1792
    if curStep == 1792 then
        setProperty('ShucksChains.visible', true)
        setProperty('ShucksHook.visible',   true)
        setProperty('whitebg.alpha',        0)
        removeLuaSprite('momento peak')
        setProperty('red thing.visible',    false)
        setProperty('red thing.alpha', 0)
    end

    -- Fade out HUD elements at step 2560
    if curStep == 2560 then
        doTweenAlpha('healthBarOverlayFadeOut', 'healthBarOverlay', 0, 0.1, 'linear')
        setProperty('accuracyText.alpha', 0)
    end

    -- At step 2765, show blood sprite and red overlay
    if curStep == 2765 then
        addLuaSprite('blood')
        doTweenAlpha('bloodFadeIn',      'blood',    1, 1, 'linear')
    end

    -- Fade out accuracy, blood, and red overlays at step 3172
    if curStep == 3172 then
        doTweenAlpha('accuracyTextFadeOut', 'accuracyText', 0, 0.7, 'linear')
        doTweenAlpha('bloodFadeOut',          'blood',        0, 0.7, 'linear')
    end

    -- Change background and fade in shucktext at step 3456
    if curStep == 3456 then
        setProperty('camGame.bgColor', getColorFromHex('000000'))
        setProperty('accuracyText.alpha', 1)
        doTweenAlpha('shucktextFadeIn', 'shucktext', 0.7, 0.5, 'linear')
        doTweenAlpha('bloodFadeIn',      'blood',    1, 0.1, 'linear')
    end

    -- Fade out shucktext at step 3480
    if curStep == 3480 then
        doTweenAlpha('shucktextFadeIn', 'shucktext', 0, 0.7, 'linear')
    end

    -- Fade out chair sprites and accuracy text at step 3696
    if curStep == 3696 then
        doTweenAlpha('accuracyTextFadeOut', 'accuracyText', 0, 1, 'linear')
        doTweenAlpha('shuckchairbgFadeOut', 'shuckchairbg',       0.2, 0.5, 'linear')
        doTweenAlpha('shuckchairfgFadeOut', 'shuckchairfg',       0.2, 0.5, 'linear')
        doTweenAlpha('bloodFadeIn',      'blood',    0, 1, 'linear')
    end

    -- Fade in chair sprites and accuracy text at step 3712
    if curStep == 3712 then
        doTweenAlpha('accuracyTextFadeIn',   'accuracyText',   1, 0.5, 'linear') 
         doTweenAlpha('bloodFadeIn',      'blood',    1, 0.1, 'linear')
        setProperty('shuckchairbg.alpha',    1)
        setProperty('shuckchairfg.alpha',    1)
    end

    if curStep == 4480 then
        doTweenAlpha('accuracyTextFadeIn',   'accuracyText',   0, 2, 'linear') 
    end

    -- Fade in health bar overlay again at step 2816
    if curStep == 2816 then
        doTweenAlpha('healthBarOverlayFadeInReturn', 'healthBarOverlay', 1, 0.5, 'linear')
    end

    -- (Duplicated step 2816 tween removed; same as above)
end


-- =============================================================
-- onSectionHit: Section-based camera zoom
-- =============================================================
function onSectionHit()
    triggerEvent('Add Camera Zoom', '0.04', '0.04')
end


-- =============================================================
-- onBeatHit: Beat-based camera zoom behavior
-- =============================================================
function onBeatHit()
    if curBeat < sectionThresholdBeat then
        -- Zoom at the start of each 16-beat section
        if curBeat % 16 == 0 then
            triggerEvent('Add Camera Zoom', '0.06', '0.06')
        end
    else
        -- After step 3456, zoom on every beat
        triggerEvent('Add Camera Zoom', '0.06', '0.06')
    end
end


-- =============================================================
-- onTimerCompleted: Timer event callbacks
-- =============================================================
function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'logoOutTimer' then
        -- Tween logo off to the right
        local offX = screenWidth + getProperty('logo.width')
        doTweenX('logoOut', 'logo', offX, logoTweenTime, 'sineInOut')
    end
end
