
"""
A html output using Interact.jl and an Electron window through Blink.jl
ElectronOutput automatically generates sliders to control simulations
in realtime. args and kwargs are passed to [`InteractOutput`]

## Example
```julia
using Blink
ElectronOutput(init, model)
```

### Arguments
- `frames::AbstractArray`: vector of matrices.
- `model::Models`: tuple of models wrapped in Models().
- `args`: any additional arguments to be passed to the model rule

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

ElectronOutput(frames::T, model, args...; kwargs...) where T <: AbstractVector = begin
    interface = InteractOutput(frames, model, args...; kwargs...)
    window = Blink.AtomShell.Window()
    body!(window, interface.page)

    ElectronOutput{T,typeof(interface)}(interface, window)
end

# Forward output methods to InteractOutput: ElectronOutput is just a wrapper.
@forward ElectronOutput.interface length, size, endof, firstindex, lastindex,
    getindex, setindex!, push!, append!,
    frames, fps, gettlast, curframe, delay,
    isshowable, isasync, hasprocessor,
    normaliseframe, frametoimage, deleteframes!, storeframe!, updateframe!,
    settime!, settimestamp!, setrunning!, setfps!

parent(o::ElectronOutput) = o.interface


# Running checks depend on the blink window still being open
isrunning(o::ElectronOutput) = isalive(o) && isrunning(o.interface)

isalive(o::ElectronOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

storeframe(o::ElectronOutput, data::AbstractSimData, args...) = showframe(parent(o), data, args...)
showframe(o::ElectronOutput, data::AbstractSimData, args...) = showframe(parent(o), data, args...)
showframe(frame::AbstractArray, o::ElectronOutput, ruleset::AbstractRuleset, args...) =
    showframe(frame, parent(o), ruleset, args...)
showframe(frame::AbstractArray, o::ElectronOutput, data::AbstractSimData, args...) =
    showframe(frame, parent(o), data, args...)
