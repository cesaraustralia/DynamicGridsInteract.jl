var documenterSearchIndex = {"docs":
[{"location":"#DynamicGridsInteract.jl-1","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.jl","text":"","category":"section"},{"location":"#","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.jl","text":"Modules = [DynamicGridsInteract]","category":"page"},{"location":"#DynamicGridsInteract.DynamicGridsInteract","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.DynamicGridsInteract","text":"DynamicGridsInteract\n\n(Image: Build Status) (Image: Codecov)\n\nProvides web interfaces for visualising and interacting with simulations from  DynamicGrids.jl, and for packages that build on it like Dispersal.jl. \n\nThe basic InteractOutput works in Jupyter notebooks and the atom plot pane, and also serves as the core component of other outputs. A Mux.jl web server ServerOutput and a Blink.jl electron app ElectronOutput are also included.\n\nTo use:\n\nusing DynamicGrids, DynamicGridsInteract\n\noutput = InteractOutput(init, ruleset; \n    tspan=(1, 100), \n    store=false, \n    processor=ColorProcessor()\n)\ndisplay(output)\n\nWhere init is either the initial array(s) for the simulation, ruleset is the Ruleset to run in simulations. \n\nTo show the interface in the Atom plot pane, run display(output).\n\nThe interface also provides control of the simulation, using Interact.jl. It will automatically generate sliders for the parameters of the Ruleset, even for user-defined rules. \n\nTo define range limits for sliders, use the @limits macro from FieldMetadata.jl. Fields to be ignored can be marked with false using the @flatten macro, and descriptions for hover text use @description.\n\nDocumentation\n\nSee the documentation for DynamicGrids.jl\n\n\n\n\n\n","category":"module"},{"location":"#DynamicGridsInteract.ElectronOutput","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.ElectronOutput","text":"ElectronOutput(init, ruleset::Ruleset; kwargs...)\n\nA html output using Interact.jl and an Electron window through Blink.jl ElectronOutput automatically generates sliders to control simulations in realtime. args and kwargs are passed to InteractOutput.\n\nExample\n\nusing Blink\nElectronOutput(init, ruleset)\n\nArguments\n\n\n\ninit: initialisation array, or NamedTuple of arrays\nruleset::Ruleset: A DynamicGrids Ruleset \n\nKeyword arguments are passed to InteractOutput.\n\n\n\n\n\n","category":"type"},{"location":"#DynamicGridsInteract.InteractOutput","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.InteractOutput","text":"InteractOutput(init, ruleset; fps=25, showfps=fps, store=false,\n               processor=ColorProcessor(), minval=nothing, maxval=nothing,\n               extrainit=Dict())\n\nAn Output for Atom/Juno and Jupyter notebooks, and the back-end for ElectronOutput and ServerOutput.\n\nArguments:\n\ninit: an Array or NamedTuple of arrays.\nruleset: the ruleset to run in the interface simulations.\n\nKeyword Arguments:\n\nfps::Real: frames per second\nshowfps::Real: maximum displayed frames per second\nstore::Bool: store the simulation frames to be used afterwards\n`processor::GridProcessor\nminval::Number: Minimum value to display in the simulation\nmaxval::Number: Maximum value to display in the simulation\n\n\n\n\n\n","category":"type"},{"location":"#DynamicGridsInteract.ServerOutput","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.ServerOutput","text":"A basic Mux.jl webserver, serving the same pages as ElectronOutput, but served for a multiple outputs in a local browser or the web.\n\nServerOutput automatically generates sliders to control simulaitons in realtime. Unlike ElectronOutput, the modifications are not written back to the original rulset. Each page load gets a identical initialised rulset.\n\n\n\n\n\n","category":"type"},{"location":"#DynamicGridsInteract.ServerOutput-Tuple{Any,Any}","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.ServerOutput","text":"ServerOutput(frames, rulset, args...; fps=25, port=8080)\n\nBuilds a ServerOutput and serves the standard web interface for rulset simulations at the chosen port.\n\nArguments\n\ninit: AbstractArray or NamedTuple of Array\nruleset::Models: tuple of rulset wrapped in Models().\n\nKeyword arguments\n\nport: port number to reach the server. ie localhost:8080\nkwargs: keyword arguments to be passed to InteractOuput.\n\n\n\n\n\n","category":"method"},{"location":"#DynamicGridsInteract.AbstractInteractOutput","page":"DynamicGridsInteract.jl","title":"DynamicGridsInteract.AbstractInteractOutput","text":"Abstract supertype of Interact outputs including InteractOuput and ElectronOutput\n\n\n\n\n\n","category":"type"}]
}
