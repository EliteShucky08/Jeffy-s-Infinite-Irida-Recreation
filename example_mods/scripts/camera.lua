local BfOfs = 50
local GfOfs = 50
local DadOfs = 50

local BfOfsX = 0
local BfOfsY = 0

local GfOfsX = 0
local GfOfsY = 0

local targetX = 0
local targetY = 0

local targetXMove = 0
local targetYMove = 0
local DadOfsX = 0
local DadOfsY = 0

local enableSystem = true

local currentTarget = ''
local currentSection = nil
local firstSection = false

-- 🔄 VARIABLES NUEVAS
local angleAmount = 1.7                -- inclinación de la cámara
local targetAngle = 0
local targetCamY = 0
local verticalCamIntensity = 0.7    -- 🔧 fuerza del movimiento vertical de cámara
local angleLerpSpeed = 0.02         -- 🔄 velocidad de interpolación de la inclinación, más suave

function onCreatePost()
    setProperty('camFollowPos.x', getProperty('dadGroup.x') + (getProperty('boyfriendGroup.x') - getProperty('dadGroup.x')))
    setProperty('camFollowPos.y', getProperty('dadGroup.y'))
    if songName == 'Phantasm' then
        BfOfsX = 100
    elseif songName == 'Leak ma Balls' then
        enableSystem = false
    end
end

function onBeatHit()
    if curBeat % 4 == 0 and currentSection == nil then
        currentSection = ''
    end
end

function onUpdate(elapsed)
    if enableSystem == true and getProperty('isCameraOnForcedPos') == false then
        if currentSection ~= nil then
            if gfSection ~= true then
                if mustHitSection == false then
                    if currentSection ~= 'dad' then
                        currentTarget = 'dad'
                        currentSection = 'dad'
                    end
                else
                    if currentSection ~= 'boyfriend' then
                        currentTarget = 'boyfriend'
                        currentSection = 'boyfriend'
                    end
                end
            else
                if currentSection ~= 'gf' then
                    currentTarget = 'gf'
                    currentSection = 'gf'
                end
            end
        end

        targetXMove = 0
        targetYMove = 0
        targetAngle = 0

        -- Cálculo de la posición y la inclinación para el objetivo actual
        if currentTarget == 'boyfriend' then
            local bfAnim = getProperty('boyfriend.animation.curAnim.name')
            targetX = getMidpointX('boyfriend') - 50 - getProperty('boyfriend.cameraPosition[0]') + getProperty('boyfriendCameraOffset[0]') + BfOfsX
            targetY = getMidpointY('boyfriend') - 100 + getProperty('boyfriend.cameraPosition[1]') + getProperty('boyfriendCameraOffset[1]') + BfOfsY

            if string.find(bfAnim, 'singLEFT', 0, true) then
                targetXMove = -BfOfs
                targetAngle = -angleAmount  -- Inclinación hacia la izquierda
            elseif string.find(bfAnim, 'singDOWN', 0, true) then
                targetYMove = BfOfs * verticalCamIntensity
            elseif string.find(bfAnim, 'singUP', 0, true) then
                targetYMove = -BfOfs * verticalCamIntensity
            elseif string.find(bfAnim, 'singRIGHT', 0, true) then
                targetXMove = BfOfs
                targetAngle = angleAmount  -- Inclinación hacia la derecha
            end

        elseif currentTarget == 'dad' then
            local dadAnim = getProperty('dad.animation.curAnim.name')
            targetX = getMidpointX('dad') + 150 + getProperty('dad.cameraPosition[0]') + getProperty('opponentCameraOffset[0]') + DadOfsX
            targetY = getMidpointY('dad') - 100 + getProperty('dad.cameraPosition[1]') + getProperty('opponentCameraOffset[1]') + DadOfsY

            if string.find(dadAnim, 'singLEFT', 0, true) then
                targetXMove = -DadOfs
                targetAngle = -angleAmount  -- Inclinación hacia la izquierda
            elseif string.find(dadAnim, 'singDOWN', 0, true) then
                targetYMove = DadOfs * verticalCamIntensity
            elseif string.find(dadAnim, 'singUP', 0, true) then
                targetYMove = -DadOfs * verticalCamIntensity
            elseif string.find(dadAnim, 'singRIGHT', 0, true) then
                targetXMove = DadOfs
                targetAngle = angleAmount  -- Inclinación hacia la derecha
            end

        elseif currentTarget == 'gf' then
            local gfAnim = getProperty('gf.animation.curAnim.name')
            targetX = getMidpointX('gf') + getProperty('gf.cameraPosition[0]') + getProperty('girlfriendCameraOffset[0]') + GfOfsX
            targetY = getMidpointY('gf') + getProperty('gf.cameraPosition[1]') + getProperty('girlfriendCameraOffset[1]') + GfOfsY

            if string.find(gfAnim, 'singLEFT', 0, true) then
                targetXMove = -GfOfs
                targetAngle = -angleAmount  -- Inclinación hacia la izquierda
            elseif string.find(gfAnim, 'singDOWN', 0, true) then
                targetYMove = GfOfs * verticalCamIntensity
            elseif string.find(gfAnim, 'singUP', 0, true) then
                targetYMove = -GfOfs * verticalCamIntensity
            elseif string.find(gfAnim, 'singRIGHT', 0, true) then
                targetXMove = GfOfs
                targetAngle = angleAmount  -- Inclinación hacia la derecha
            end
        end

        -- Movimiento de cámara (solo Y para UP/DOWN)
        setProperty('camFollow.x', targetX) -- sin movimiento X
        setProperty('camFollow.y', targetY + targetYMove)

        -- Inclinación suave y más controlada
        local currentAngle = getProperty('camGame.angle')
        setProperty('camGame.angle', lerp(currentAngle, targetAngle, angleLerpSpeed))  -- Interpolación más suave para ambas partes

    end
end

function onMoveCamera(focus)
    if firstSection == false and enableSystem then
        currentTarget = focus
        firstSection = true
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end
