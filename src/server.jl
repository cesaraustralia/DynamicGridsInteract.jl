"""
A basic Mux.jl webserver, serving the same pages as ElectronOutput, but served for a 
multiple outputs in a local browser or the web.

ServerOutput automatically generates sliders to control simulaitons
in realtime. Unlike ElectronOutput, the modifications are not written back 
to the original rulset. Each page load gets a identical initialised rulset.
"""
mutable struct ServerOutput{T} <: AbstractInteractOutput{T}
    frames::T
    port::Int
end


"""
    ServerOutput(frames, rulset, args...; fps=25, port=8080)
Builds a ServerOutput and serves the standard web interface for rulset
simulations at the chosen port. 

### Arguments
- `frames::AbstractArray`: vector of matrices.
- `rulset::Models`: tuple of rulset wrapped in Models().
- `args`: any additional arguments to be passed to the rulset rule

### Keyword arguments
- `fps`: frames per second
- `showmax_fps`: maximum displayed frames per second
- `port`: port number to reach the server at
"""
ServerOutput(frames, rulset; port=8080, kwargs...) = begin
    server = ServerOutput(frames, port)
    store = false
    function muxapp(req)
        InteractOutput(deepcopy(server.frames), deepcopy(rulset); kwargs...).page
    end
    webio_serve(page("/", req -> muxapp(req)), port)
    server
end
