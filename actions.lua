return {
	sayhello = function()
		--[[love.graphics.setColor(0,0,255,255)
		love.graphics.rectangle("line", 16*scale, 144*scale, 224*scale, 64*scale)
		love.graphics.setColor(0,0,255,127)
		love.graphics.rectangle("fill", 16*scale, 144*scale, 224*scale, 64*scale)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(names[character.id].."! Welcome to the Test Map.", 20*scale, 136*scale)
		love.graphics.print("There's a test teleporter inside.", 20*scale, 144*scale)--]]
		showDialog("Reuben! Welcome to the Test Map. There's a test teleporter inside.")
	end,
	goodnight = function()
		showDialog("Good night!")
		--[[love.graphics.setColor(0,0,255,255)
		love.graphics.rectangle("line", 16*scale, 144*scale, 224*scale, 64*scale)
		love.graphics.setColor(0,0,255,127)
		love.graphics.rectangle("fill", 16*scale, 144*scale, 224*scale, 64*scale)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Good night!", 20*scale, 136*scale)--]]
		--[[for start in 0, 400 do
			if start > 200 then
				love.graphics.setColor(start*127.5, start*127.5, start*127.5)
			else
				love.graphics.setColor(255-(start*127.5), 255-(start*127.5), 255-(start*127.5))
			end
		end --]]
	end,
	needfire = function()
		--if items contains fire then
		--change that block of ice to nothing
		--else
		showDialog("You need fire to melt ice.")
		--end
	end,
	credits = function()
		creditstime = gametime
		--gamestate = "credits"
		showDialog("You reached the end of the playable demo of Reuben Quest. Thanks for playing!")
	end,
}
