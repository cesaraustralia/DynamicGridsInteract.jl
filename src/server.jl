"""
    ServerOutput(init; port=8080, rulset, tspan, kw...)

A basic Mux.jl webserver, serving a [`InteractOutput`](@ref)s to the web.

Unlike [`ElectronOutput`](@ref), the parameter modifications are not 
written back to the original rulset, and the simulations are not stored. 
Each page load gets a newly initialised Rulset.

# Arguments

- `init`: initialisation `Array` or `NamedTuple` of `Array`

# Keyword arguments

- `port`: port number to reach the server. `8080` by default, found at `localhost:8080`.
$INTERACT_OUTPUT_KEYWORDS

An `ImageConfig` object can be also passed to the `imageconfig` keyword, and other keywords will be ignored.
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
