
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
mutable struct ElectronOutput{T,F,I<:InteractOutput{T,F}} <: AbstractInteractOutput{T,F}
    interface::I
    window::Blink.AtomShell.Window
end
function ElectronOutput(; kwargs...)
    interface = InteractOutput(; kwargs...)
    window = _newelectronwindow(interface)
    ElectronOutput(interface, window)
end

interface(o::ElectronOutput) = o.interface

# Forward output methods to InteractOutput: ElectronOutput is just a wrapper.
for f in (:length, :size, :firstindex, :lastindex)
    @eval $f(o::ElectronOutput) = $f(interface(o))
end

for f in (:getindex, :setindex!, :push!, :append!)
    @eval $f(o::ElectronOutput, x) = $f(interface(o), x)
end

# DynamicGrids.jl interface
for f in (
    :frames, :init, :aux, :mask, :extent, :graphicconfig, :imageconfig,
    :stoppedframe, :tspan, :fps, :isasync, :isstored, :store, :isshowable,
    :minval, :maxval, :renderer
)
   @eval DG.$f(o::ElectronOutput) = DG.$f(interface(o))
end

for f in (
    :setfps!, :setrunning!, :settspan!, :settimestamp!, :setstoppedframe!,
    :initialise!, :finalise!, :initialisegraphics, :finalisegraphics, :maybesleep,
)
   @eval DG.$f(o::ElectronOutput, args...) = DG.$f(interface(o), args...)
end

DG.storeframe!(o::ElectronOutput, data::DG.AbstractSimData) =
    DG.storeframe!(interface(o), data)
DG.showframe(o::ElectronOutput, data::DG.AbstractSimData, args...) =
    DG.showframe(interface(o), data, args...)


# Running checks depend on the blink window still being open
DG.isrunning(o::ElectronOutput) = _isalive(o) && DG.isrunning(interface(o))

_isalive(o::ElectronOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

# Display

function Base.display(o::ElectronOutput)
    if !_isalive(o)
        o.window = _newelectronwindow(interface(o))
    end
    return nothing
end

function _newelectronwindow(interface)
    window = Blink.AtomShell.Window()
    body!(window, interface.page)
    return window
end
