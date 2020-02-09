
"""
A html output using Interact.jl and an Electron window through Blink.jl
ElectronOutput automatically generates sliders to control simulations
in realtime. args and kwargs are passed to [`InteractOutput`]

## Example
```julia
using Blink
ElectronOutput(init, ruleset)
```

### Arguments
#
- `init`: initialisation array, or NamedTuple of arrays
- `ruleset::Models`: DynamicGrids `Ruleset` 

### Optional keyword arguments
- `fps = 25`: frames per second.
- `showfps = fps`: maximum displayed frames per second
- `store::Bool = false`: save frames or not.
- `processor = Greyscale()`
- `theme` A css theme.
"""
mutable struct ElectronOutput{T, I<:InteractOutput{T}} <: AbstractInteractOutput{T}
    interface::I
    window::Blink.AtomShell.Window
end

ElectronOutput(init, ruleset; kwargs...) = begin
    interface = InteractOutput(init, ruleset; kwargs...)
    window = newelectronwindow(interface)
    ElectronOutput{typeof(frames(interface)),typeof(interface)}(interface, window)
end

interface(o::ElectronOutput) = o.interface

# Forward output methods to InteractOutput: ElectronOutput is just a wrapper.
@forward ElectronOutput.interface length, size, endof, firstindex, lastindex,
    getindex, setindex!, push!, append!, storegrid!,
    frames, starttime, stoptime, tspan, setrunning!, setstarttime!, setstoptime!,
    settimestamp!, fps, setfps!, showfps, isasync, isstored,
    isshowable, finalize!, delay

isalive(o::ElectronOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

# Running checks depend on the blink window still being open
DynamicGrids.isrunning(o::ElectronOutput) = isalive(o) && isrunning(o.interface)

DynamicGrids.showgrid(o::ElectronOutput, args...) = 
    showgrid(interface(o), args...)
DynamicGrids.showgrid(o::ElectronOutput, data::AbstractSimData, args...) = 
    showgrid(interface(o), data, args...)

newelectronwindow(interface) = begin
    window = Blink.AtomShell.Window()
    body!(window, interface.page)
    window
end

Base.display(o::ElectronOutput) =
    if !isalive(o)
        o.window = newelectronwindow(o.interface)
    end
