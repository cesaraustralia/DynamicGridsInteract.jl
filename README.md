# CellularAutomataWeb

[![Build Status](https://travis-ci.com/rafaqz/CellularAutomataWeb.jl.svg?branch=master)](https://travis-ci.com/rafaqz/CellularAutomataWeb.jl)
[![Codecov](https://codecov.io/gh/rafaqz/CellularAutomataWeb.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rafaqz/CellularAutomataWeb.jl)

Provides web interfaces for visualising and interacting with simulations from 
CellularAutomataBase.jl and packages that build on it like Dispersal.jl. 

Both a Mux.jl web server and a Blink.jl electron interface are included.


To use:

```julia
using CellularAutomataWeb
BlinkOutput(init, ruleset; fps=25, showfps=fps, store=false,
            processor=GreyscaleProcessor(), theme=WebTheme(), extrainit=Dict())
```

Where `init` is either the initial array for the simulation, a vector of arrays or another AbstractOutput. 
`extrainit` is a named dictionary with additional arrays that can be chosen in the interface. An
Interact.jl theme can be passed with the `theme` keyword.

The interface provides control of the simulation. It will automatically generate 
Interact.jl sliders for the parameters of the `Ruleset` passed in, even for
user-defined rules.

## Documentation

See the documentation for [CellularAutomataBase.jl](https://rafaqz.github.io/CellularAutomataBase.jl/dev/)
