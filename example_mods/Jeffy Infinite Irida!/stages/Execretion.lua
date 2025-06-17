function onCreate()
    makeLuaSprite('stage', 'ExcretionBG/stage', 200, 1100) 
    setScrollFactor('stage', 1, 1)
    scaleObject('stage', 3.5, 3.5) 
    addLuaSprite('stage', false) 

    makeLuaSprite('fg', 'ExcretionBG/fg', -450, 1500)
    setScrollFactor('fg', 1, 1)
    scaleObject('fg', 3, 3)
    addLuaSprite('fg', true) 
end