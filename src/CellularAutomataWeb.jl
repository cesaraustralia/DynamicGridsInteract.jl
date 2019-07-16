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
using CellularAutomataBase: @ImageProc, @Graphic, @Output, frametoimage

import CellularAutomataBase: deleteframes!, storeframe!, updateframe!,
    showframe, delay, normaliseframe, 
    getfps, gettlast, curframe, hasfps, hasminmax, hasprocessor, 
    settimestamp!, setrunning!, setfps!,
    isshowable, isasync, isrunning

import Base: length, size, firstindex, lastindex, getindex, setindex!, push!, append!

import InteractBase: WidgetTheme, libraries

export BlinkOutput, MuxOutput

include("web.jl")
include("blink.jl")
include("mux.jl")

end
