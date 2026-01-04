local neat = require 'neat.lua/neat'
local neat_settings = {}

local HYPERNEAT = {}

function HYPERNEAT.create_2dsubstrate(settings)
  local genome = settings.genome or neat.create_genome({
    input_count = 5,
    output_count = 1
  })

  settings.genome = genome

  local substrate = {
    settings = settings,
    inputs = {},
    outputs = {},
    weights = {},
  }

  for y = 0, settings.input_res - 1 do
    for x = 0, settings.input_res - 1 do
      table.insert(substrate.inputs, {
        x = (x / (settings.input_res - 1)) * 2 - 1,
        y = (y / (settings.input_res - 1)) * 2 - 1
      })
    end
  end

  for i = 0, settings.output_count - 1 do
    table.insert(substrate.outputs, {
      x = (i / (settings.output_count - 1)) * 2 - 1,
      y = 1.0
    })
  end

  for i, n in ipairs(substrate.inputs) do
    substrate.weights[i] = {}
    for j, o in ipairs(substrate.outputs) do
      -- input x, input y, output x, output y, bias
      substrate.weights[i][j] = neat.evaluate(genome, { n.x, n.y, o.x, o.y, 1.0 })[1]
    end
  end

  return substrate
end

return HYPERNEAT
