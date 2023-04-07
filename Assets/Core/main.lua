local console_toggle = require("Scripts/console.console")
local json = require("Scripts/json")
local lovePlus = require("Scripts/love-plus")


function love.load()
    
end

function love.draw()

end

function love.textinput(text)
    console_toggle(text)
end

function graphicTest()
    for _=1,1000000 do
        love.graphics.circle("fill", 100, 100, 50)
    end
    end_time = love.timer.getTime()
    print("circles: "..end_time.. " or "..end_time-start_time)
end