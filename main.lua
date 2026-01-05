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
function love.draw()
  if last_champion then neat.draw_node_connections(last_champion) end
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
end
