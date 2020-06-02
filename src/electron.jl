
"""
    ElectronOutput(init, ruleset::Ruleset; kwargs...)

A html output using Interact.jl and an Electron window through Blink.jl
ElectronOutput automatically generates sliders to control simulations
in realtime. args and kwargs are passed to [`InteractOutput`](@ref).

## Example
```julia
using Blink
ElectronOutput(init, ruleset; tspan=(1, 100))
```

### Arguments

- `init`: initialisation array, or `NamedTuple` of arrays
- `ruleset::Ruleset`: A DynamicGrids `Ruleset` 

Keyword arguments are passed to [`InteractOutput`](@ref).
"""
mutable struct ElectronOutput{T, I<:InteractOutput{T}} <: AbstractInteractOutput{T}
    interface::I
    window::Blink.AtomShell.Window
end

ElectronOutput(; kwargs...) = begin
    interface = InteractOutput(; kwargs...)
    window = newelectronwindow(interface)
    ElectronOutput(interface, window)
end

interface(o::ElectronOutput) = o.interface

# Forward output methods to InteractOutput: ElectronOutput is just a wrapper.
Base.length(o::ElectronOutput) = length(interface(o))
Base.size(o::ElectronOutput) = size(interface(o))
Base.firstindex(o::ElectronOutput) = firstindex(interface(o))
Base.lastindex(o::ElectronOutput) = lastindex(interface(o))
Base.getindex(o::ElectronOutput, i::Union{Int,AbstractVector,Colon}) = 
    getindex(interface(o), i)
Base.setindex!(o::ElectronOutput, x, i::Union{Int,AbstractVector,Colon}) = 
    setindex!(interface(o), x, i)
Base.push!(o::ElectronOutput, x) = push!(interface(o), x)
Base.append!(o::ElectronOutput, x) = append!(interface(o), x)

DG.frames(o::ElectronOutput) = DG.frames(interface(o))
DG.init(o::ElectronOutput) = DG.init(interface(o))
DG.aux(o::ElectronOutput) = DG.aux(interface(o))
DG.mask(o::ElectronOutput) = DG.mask(interface(o))
DG.extent(o::ElectronOutput) = DG.extent(interface(o))
DG.graphicconfig(o::ElectronOutput) = DG.graphicconfig(interface(o))
DG.imageconfig(o::ElectronOutput) = DG.imageconfig(interface(o))
DG.starttime(o::ElectronOutput) = DG.starttime(interface(o))
DG.stoptime(o::ElectronOutput) = DG.stoptime(interface(o))
DG.tspan(o::ElectronOutput) = DG.tspan(interface(o))
DG.fps(o::ElectronOutput) = DG.fps(interface(o))
DG.isasync(o::ElectronOutput) = DG.isasync(interface(o))
DG.isstored(o::ElectronOutput) = DG.isstored(interface(o))
DG.store(o::ElectronOutput) = DG.store(interface(o))
DG.isshowable(o::ElectronOutput) = DG.isshowable(interface(o))

DG.setfps!(o::ElectronOutput, x) = DG.setfps!(interface(o), x)
DG.setrunning!(o::ElectronOutput, x) = DG.setrunning!(interface(o), x)
DG.setstarttime!(o::ElectronOutput, x) = DG.setstarttime!(interface(o), x)
DG.setstoptime!(o::ElectronOutput, x) = DG.setstoptime!(interface(o), x)
DG.settimestamp!(o::ElectronOutput, x) = DG.settimestamp!(interface(o), x)
DG.initialise(o::ElectronOutput, args...) = DG.initialise(interface(o), args...)
DG.finalise(o::ElectronOutput, args...) = DG.finalise(interface(o), args...)
DG.delay(o::ElectronOutput, x) = DG.delay(interface(o), x)

DG.minval(o::ElectronOutput) = DG.minval(interface(o))
DG.maxval(o::ElectronOutput) = DG.maxval(interface(o))
DG.processor(o::ElectronOutput) = DG.processor(interface(o))

isalive(o::ElectronOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

# Running checks depend on the blink window still being open
DG.isrunning(o::ElectronOutput) = isalive(o) && isrunning(interface(o))

DG.storegrid!(o::ElectronOutput, data::DynamicGrids.AbstractSimData) = 
    storegrid!(interface(o), data)

DG.showgrid(o::ElectronOutput, data::DG.AbstractSimData, args...) = 
    showgrid(interface(o), data, args...)

newelectronwindow(interface) = begin
    window = Blink.AtomShell.Window()
    body!(window, interface.page)
    window
end

Base.display(o::ElectronOutput) =
    if !isalive(o)
        o.window = newelectronwindow(interface(o))
    end
