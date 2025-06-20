

function onCreate()
    -- Your normal BG setup...
    makeLuaSprite('irida1bg', 'IridaBG/irida1bg', 1450, 1650)
    setScrollFactor('irida1bg', 1, 1)
    scaleObject('irida1bg', 2.6, 2.6)
    addLuaSprite('irida1bg', false)

    makeLuaSprite('irida1piano', 'IridaBG/irida1piano', 1400, 2500)
    setScrollFactor('irida1piano', 1, 1)
    scaleObject('irida1piano', 3.5, 3.5)
    addLuaSprite('irida1piano', false)

    makeLuaSprite('bg', 'IridaBG/bg', 1400, 1650)
    setScrollFactor('bg', 1, 1)
    addLuaSprite('bg', false)
    scaleObject('bg', 4, 4)
    setProperty('bg.visible', false)

    makeAnimatedLuaSprite('Pianoportalp2', 'IridaBG/Aethos_phase_2_fanmade', 1500, 1650)
    addAnimationByPrefix('Pianoportalp2', 'idle', 'ezgif-6-1ed231e80e', 24, true)
    addLuaSprite('Pianoportalp2', false)
    scaleObject('Pianoportalp2', 3.5, 3.5)
    setProperty('Pianoportalp2.visible', false)

    makeLuaSprite('Boom', 'IridaBG/Boom', -100, -150)
    setScrollFactor('Boom', 1, 1)
    addLuaSprite('Boom', false)
    scaleObject('Boom', 1.5, 1.5)
    setProperty('Boom.visible', false)

    makeLuaSprite('floor', 'IridaBG/floor', -200, 350)
    setScrollFactor('floor', 1, 1)
    addLuaSprite('floor', false)
    setProperty('floor.visible', false)

    makeLuaSprite('weirdshit', 'IridaBG/weirdshit', 800, 400)
    setScrollFactor('weirdshit', 1.3, 1.3)
    addLuaSprite('weirdshit', true)
    setProperty('weirdshit.visible', false)

    makeAnimatedLuaSprite('Pianoportal', 'IridaBG/Pianoportal', 1500, 1650)
    addAnimationByPrefix('Pianoportal', 'idle', 'ezgif-3-c33f84cd69', 24, true)
    addLuaSprite('Pianoportal', false)
    scaleObject('Pianoportal', 3.5, 3.5)
    setProperty('Pianoportal.visible', false)
end

function onStepHit()
    if curStep == 896 then
        removeLuaSprite('irida1bg')
        removeLuaSprite('irida1piano')
        setProperty('Pianoportal.visible', true)
    end
    if curStep == 1024 then
        removeLuaSprite('Pianoportal')
        setProperty('bg.visible', true)
        setProperty('Pianoportalp2.visible', true)
    end
    if curStep == 1936 then
        removeLuaSprite('bg')
        removeLuaSprite('Pianoportalp2')
        setProperty('Boom.visible', true)
    end
end