function onEvent(n,v1,v2)


	if n == 'Black Flash' then

	   makeLuaSprite('black', '', 0, 0);
        makeGraphic('black',1920,1080,'000000 ')
	      addLuaSprite('black', true);
	      setLuaSpriteScrollFactor('black',0,0)
	      setProperty('black.scale.x',2)
	      setProperty('black.scale.y',2)
	      setProperty('black.alpha',0)
              setObjectCamera('black', 'camGame')
              setObjectOrder('black', 10)
              setObjectOrder('bf', 9)

		setProperty('black.alpha',0.9)
		doTweenAlpha('flTw','black',0,v1,'linear')
	end



end