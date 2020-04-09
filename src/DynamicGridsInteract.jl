module DynamicGridsInteract
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsInteract

using Blink,
      DynamicGrids,
      FieldDefaults,
      FieldMetadata,
      Flatten,
      Interact,
      InteractBase,
      Mux,
      WebIO,
      WebSockets

const DG = DynamicGrids

# Mixins
using DynamicGrids: @Image, @Graphic, @Output, AbstractSimData, SimData, rules

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent, show

import InteractBase: WidgetTheme, libraries

import DynamicGrids: storegrid!, frames, showgrid, delay,
    fps, showfps, frames, fps, delay,
    isshowable, isasync, isstored, isrunning, starttime, stoptime, tspan, processor,
    grid2image, finalise, storegrid!,
    setstoptime!, setstarttime!, settimestamp!, setrunning!, setfps!

export AbstractWebOutput, InteractOutput, ElectronOutput, ServerOutput

include("interact.jl")
include("electron.jl")
include("server.jl")

end
