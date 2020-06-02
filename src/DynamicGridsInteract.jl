module DynamicGridsInteract
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsInteract

using Blink,
      DynamicGrids,
      FieldDefaults,
      FieldMetadata,
      Flatten,
      ImageShow,
      Interact,
      InteractBase,
      Mux,
      WebIO,
      WebSockets

const DG = DynamicGrids

# Mixins
using DynamicGrids: AbstractSimData, SimData, rules

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent, show

import InteractBase: WidgetTheme, libraries

import DynamicGrids: storegrid!, frames, init, showgrid, delay,
    fps, frames, fps, delay, starttime, stoptime, tspan, processor,
    isshowable, isasync, isstored, isrunning, 
    grid2image, finalise, storegrid!, aux,
    setstoptime!, setstarttime!, settimestamp!, setrunning!, setfps!

export AbstractWebOutput, InteractOutput, ElectronOutput, ServerOutput

include("interact.jl")
include("electron.jl")
include("server.jl")

end
