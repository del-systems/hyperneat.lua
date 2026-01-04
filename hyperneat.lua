local neat = require 'neat/neat'
local neat_settings = {}

local HYPERNEAT = {}

function HYPERNEAT.refill_weights(substrate, settings)
  for i, n in ipairs(substrate.inputs) do
    substrate.weights[i] = {}
    for j, o in ipairs(substrate.outputs) do
      -- input x, input y, output x, output y, bias
      substrate.weights[i][j] = neat.evaluate(substrate.genome, { n.x, n.y, o.x, o.y, 1.0 })[1]
    end
  end
end

function HYPERNEAT.create_2dsubstrate(settings)
  local genome = settings.genome or neat.create_genome({
    input_count = 5,
    output_count = 1
  })

  local substrate = {
    genome = genome,
    settings = settings,
    fitness = 0,
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

  HYPERNEAT.refill_weights(substrate, settings)

  return substrate
end


function HYPERNEAT.evaluate(substrate, inputs, settings)
  local sigmoid = neat.get_default_activation_by_name("sigmoid")
  local results = {}

  for j, output in ipairs(substrate.outputs) do
    local sum = 0

    for i, input in ipairs(substrate.inputs) do
      sum = sum + (input * substrate.weights[i][j])
    end

    table.insert(results, sigmoid.fn(sum))
  end

  return results
end

function HYPERNEAT.evolve_population(population)
  local genomes = {}
  local next_gen = {}

  for _, substrate in ipairs(population) do
    table.insert(genomes, substrate.genome)
    table.insert(next_gen, {
      settings = substrate.settings,
      inputs = substrate.inputs,
      outputs = substrate.outputs,
      weights = {}
    })
    substrate.genome.fitness = substrate.fitness
  end

  genomes = neat.evolve_population(genomes)
  for i, substrate in ipairs(next_gen) do
    substrate.fitness = 0
    substrate.genome = genomes[i]
    HYPERNEAT.refill_weights(substrate)
  end

  return next_gen
end

return HYPERNEAT
