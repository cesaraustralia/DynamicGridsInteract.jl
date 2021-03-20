"""
    ServerOutput(init; ruleset, tspan, port=8080, kw...)

A basic Mux.jl webserver, serving a [`InteractOutput`](@ref)s to the web.

Unlike ElectronOutput, the parameter modifications are not written back
to the original rulset, and the simulations are not stored. 
Each page load gets a identical initialised rulset.

### Arguments

- `init`: `AbstractArray` or `NamedTuple` of `Array`

### Keywords

- `port`: port number to reach the server. ie localhost:8080

Other keyword arguments to be passed to [`InteractOuput`](@ref).
"""
mutable struct ServerOutput{I}
    init::I
    port::Int
end
function ServerOutput(init; port=8080, ruleset, kw...)
    server = ServerOutput(init, port)
    function app(request)
        InteractOutput(deepcopy(server.init); ruleset=deepcopy(ruleset), kw...).page
    end
    WebIO.webio_serve(Mux.page("/", request -> app(request)), port)
    return server
end

function Base.show(io::IO, output::ServerOutput)
    println(io, typeof(output))
    println(io, "Port: ", output.port)
end
