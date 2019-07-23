
"""
A html output using Interact.jl and an Electron window through Blink.jl
BlinkOutput automatically generates sliders to control simulations
in realtime. args and kwargs are passed to [`WebOutput`]

## Example
```julia
using Blink
BlinkOutput(init, model)
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
mutable struct BlinkOutput{T, I<:WebOutput{T}} <: AbstractOutput{T}
    interface::I
    window::Blink.AtomShell.Window
end

BlinkOutput(frames::T, model, args...; kwargs...) where T <: AbstractVector = begin
    interface = WebOutput(frames, model, args...; kwargs...)
    window = Blink.AtomShell.Window()
    body!(window, interface.page)

    BlinkOutput{T,typeof(interface)}(interface, window)
end

# Forward output methods to WebOutput: BlinkOutput is just a wrapper.
@forward BlinkOutput.interface length, size, endof, firstindex, lastindex, getindex,
    setindex!, push!, append!,
    deleteframes!, storeframe!, updateframe!,
    delay, normalizeframe, processframe, webimage,
    settime!, settimestamp!, setrunning!, setfps!,
    getfps, gettlast, isshowable, isasync, curframe,
    hasfps, hasprocessor

# Running checks depend on the blink window still being open
isrunning(o::BlinkOutput) = isalive(o) && isrunning(o.interface)

isalive(o::BlinkOutput) = o.window.content.sock.state == WebSockets.ReadyState(1)

showframe(o::BlinkOutput, rs::AbstractRuleset, args...) = showframe(o.interface, rs, args...)
showframe(o::BlinkOutput, frame::AbstractArray, args...) = showframe(o.interface, frame, args...)
