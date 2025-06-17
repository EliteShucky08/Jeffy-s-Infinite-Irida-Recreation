-- in your per‐song script (e.g. mods/songs/shucks/script.lua)

function onEvent(name, value1, value2)
    if name == 'playVideoyeyey' then  -- your custom event name
        local tag   = 'videoStart'
        local file  = value1           -- the MP4 filename (no “.mp4”) in mods/videos/
        local cam   = string.lower(value2)  -- must be "game", "hud", or "other"
        local loop  = true             -- true or false

        -- create & queue up the video sprite
        makeVideoSprite(tag, file, 0, 0, cam, loop)

        -- force it to the very back/front of that camera’s draw order
        setObjectOrder(tag .. '_video', 0)

        -- make sure it’s visible
        setProperty(tag .. '_video.alpha', 1)
    end
end
