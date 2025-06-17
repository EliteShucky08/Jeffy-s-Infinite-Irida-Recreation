-- The first event mabe by me(Scarlet Eye) --
function onEvent(name, value1, value2)
	if name == 'RedVG' then
		if value1 then -- begining
		makeLuaSprite('Red', 'Blood', 0, 0)
	    setObjectCamera('Red', 'other')
	    addLuaSprite('Red', true)
		screenCenter('Red', 'xy');
		setProperty('Red.visible', true);
		end
		if value2 then
			setProperty('Red.visible', false);
		end
	end
end