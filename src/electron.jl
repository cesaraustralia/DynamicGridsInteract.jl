
"""
    ElectronOutput(init, ruleset::Ruleset; kwargs...)

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
- `init`: initialisation array, or `NamedTuple` of arrays
- `ruleset::Ruleset`: A DynamicGrids `Ruleset` 

Keyword arguments are passed to [`InteractOutput`](@ref).
"""
mutable struct ElectronOutput{T, I<:InteractOutput{T}} <: AbstractInteractOutput{T}
    interface::I
    window::Blink.AtomShell.Window
end

ElectronOutput(init, ruleset::Ruleset; kwargs...) = begin
    interface = InteractOutput(init, ruleset; kwargs...)
    window = newelectronwindow(interface)
    ElectronOutput(interface, window)
end

interface(o::ElectronOutput) = o.interface

# Forward output methods to InteractOutput: ElectronOutput is just a wrapper.
Base.length(o::ElectronOutput) = length(interface(o))
Base.size(o::ElectronOutput) = size(interface(o))
Base.firstindex(o::ElectronOutput) = firstindex(interface(o))
Base.lastindex(o::ElectronOutput) = lastindex(interface(o))
Base.getindex(o::ElectronOutput, I...) = getindex(interface(o), I...)
Base.setindex!(o::ElectronOutput, x, I...) = setindex!(interface(o), x, I...)
Base.push!(o::ElectronOutput, x) = push!(interface(o), x)
Base.append!(o::ElectronOutput, x) = append!(interface(o), x)

DG.processor(o::ElectronOutput) = processor(interface(o))
DG.frames(o::ElectronOutput) = frames(interface(o))
DG.starttime(o::ElectronOutput) = starttime(interface(o))
DG.stoptime(o::ElectronOutput) = stoptime(interface(o))
DG.tspan(o::ElectronOutput) = tspan(interface(o))
DG.fps(o::ElectronOutput) = fps(interface(o))
DG.showfps(o::ElectronOutput) = showfps(interface(o))
DG.isasync(o::ElectronOutput) = isasync(interface(o))
DG.isstored(o::ElectronOutput) = isstored(interface(o))
DG.isshowable(o::ElectronOutput) = isshowable(interface(o))

DG.setfps!(o::ElectronOutput, x) = setfps!(interface(o), x)
DG.setrunning!(o::ElectronOutput, x) = setrunning!(interface(o), x)
DG.setstarttime!(o::ElectronOutput, x) = setstarttime!(interface(o), x)
DG.setstoptime!(o::ElectronOutput, x) = setstoptime!(interface(o), x)
DG.settimestamp!(o::ElectronOutput, x) = settimestamp!(interface(o), x)
DG.initialise(o::ElectronOutput, args...) = initialise(interface(o), args...)
DG.finalise(o::ElectronOutput, args...) = finalise(interface(o), args...)
DG.delay(o::ElectronOutput, x) = delay(interface(o), x)

isalive(o::ElectronOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

# Running checks depend on the blink window still being open
DG.isrunning(o::ElectronOutput) = isalive(o) && isrunning(interface(o))

DG.storegrid!(o::ElectronOutput, data::DynamicGrids.AbstractSimData) = 
    storegrid!(interface(o), data)

DG.showgrid(o::ElectronOutput, args...) = 
    showgrid(interface(o), args...)

newelectronwindow(interface) = begin
    window = Blink.AtomShell.Window()
    body!(window, interface.page)
    window
end

Base.display(o::ElectronOutput) =
    if !isalive(o)
        o.window = newelectronwindow(interface(o))
    end
