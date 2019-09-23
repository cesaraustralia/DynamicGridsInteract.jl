module DynamicGridsInteract
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) DynamicGridsInteract

using AssetRegistry,
      Blink,
      DynamicGrids,
      FieldMetadata,
      Flatten,
      Images,
      Interact,
      InteractBase,
      InteractBulma,
      Lazy,
      Mux,
      WebSockets

# Mixins
using DynamicGrids: @Image, @Graphic, @Output, AbstractSimData, SimData

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent

import InteractBase: WidgetTheme, libraries

import DynamicGrids: storeframe!, updateframe!,
    frames, showframe, delay, normaliseframe, frametoimage,
    fps, showfps, gettlast, curframe, 
    settimestamp!, setrunning!, setfps!, isshowable, isasync, isrunning

export AbstractWebOutput, InteractOutput, ElectronOutput, ServerOutput

include("interact.jl")
include("electron.jl")
include("server.jl")

end
