"""
A basic Mux.jl webserver, serving the same pages as BlinkOutput, but served for a 
multiple outputs in a local browser or the web.

MuxServer automatically generates sliders to control simulaitons
in realtime. Unlike BlinkOUtput, the modifications are not written back 
to the original rulset. Each page load gets a identical initialised rulset.
"""
mutable struct MuxServer{T} <: AbstractWebOutput{T}
    frames::T
    port::Int
end


"""
    MuxServer(frames, rulset, args...; fps=25, port=8080)
Builds a MuxServer and serves the standard web interface for rulset
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
MuxServer(frames::T, rulset; port=8080, kwargs...) where T <: AbstractVector = begin
    server = MuxServer(frames, port)
    store = false
    function muxapp(req)
        WebInterface(deepcopy(server.frames), deepcopy(rulset); kwargs...).page
    end
    webio_serve(page("/", req -> muxapp(req)), port)
    server
end
