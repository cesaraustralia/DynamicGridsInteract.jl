module DynamicGridsInteract
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsInteract

using Blink,
      DynamicGrids,
      ImageShow,
      Interact,
      InteractBase,
      InteractModels,
      Mux,
      WebIO,
      WebSockets

const DG = DynamicGrids

using DynamicGrids: AbstractSimData, SimData, rules, fps, init, tspan, isrunning, setrunning!

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent, show

export AbstractInteractOutput, InteractOutput, ElectronOutput, ServerOutput

include("interact.jl")
include("electron.jl")
include("server.jl")

end
