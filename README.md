# DynamicGridsInteract

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://cesaraustralia.github.io/DynamicGridsInteract.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://cesaraustralia.github.io/DynamicGridsInteract.jl/dev)
[![Build Status](https://travis-ci.org/cesaraustralia/DynamicGridsInteract.jl.svg?branch=master)](https://travis-ci.org/cesaraustralia/DynamicGridsInteract.jl)
[![Codecov](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl)

DynamicGridsInteract provides web interfaces for visualising and interacting
with simulations from
[DynamicGrids.jl](https://cesaraustralia.github.io/DynamicGrids.jl), and for
packages that build on it like [Dispersal.jl](https://cesaraustralia.github.io/Dispersal.jl). 

The basic `InteractOutput` works in the atom plot pane and Jupyter notebooks,
and also serves as the core component of other outputs. A Mux.jl web server
`ServerOutput` and a Blink.jl electron app `ElectronOutput` are also
included.

This demo shows the `InteractOutput` running it the atom IDE:

[![Demo](https://img.youtube.com/vi/cXzYGHw_DaA/maxresdefault.jpg)](https://youtu.be/cXzYGHw_DaA)

To use:

```julia
using DynamicGrids, DynamicGridsInteract

output = InteractOutput(init; 
    ruleset=ruleset,
    tspan=1:100, 
    processor=ColorProcessor()
)
display(output)
```

Where `init` is the initial array(s) for the simulation and ruleset is the
`Ruleset` to run in simulations. 

To show the interface in the Atom plot pane, run `display(output)`.

# Interactive parameters

The interface provides control of the simulation using ModelParameters.jl and Interact.jl via InteractModels.jl. 
It will automatically generate sliders for every `ModelParameters.Param` parameter in the `Ruleset`, given they 
additionally have either a `range` (an `AbstractRange`) or `bounds` (a `Tuple`) field defined.

See the examples in the InteractModels.jl [docs](https://rafaqz.github.io/ModelParameters.jl/stable/interactmodels/).
