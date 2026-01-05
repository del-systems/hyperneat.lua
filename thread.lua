require "love.image"
require "love.math"

local hyperneat = require "hyperneat"
local neat = require "neat/neat"

local status_channel = love.thread.getChannel("status")
local champion_neat_channel = love.thread.getChannel("champion")

status_channel:push('initializing...')

local population = {}
for i = 1, 100 do
  local hyperneat_settings = {
    input_res = 28,
    output_count = 10
  }

  if true then
    hyperneat_settings.genome = {
      fitness = 0,
      settings = { innovation_counter = 841 },
      nodes = {
        { id = 1, type = "input", activation = neat.get_default_activation_by_name("identity") },
        { id = 2, type = "input", activation = neat.get_default_activation_by_name("identity") },
        { id = 3, type = "input", activation = neat.get_default_activation_by_name("identity") },
        { id = 4, type = "input", activation = neat.get_default_activation_by_name("identity") },
        { id = 5, type = "input", activation = neat.get_default_activation_by_name("identity") },
        { id = 6, type = "output", activation = neat.get_default_activation_by_name("tanh") },
        { id = 7, type = "hidden", activation = neat.get_default_activation_by_name("tanh") },
        { id = 8, type = "hidden", activation = neat.get_default_activation_by_name("cos") },
        { id = 9, type = "hidden", activation = neat.get_default_activation_by_name("sigmoid") },
      },
      connections = {
        { in_node = 1, out_node = 6, weight = 0.6012, innovation = 341, enabled = false },
        { in_node = 2, out_node = 6, weight = 0.1527, innovation = 342, enabled = false },
        { in_node = 3, out_node = 6, weight = 0.6256, innovation = 343, enabled = true },
        { in_node = 4, out_node = 6, weight = -1.7850, innovation = 344, enabled = false },
        { in_node = 5, out_node = 6, weight = -0.8807, innovation = 345, enabled = false },
        { in_node = 5, out_node = 7, weight = -0.3454, innovation = 672, enabled = false },
        { in_node = 7, out_node = 6, weight = -0.1346, innovation = 673, enabled = true },
        { in_node = 5, out_node = 8, weight = -0.4274, innovation = 699, enabled = true },
        { in_node = 8, out_node = 7, weight = -0.5572, innovation = 700, enabled = true },
        { in_node = 7, out_node = 8, weight = 0.1041, innovation = 839, enabled = true },
        { in_node = 1, out_node = 9, weight = -0.5523, innovation = 840, enabled = true },
        { in_node = 9, out_node = 6, weight = -1.0307, innovation = 841, enabled = true },
      }
    }
  end

  table.insert(population, hyperneat.create_2dsubstrate(hyperneat_settings))
end

local function gather_png_files(path, file_list)
  local items = love.filesystem.getDirectoryItems(path)
  local current_dir = path:match("([^/]+)$") or path

  for _, item in ipairs(items) do
    local full_path = path .. "/" .. item
    local info = love.filesystem.getInfo(full_path)

    if info.type == "directory" then
      gather_png_files(full_path, file_list)
    elseif info.type == "file" and item:match("%.png$") then
      table.insert(file_list, {
        path = full_path,
        directory = current_dir
      })
    end
  end
end

local all_files = {}
gather_png_files("dataset", all_files)
status_channel:push('dataset has been read')

--math.randomseed(os.time())
--for i = #all_files, 2, -1 do
--  local j = math.random(i)
--  all_files[i], all_files[j] = all_files[j], all_files[i]
--end

local function process_datasets(path)
  local items = love.filesystem.getDirectoryItems(path)
  local current_dir = path:match("([^/]+)$")
  print(current_dir)

  for _, item in ipairs(items) do
    local full_path = path .. "/" .. item
    local info = love.filesystem.getInfo(full_path)

    if info.type == "directory" then
      process_datasets(full_path)
    elseif info.type == "file" and item:match("%.png$") then
      -- current_dir holds the immediate parent directory name
      local full_data = love.filesystem.newFileData(full_path)
      local image_data = love.image.newImageData(full_data)

      local w, h = image_data:getDimensions()
      local inputs = {}
      for y = 0, h - 1 do
        for x = 0, w - 1 do
          local r, g, b, a = image_data:getPixel(x, y)
          table.insert(inputs, r * 2 - 1)
        end
      end

      for _, substrate in ipairs(population) do
        local results = hyperneat.evaluate(substrate, inputs)
        local max = math.max(results[1], results[2], results[3], results[4], results[5], results[6], results[7], results[8], results[9], results[10])

        if max > 0.70 then
          if current_dir == "0" and results[1] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "1" and results[2] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "2" and results[3] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "3" and results[4] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "4" and results[5] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "5" and results[6] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "6" and results[7] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "7" and results[8] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "8" and results[9] == max then
            substrate.fitness = substrate.fitness + 1
          elseif current_dir == "9" and results[10] == max then
            substrate.fitness = substrate.fitness + 1
          end
        end
      end

      -- image_data now contains the pixel data
      -- Access pixels via image_data:getPixel(x, y)

      image_data = nil
      full_data = nil
    end
  end
end

local function train(i)
  print(all_files[i].directory)
  local full_data = love.filesystem.newFileData(all_files[i].path)
  local image_data = love.image.newImageData(full_data)

  local w, h = image_data:getDimensions()
  local inputs = {}
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local r, g, b, a = image_data:getPixel(x, y)
      table.insert(inputs, r * 2 - 1)
    end
  end

  for _, substrate in ipairs(population) do
    local results = hyperneat.evaluate(substrate, inputs)
    local max = math.max(results[1], results[2], results[3], results[4], results[5], results[6], results[7], results[8], results[9], results[10])
    local min = math.min(results[1], results[2], results[3], results[4], results[5], results[6], results[7], results[8], results[9], results[10])

    local dir_number = tonumber(all_files[i].directory)
    if min < 0.4 and max > 0.5 and max == results[dir_number + 1] then
      substrate.fitness = substrate.fitness + 1
    else
      substrate.fitness = substrate.fitness - 1
    end
    substrate.genome.fitness = substrate.fitness
  end


  image_data = nil
  full_data = nil
end


local max_files = 3
while true do
  for i = 1, math.min(max_files, #all_files) do
    if max_files >= #all_files then
      train(i)
    else
      train(math.random(1, #all_files))
    end
  end
  neat.print_genome(population[1].genome)
  champion_neat_channel:push(neat.purify_genome(population[1].genome))
  population = hyperneat.evolve_population(population)
  max_files = max_files + 1
end
