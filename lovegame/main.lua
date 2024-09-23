# Sending data through socket!
if false then love = love end

-- local utf8 = require("utf8")

local socket = require("socket")
local json = require("rxijson.json")

local data = {x = 123, y = 456}
local serializedData = json.encode(data)

local udp = socket.udp()
local touches
local connected = false

local buttonH = 128

local x, y, dx, dy = 0, 0, 0, 0
local s, sx, st = 0, 0, 0
local text = ""

love.keyboard.setTextInput( true )

local valid = false

local function validate()
	valid = ( string.find(text, "^%d+%.%d+$") and true or false )
	if valid then
		love.filesystem.write( 'destination ip address', text )
	end
end

function love.textinput(t)
	text = text .. t
	validate()
end

function love.load()
	local read = love.filesystem.read( 'destination ip address' )
	if read then
		text = read
		valid = true
		love.keyboard.setTextInput( false )
	end
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            text = string.sub(text, 1, byteoffset - 1)
			validate()
        end
    end
end

function love.keyreleased(key)
	if key == "escape" then
		love.keyboard.setTextInput( not love.keyboard.hasTextInput() )
	end
end

function love.update(dt)
	WinW, WinH = love.graphics.getDimensions()
	WinH = WinH - buttonH
	touches = love.touch.getTouches( )
	local xp, yp = x, y
	x, y = 0, 0
	local tn = 0
	st = st - 1
	if st <= 0 then s = 0 end
	for i,v in pairs(touches) do
		local tx, ty = love.touch.getPosition(v)
		if ty < WinH then
			x = x + tx
			y = y + ty
			tn = tn + 1
		else
			-- if st <= 0 then sx = tx - 1 end
			-- s = (tx - sx) / WinW * 2
			s = 1
			st = 2
		end
	end
	if tn == 0 then
		x = xp y = yp
	else
		x = x / tn
		y = y / tn
		x = x / WinW
		y = y / WinH
	end
	if tn > 1 then s = -1 end
	dx = x - xp
	dy = y - yp
	if math.abs( dx + dy + s ) > 10 ^-9 and valid then
		data = { x=x, y=y }
		if connected == "Cool!" then
			if s ~= 0 then data.s = s end
			serializedData = json.encode(data)
			udp:setpeername('192.168.' .. text, 5329)
			udp:send(serializedData)
			udp:close()
		else
			udp:setpeername('192.168.' .. text, 5329)
			udp:send( json.encode({["hello!"] = WinW/WinH}) )
			udp:settimeout(1)
			connected = udp:receive(32)
			udp:close()
		end
	end
end

function love.draw()
	love.graphics.circle( "line", data.x, data.y, 16 )
	love.graphics.setColor(0.25, 0.25, 0.25)
	love.graphics.print( 'Android to Mouse', WinW / 3, WinH / 3 + 32)
	love.graphics.setColor(1, 1, 1)
	if not valid then
		love.graphics.setColor(1, 0.5, 0.5)
		love.graphics.print( 'NOT VALID IP DIRECTION' , WinW / 3, WinH / 3 - 64 )
		love.graphics.setColor(1, 1, 1)
		love.graphics.print( 'Check it in the PC program' , WinW / 3, WinH / 3 - 48 )
		love.graphics.print( '192.168.' .. text, WinW / 3, WinH / 3 )
	end
	love.graphics.line(0, WinH, WinW, WinH)
	love.graphics.print( connected and connected or 'false', WinW / 3, WinH + buttonH / 2 )
end
