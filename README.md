# DynamicGridsInteract

[![Build Status](https://travis-ci.org/cesaraustralia/DynamicGridsInteract.jl.svg?branch=master)](https://travis-ci.org/cesaraustralia/DynamicGridsInteract.jl)
[![Codecov](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl)

Provides web interfaces for visualising and interacting with simulations from 
DynamicGrids.jl, and for packages that build on it like Dispersal.jl. 

The basic `InteractOutput` works in Jupyter notebooks and the atom plot pane,
and also serves as the core component of other outputs. A Mux.jl web server
`ServerOutput` and a Blink.jl electron app `ElectronOutput` are also
included.


To use:

```julia
using DynamicGrids, DynamicGridsInteract

output = InteractOutput(init, ruleset; 
    tspan=(1, 100), 
    store=false, 
    processor=ColorProcessor()
)
display(output)
```

Where `init` is either the initial array(s) for the simulation, ruleset is the
`Ruleset` to run in simulations. 

To show the interface in the Atom plot pane, run `display(output)`.

The interface also provides control of the simulation, using Interact.jl. It
will automatically generate sliders for the parameters of the `Ruleset`, even
for user-defined rules. 

To define range limits for sliders, use the `@limits` macro from
[FieldMetadata.jl](https://github.com/rafaqz/FieldMetadata.jl/). Fields to be
ignored can be marked with `false` using the `@flatten` macro, and descriptions for
hover text use `@description`.

## Documentation

See the documentation for [DynamicGrids.jl](https://cesaraustralia.github.io/DynamicGrids.jl/dev/)
