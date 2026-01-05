local thread = love.thread.newThread("thread.lua")
local neat = require("neat/neat")
local hyperneat = require("hyperneat")

local status_channel = love.thread.getChannel("status")
local champion_neat_channel = love.thread.getChannel("champion")

function love.load()
  thread:start()
end


local last_status = nil
local last_champion = nil
local last_viz = nil
function love.draw()
  if last_champion then neat.draw_node_connections(last_champion) end
  if last_viz then love.graphics.draw(last_viz) end
  if last_status then love.graphics.print(last_status) end
end

function love.keypressed(key, scancode)
  if scancode == "e" then
  end
end

function love.update(dt)
  local new_status = status_channel:pop()
  if new_status then last_status = new_status end

  local new_champion = champion_neat_channel:pop()
  if new_champion then last_champion = new_champion end
  if new_champion then
    local substrate = hyperneat.create_2dsubstrate({
      input_res = 64,
      output_count = 10,
      genome = new_champion
    })

    -- Create pixel buffer
    local imageData = love.image.newImageData(substrate.settings.input_res * substrate.settings.output_count, substrate.settings.input_res)

    for j, o in ipairs(substrate.outputs) do
      for i, input in ipairs(substrate.inputs) do
        local w = (substrate.weights[i][j] + 1) * 0.5
        imageData:setPixel(
          (input.x + 1) / 2 * (substrate.settings.input_res - 1 ) + (j - 1) * substrate.settings.input_res,
          (input.y + 1) / 2 * (substrate.settings.input_res - 1 ),
          w, w, w, 1.0
        )
      end
    end

    -- Upload to GPU
    last_viz = love.graphics.newImage(imageData)
  end
end
