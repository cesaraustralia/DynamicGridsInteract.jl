# DynamicGridsInteract

[![Build Status](https://travis-ci.com/cesaraustralia/DynamicGridsInteract.jl.svg?branch=master)](https://travis-ci.com/cesaraustralia/DynamicGridsInteract.jl)
[![Codecov](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cesaraustralia/DynamicGridsInteract.jl)

Provides web interfaces for visualising and interacting with simulations from 
DynamicGrids.jl and packages that build on it like Dispersal.jl. 

The basic InteractOutput works in Jupyter notebooks and the atom plot pane. A
Mux.jl web server `ServerOutput` and a Blink.jl electron interface
`ElectronOutput` are also included.


To use:

```julia
using DynamicGridsInteract
output = InteractOutput(init, ruleset; fps=25, showfps=fps, store=false,
                        processor=ColorProcessor(), extrainit=Dict())
display(output)
```

Where `init` is either the initial array for the simulation, a vector of arrays
or another AbstractOutput. `extrainit` is a named dictionary with additional
arrays that can be chosen in the interface. An Interact.jl theme can be passed
with the `theme` keyword.

The interface provides control of the simulation. It will automatically generate 
Interact.jl sliders for the parameters of the `Ruleset` passed in, even for
user-defined rules.

## Documentation

See the documentation for [DynamicGrids.jl](https://cesaraustralia.github.io/DynamicGrids.jl/dev/)
