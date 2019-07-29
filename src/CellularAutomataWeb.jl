module CellularAutomataWeb


using AssetRegistry, 
      Blink, 
      CellularAutomataBase, 
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
using CellularAutomataBase: @ImageProc, @Graphic, @Output, AbstractSimData, SimData

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!, parent

import InteractBase: WidgetTheme, libraries

import CellularAutomataBase: deleteframes!, storeframe!, updateframe!,
    frames, showframe, delay, normaliseframe, frametoimage,
    fps, showfps, gettlast, curframe, hasprocessor, 
    settimestamp!, setrunning!, setfps!, isshowable, isasync, isrunning

export AbstractWebOutput, WebOutput, BlinkOutput, MuxOutput

include("web.jl")
include("blink.jl")
include("mux.jl")

end
