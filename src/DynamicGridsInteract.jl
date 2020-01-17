module DynamicGridsInteract
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsInteract

using Blink,
      DynamicGrids,
      FieldDefaults,
      FieldMetadata,
      Flatten,
      Images,
      Interact,
      InteractBase,
      Lazy,
      Mux,
      WebIO,
      WebSockets

# Mixins
using DynamicGrids: @Image, @Graphic, @Output, AbstractSimData, SimData, rules

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent, show

import InteractBase: WidgetTheme, libraries

import DynamicGrids: storeframe!, frames, showframe, delay, normaliseframe, frametoimage,
    fps, showfps, currentframe, frames, fps, delay,
    isshowable, isasync, isstored, isrunning, starttime, stoptime, tspan, 
    normaliseframe, frametoimage, finalize!, storeframe!, 
    setstoptime!, setstarttime!, settimestamp!, setrunning!, setfps!

export AbstractWebOutput, InteractOutput, ElectronOutput, ServerOutput

include("interact.jl")
include("electron.jl")
include("server.jl")

end
