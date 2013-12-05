--[[
Reuben Quest: Ev Awakening
Original by DJ Omnimaga
Coded by Juju
Graphics by DJ Omnimaga
Music by DJ Omnimaga
--]]

function love.load()
	scale = 2
	gametime = 0
	creditstime = 0
	gamestate = "introcredits"
	math.randomseed(os.time())
	love.graphics.setDefaultImageFilter("nearest", "linear")
	
	loader = require("AdvTiledLoader.Loader")
	loader.path = "maps/"
	map = loader.load("aurawoods.tmx")
	omnilogo = love.graphics.newImage("imgs/omnimaga_logo.png")
	title = love.graphics.newImage("imgs/title.png")
	characters = love.graphics.newImage("imgs/characters.png")
	pausemenu = love.graphics.newImage("imgs/pausemenu.png")
	dialog = love.graphics.newImage("imgs/dialog.png")
	monsters = love.graphics.newImage("imgs/monsters.png")
	fire = love.graphics.newImage("imgs/fire.png")
	intromusic = love.audio.newSource("sounds/MysteriousIsland.ogg")
	
	deffont = love.graphics.newFont("PressStart2P.ttf", 8)
	gamefont = love.graphics.newFont("PressStart2P.ttf", 8*scale)
	love.graphics.setFont(gamefont)
	love.graphics.setColor(255,255,255,255)
	love.graphics.setBackgroundColor(0,0,0)
	love.graphics.setCaption("Reuben Quest HD Edition")
	love.graphics.setMode(256*scale, 224*scale, false)
	love.graphics.scale(scale, scale)
	
	character = {}
	character.x = 56
	character.y = 88
	character.id = 1
	character.orientation = 2
	character.state = 1
	names = {[0]="Eljin", "Merix", "Zormy", "Guil", "Ji", "Manu", "Kyra", "Miyuki"}
	min_dt = 1/60
	next_time = love.timer.getMicroTime()
	isNight = true
	light = 6

	mapX = 192
	mapY = 1024

	actions = love.filesystem.load("actions.lua")()
	
	monsterstats = {
	--	{name,		lvl, hp, xp, rate, x, y, width, height, boss}
		{"Smallguy",	1, 15, 1, 48, 0, 0, 64, 20, 0},
		{"Someguy",	2, 14, 2, 48, 0, 20, 64, 34, 0},
		{"Lolguy",	3, 20, 2, 48, 0, 54, 64, 36, 0},
		{"Bigguy",	4, 17, 3, 48, 0, 90, 64, 38, 0},
		{"Boss",	5, 150, 20, 0, 0, 128, 64, 36, 1},
	}
	
	moves = {
	--	{name, atk}
		{"Fire", 7},
	}
	
	leveltable = {
	--	{HP, MP, NXT}
		{45, 29, 10}, -- 1
		{60, 34, 15}, -- 2
		{75, 39, 22}, -- 3
		{90, 44, 33}, -- 4
		{105, 49, 49}, -- 5
		{120, 54, 73}, -- 6
		{135, 59, 109}, -- 7
		{150, 64, 163}, -- 8
		{165, 69, 244}, -- 9
		{180, 74, 366}, -- 10
		{195, 79, 549}, -- 11
		{210, 84, 823}, -- 12
		{225, 89, 1234}, -- 13
		{240, 94, 1851}, -- 14
		{255, 99, -1}, -- 15
	}
	
	level = 1
	exp = 0
	hp = leveltable[level][1]
	mp = leveltable[level][2]
	
	items = {}
	
	randomseed = math.random(80, 480)
	
	transition = love.graphics.newPixelEffect [[
		extern number time;
        	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        	{
        		return color*vec4(sin(time),cos(time),sin(time),1.0);
        	}
	]]
	
	introfx = love.graphics.newPixelEffect [[
		extern number time;
        	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        	{
        		return vec4(0, 0, abs(sin(-pixel_coords.x*.001+-pixel_coords.y*.01-(time))/2)+0.5, 1.0);
        	}
	]]
	battlefx = introfx
	--battlefx = love.graphics.newPixelEffect 
	--[[
		extern number time;
		
        	mat2 m = mat2( 0.90,  0.110, -0.70,  1.00 );

float hash( float n )
{
    return fract(sin(n)*758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    //f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + p.z*800.0;
    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
		    mix(mix( hash(n+800.0), hash(n+801.0),f.x), mix( hash(n+857.0), hash(n+858.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f = 0.0;
    f += 0.50000*noise( p ); p = p*2.02;
    f += 0.25000*noise( p ); p = p*2.03;
    f += 0.12500*noise( p ); p = p*2.01;
    f += 0.06250*noise( p ); p = p*2.04;
    f += 0.03125*noise( p );
    return f/0.984375;
}

float cloud(vec3 p)
{
	p+=fbm(vec3(p.x,p.y,0.0)*0.5)*2.25;
	
	float a =0.0;
	a+=fbm(p*3.0)*2.2-1.1;
	if (a<0.0) a=0.0;
	//a=a*a;
	return a;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec2 position = pixel_coords;
	position.y+=0.2;
	vec2 coord= vec2((position.x-0.5)/position.y,1.0/(position.y+0.2));
	coord+=time*0.1;
	float q = cloud(vec3(coord*1.0,time*0.222));
	vec3 col =vec3(0.5,0.5,0.6) + vec3(q*vec3(0.9,0.9,0.9));
	col+=hash(time+pixel_coords.x+pixel_coords.y*9.9)*0.01;
	col*=0.7-length(pixel_coords -0.5)*0.7;
	float w=length(col);
	col=mix(col*vec3(1.0,1.2,1.6),vec3(w,w,w)*vec3(1.4,1.2,1.0),w*1.1-0.2);
	return vec4( col, 1.0 );

}
	]]
	icebeam = love.graphics.newParticleSystem( fire, 800 )
	icebeam:setPosition( 192*scale, 128*scale )
	icebeam:setOffset( 0, 0 )
	icebeam:setBufferSize( 1000 )
	icebeam:setEmissionRate( 100 )
	icebeam:setLifetime( 1 )
	icebeam:setParticleLife( 1 )
	icebeam:setColors( 0, 0, 255, 0, 0, 255, 255, 127 )
	icebeam:setSizes( 1, 1, 1 )
	icebeam:setSpeed( 150, 300  )
	icebeam:setDirection( math.rad(180) )
	icebeam:setSpread( math.rad(15) )
	icebeam:setGravity( 0, 0 )
	icebeam:setRotation( math.rad(0), math.rad(0) )
	icebeam:setSpin( math.rad(0.5), math.rad(1), 1 )
	icebeam:setRadialAcceleration( 0 )
	icebeam:setTangentialAcceleration( 0 )
	
	healbeam = love.graphics.newParticleSystem( fire, 800 )
	healbeam:setPosition( 192*scale, 144*scale )
	healbeam:setOffset( 0, 0 )
	healbeam:setBufferSize( 1000 )
	healbeam:setEmissionRate( 100 )
	healbeam:setLifetime( 1 )
	healbeam:setParticleLife( 0.5 )
	healbeam:setColors( 255, 0, 0, 0, 255, 0, 255, 127 )
	healbeam:setSizes( 1, 1, 1 )
	healbeam:setSpeed( 150, 300  )
	healbeam:setDirection( math.rad(270) )
	healbeam:setSpread( math.rad(90) )
	healbeam:setGravity( 0, 0 )
	healbeam:setRotation( math.rad(0), math.rad(0) )
	healbeam:setSpin( math.rad(0.5), math.rad(1), 1 )
	healbeam:setRadialAcceleration( 0 )
	healbeam:setTangentialAcceleration( 0 )
end

function love.keypressed(key)
	if gamestate == "introcredits" then
		if love.keyboard.isDown("return") then
			gamestate = "menu"
		end
	elseif gamestate == "menu" then
		if key == "return" then
			creditstime = gametime
			intromusic:play()
			gamestate = "intro"
		elseif key == "escape" then
			love.event.push("quit")
		end
	elseif gamestate == "intro" then
		intromusic:stop()
		gamestate = "game"
	elseif gamestate == "game" then
		if key == "escape" then
			gamestate = "pause"
		end
		--[[
		if key == "p" then
			character.id = character.id+1
			if character.id >= 8 then
				character.id = 0
			end
		elseif key == "o" then
			if scale == 1 then scale = 2 else scale = 1 end
			love.graphics.setMode(256*scale, 224*scale, false)
			love.graphics.scale(scale, scale)
		
		elseif key == "l" then
			isNight = not isNight
		end--]]
	elseif gamestate == "pause" then
		if key == "escape" then
			gamestate = "game"
		end
	elseif gamestate == "credits" then
		intromusic:stop()
		gamestate = "game"
	elseif gamestate == "battle" then
		if key == "right" then
			if monster[10] == 0 then
				if math.random(0, 1) == 0 then
					randomseed = math.random(80, 480)
					gamestate = "game"
				else
					hp = hp - monster[2]*2
				end
			end
		end
		if key == "left" then
			icebeam:reset()
			icebeam:start()
			monsterhp = monsterhp - level*5
			hp = hp - monster[2]*2
		end
		if key == "up" then
			if mp > 0 then
				healbeam:reset()
				healbeam:start()
				mp = mp - 1
				hp = hp + 20
				if hp > leveltable[level][1] then hp = leveltable[level][1] end
			end
		end
		if monsterhp <= 0 then
			exp = exp + monster[4]
			while exp >= leveltable[level][3] and leveltable[level][3] ~= -1 do
				exp = exp-leveltable[level][3]
				level = level+1
				hp = leveltable[level][1]
				mp = leveltable[level][2]
			end
			randomseed = math.random(80, 480)
			if thisistheend then
				thisistheend = nil
				intromusic:play()
				hp = leveltable[level][1]
				mp = leveltable[level][2]
				gamestate = "credits"
			else
				gamestate = "game"
			end
		end
		if hp <= 0 then
			thisistheend = nil
			gamestate = "gameover"
		end
	elseif gamestate == "gameover" then
		love.load()
	end
end

function love.keyreleased(key)
	if gamestate == "game" then
		if key == "left" then
			-- Stop the sound
			-- why it's still here
		end
	end
end

function love.update(dt)
	gametime = gametime+dt;
	transition:send("time", gametime)
	introfx:send("time", gametime)
	battlefx:send("time", gametime)
	icebeam:update(dt)
	healbeam:update(dt)
	next_time = next_time + min_dt
	if gamestate == "introcredits" then
		if gametime >= 4 then
			gamestate = "menu"
		end
	elseif gamestate == "menu" then
		-- Nothing happens here.
	elseif gamestate == "game" then
		character.state = 1
		if love.keyboard.isDown("left") then
			if not detectCollision(character.x+mapX-8, character.y+mapY) then
				character.x = character.x-1
				randomseed = randomseed-1
			end
			character.orientation = 3
			character.state = math.floor(gametime*4)%4
		end
		if love.keyboard.isDown("right") then
			if not detectCollision(character.x+mapX+8, character.y+mapY) then
				character.x = character.x+1
				randomseed = randomseed-1
			end
			character.orientation = 1
			character.state = math.floor(gametime*4)%4
		end
		if love.keyboard.isDown("up") then
			if not detectCollision(character.x+mapX, character.y+mapY-4) then
				character.y = character.y-1
				randomseed = randomseed-1
			end
			character.orientation = 0
			character.state = math.floor(gametime*4)%4
		end
		if love.keyboard.isDown("down") then
			if not detectCollision(character.x+mapX, character.y+mapY+1) then
				character.y = character.y+1
				randomseed = randomseed-1
			end
			character.orientation = 2
			character.state = math.floor(gametime*4)%4
		end
		if character.state >= 3 then character.state = 1 end
		if character.x < 48 then
			character.x = 48
			mapX = mapX-1
		end
		if character.x > 256-48 then
			character.x = 256-48
			mapX = mapX+1
		end
		if character.y < 64 then
			character.y = 64
			mapY = mapY-1
		end
		if character.y > 224-48 then
			character.y = 224-48
			mapY = mapY+1
		end
		if randomseed <= 0 then
			monster = monsterstats[math.random(1, 4)]
			monsterhp = monster[3]
			gamestate = "battle"
		end
	elseif gamestate == "pause" then
		character.state = math.floor(gametime*4)%4
		if character.state >= 3 then character.state = 1 end
	end
end

function love.draw()
	if gamestate == "introcredits" then -- Intro
		if gametime < 2 then
			love.graphics.setColor(gametime*127.5, gametime*127.5, gametime*127.5)
		else
			love.graphics.setColor(255-(gametime*127.5), 255-(gametime*127.5), 255-(gametime*127.5))
		end
		love.graphics.draw(omnilogo, 0, 0, 0, scale) -- 320*(83-gametime)
		love.graphics.setFont(gamefont)
		--love.graphics.print("presents", 50*scale, 112*scale) -- 344*(83*gametime)
	elseif gamestate == "menu" then -- Draw the menu
		love.graphics.setColor(255,255,255)
		--[[love.graphics.setFont(gamefont)
		love.graphics.print("Reuben Quest", 65*scale, 50*scale)
		love.graphics.print("Press ENTER", 85*scale, 150*scale)
		love.graphics.print("(C) 2012-2013 Omnimaga", 60*scale, 180*scale)
		love.graphics.setFont(deffont)	
		love.graphics.print("v0.0.1-dev", 0, 215*scale)--]]
		love.graphics.draw(title, 0, 0, 0, scale)
	elseif gamestate == "intro" then
		creditstext = {
		"Once upon a time on a foreign island, "..
		"an evil knight named Ev came in order to disturb "..
		"the peace that citizens established.",
		"Then one day a warrior with legendary power "..
		"came to defeat the knight to save the people. "..
		"Then the hero vanished.",
		"Several years passed and one day, Ev arose "..
		"from darkness once again, and no sign from "..
		"the hero that defeated him a few years ago.",
		"So a young boy called Reuben with magic power "..
		"had to save the island once again...",
		"Omnimaga presents",
		"a game by\nKévin Ouellet",
		"programmed by\nJulien Savard",
		"powered by\nLÖVE",
		"made for\nCemetech Contest #9",
		"special thanks to\nDJ Omnimaga",
		"special thanks to\nSorunome",
		"special thanks to\nArt_of_camelot",
		"special thanks to\nKerm Martian",
		"special thanks to\neveryone else on Omnimaga and Cemetech",
		"Reuben Quest: Ev Awakening",
		}
		thetime = (gametime-creditstime)
		duration = 6
		love.graphics.setFont(gamefont)
		if thetime >= #creditstext*duration-12 and thetime < #creditstext*duration then
			intromusic:setVolume(1-((thetime-(#creditstext*duration-12))/12))
		end
		love.graphics.setColor(math.abs(math.sin(thetime/duration*math.pi))*255, math.abs(math.sin(thetime/duration*math.pi))*255, math.abs(math.sin(thetime/duration*math.pi))*255)
		--love.graphics.setColor(255, 255, 255)
		wrapPrint(creditstext[math.floor(thetime/duration)+1] or "", 40, 40, 27, 16)
		love.graphics.setPixelEffect(introfx)
		love.graphics.setColor(89, 125, 206)
		love.graphics.rectangle('fill', 0, 112*scale, 256*scale, 72*scale)
		love.graphics.setPixelEffect()
		love.graphics.setColor(48, 52, 109)
		love.graphics.rectangle('fill', 0, 184*scale, 256*scale, 40*scale)
		love.graphics.setColor(255, 255, 255)
		drawChar(character.id, 1, 0, 236, 204)
		if thetime >= #creditstext*duration then
			intromusic:stop()
			gamestate = "game"
		end
	elseif gamestate == "game" or gamestate == "pause" then -- We're in the game
		love.graphics.setFont(gamefont)
		--love.graphics.translate(mapX, mapY)
		map:autoDrawRange(-mapX, -mapY, scale, 50)
		love.graphics.push()
		love.graphics.scale(scale)
		love.graphics.translate(-mapX, -mapY)
		--love.graphics.setPixelEffect(transition)
		map:draw()
		love.graphics.pop()
		love.graphics.setColor(255, 255, 255)
		-- Draw the player
		drawChar(character.id, character.state, character.orientation, character.x, character.y)
		--charquad = love.graphics.newQuad((character.id%4)*72+character.state*24, math.floor(character.id/4)*128+character.orientation*32, 24, 32, 288, 256)
		--love.graphics.drawq(characters, charquad, (character.x-12)*scale, (character.y-32)*scale, 0, scale)
		-- Draw the NPCs
		for i=1,#map.ol["objects"].objects do
			object = map.ol["objects"].objects[i]
			if object.type == "npc" and object.properties.char then
				drawChar(object.properties.char, 1, 2, (object.x+object.width/2)-mapX, (object.y+object.height/2)-mapY)
				if ((object.y+object.height/2)-mapY) >= 0 and ((object.y+object.height/2)-mapY) <= character.y then drawChar(character.id, character.state, character.orientation, character.x, character.y) end
				--npcquad = love.graphics.newQuad((object.properties.char%4)*72+1*24, math.floor(object.properties.char/4)*128+2*32, 24, 32, 288, 256)
				--love.graphics.drawq(characters, npcquad, ((object.x+object.width/2)-12)*scale, ((object.y+object.height/2)-32)*scale, 0, scale)
			end
		end
		doAction(mapX+character.x, mapY+character.y) -- Player steps in a NPC
		love.graphics.setFont(deffont)
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.rectangle("fill", 0, 0, 96, 16)
		love.graphics.setColor(255, 255, 255, 255)
		--love.graphics.print(names[character.id], 0, -3)
		love.graphics.print("("..(mapX+character.x)..","..(mapY+character.y)..")", 0, 0)
		if gamestate == "pause" then
			love.graphics.setFont(gamefont)
			--[[love.graphics.setColor(0, 0, 127, 191)
			love.graphics.rectangle("fill", 32, 32, 448, 384)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setLine(4, "smooth")
			love.graphics.rectangle("line", 32, 32, 448, 384)--]]
			love.graphics.draw(pausemenu, 0, 0, 0, scale)
			love.graphics.print("STATUS", 40, 40)
			love.graphics.print("Area: "..map.properties.name, 40, 56)
			love.graphics.print("Lv: "..level, 40, 72)
			love.graphics.print("Exp: "..exp, 40, 88)
			love.graphics.print("NXT: "..(leveltable[level][3] == -1 and "---" or leveltable[level][3]), 40, 104)
			love.graphics.print("HP: "..hp.."/"..leveltable[level][1], 216, 72)
			love.graphics.print("MP: "..mp.."/"..leveltable[level][2], 216, 88)
			--love.graphics.print("Next: "..randomseed, 216, 104) -- people shouldn't be able to know that
			drawChar(character.id, character.state, 2, 208+12, 24+32)
		end
	elseif gamestate == "credits" then
		thetime = (gametime-creditstime)*16
		love.graphics.setFont(gamefont)
		love.graphics.print("Reuben Quest: Ev Awakening", 40, (232-thetime)*scale)
		love.graphics.print("ORIGINAL IDEA", 40, (248-thetime)*scale)
		love.graphics.print("Kévin Ouellet", 40, (256-thetime)*scale)
		love.graphics.print("PROGRAMMING", 40, (272-thetime)*scale)
		love.graphics.print("Julien Savard", 40, (280-thetime)*scale)
		love.graphics.print("GRAPHICS", 40, (296-thetime)*scale)
		love.graphics.print("Kévin Ouellet", 40, (304-thetime)*scale)
		love.graphics.print("Sorunome", 40, (312-thetime)*scale)
		love.graphics.print("MUSIC", 40, (328-thetime)*scale)
		love.graphics.print("Kévin Ouellet", 40, (336-thetime)*scale)
		love.graphics.print("Thanks for playing!", 40, (352-thetime)*scale)
		love.graphics.print("Made for Cemetech Contest #9", 40, (360-thetime)*scale)
		if thetime >= 376 then creditstime = gametime end
	elseif gamestate == "battle" then
		love.graphics.setPixelEffect(battlefx)
		love.graphics.rectangle('fill', 0, 0, 256*scale, 224*scale)
		love.graphics.setPixelEffect()
		love.graphics.setFont(gamefont)
		--love.graphics.print("HP: "..monsterhp, 40, 40) -- they shouldn't know that either
		love.graphics.print("HP: "..hp, 288, 40)
		love.graphics.print("MP: "..mp, 288, 56)
		quad = love.graphics.newQuad(monster[6], monster[7], monster[8], monster[9], 64, 537)
		love.graphics.drawq(monsters, quad, 20*scale, 128*scale, 0, scale)
		drawChar(character.id, 1, 3, 192, 144)
		love.graphics.draw(icebeam, 0, 0)
		love.graphics.draw(healbeam, 0, 0)
	elseif gamestate == "gameover" then
		love.graphics.print("GAME OVER", 88*scale, 108*scale)
	end
	love.graphics.setCaption("Reuben Quest HD Edition ("..love.timer.getFPS().." FPS)")
	--love.graphics.setFont(deffont)
	--love.graphics.print("FPS "..love.timer.getFPS(), 0, -11) -- .."  GT "..gametime
	local cur_time = love.timer.getMicroTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function getDistance(x1, y1, x2, y2)
	return (math.abs(x1-x2)^2+math.abs(y1-y2)^2)^0.5
end

function detectCollision(x, y)
	local tile = map.tl["ground"].tileData(math.floor(x/16), math.floor(y/16))
	if tile == nil then return true end
	if tile.properties.obstacle == 1 then return true end
	return false
end

function doAction(x, y)
	objlayer = map.ol["objects"]
	for i=1,#objlayer.objects do
		object = objlayer.objects[i]
		if x >= object.x and x < object.x+object.width and y >= object.y and y < object.y+object.height then
			if object.type == "action" then
				actions[object.properties.action]()
			elseif object.type == "teleport" then
				map = loader.load(object.properties.map..".tmx")
				mapX = object.properties.x-character.x
				mapY = object.properties.y-character.y
			elseif object.type == "npc" then
				showDialog(object.properties.msg)
			elseif object.type == "battle" then
				map = loader.load(object.properties.map..".tmx")
				mapX = object.properties.x-character.x
				mapY = object.properties.y-character.y
				thisistheend = object.properties.ending
				monster = monsterstats[object.properties.monster]
				monsterhp = monster[3]
				gamestate = "battle"
			end
		end
	end
end

function drawChar(cid, state, orientation, x, y)
	quad = love.graphics.newQuad((cid%4)*72+state*24, math.floor(cid/4)*128+orientation*32, 24, 32, 288, 256)
	love.graphics.drawq(characters, quad, (x-12)*scale, (y-32)*scale, 0, scale)
end

function wrapPrint(message, x, y, limit, jump)
	limit = limit or 27
	jump = jump or 8
	str = wrap(message, limit)
	offset = y
	for line in str:gmatch("[^\r\n]+") do
		love.graphics.print(line, x, offset)
		offset = offset + jump
	end
end

function showDialog(message)
	love.graphics.draw(dialog, 0, 0, 0, scale)
	str = wrap(message, 27)
	offset = 148
	for line in str:gmatch("[^\r\n]+") do
		love.graphics.print(line, 20*scale, offset*scale)
		offset = offset + 8
	end
end

function wrap(str, limit, indent, indent1)
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local finalstr = ""
  for line in str:gmatch("[^\r\n]+") do
  	local here = 1-#indent1
  	finalstr = finalstr..indent1..line:gsub("(%s+)()(%S+)()",
  		                        function(sp, st, word, fi)
  		                          if fi-here > limit then
  		                            here = st - #indent
  		                            return "\n"..indent..word
  		                          end
  		                        end).."\n"
  end
  return finalstr
end
