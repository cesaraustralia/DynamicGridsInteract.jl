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
- `port`: port number to reach the server. ie localhost:8080 
See [`InteractOutput`](@ref) for complete list.

"""
ServerOutput(frames, rulset; port=8080, kwargs...) = begin
    server = ServerOutput(frames, port)
    store = false
    function app(request)
        InteractOutput(deepcopy(server.frames), deepcopy(rulset); kwargs...).page
    end
    WebIO.webio_serve(Mux.page("/", request -> app(request)), port)
    server
end

show(io::IO, output::ServerOutput) = begin
    println(io, typeof(output))
    println(io, "Port: ", output.port)
end




