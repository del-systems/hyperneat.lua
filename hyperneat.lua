local neat = require 'neat.lua/neat'
local neat_settings = {}

local HYPERNEAT = {}

function HYPERNEAT.create_substrate(settings)
  settings.input_count
  settings.output_count

  local substrate = { settings = settings }
  return substrate
end

return HYPERNEAT
