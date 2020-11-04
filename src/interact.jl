
"""
Abstract supertype of Interact outputs including `InteractOuput` and `ElectronOutput`
"""
abstract type AbstractInteractOutput{T} <: ImageOutput{T} end


"""
    InteractOutput(init; ruleset, fps=25.0, store=false,
                   processor=ColorProcessor(), minval=nothing, maxval=nothing,
                   extrainit=Dict())

An `Output` for Atom/Juno and Jupyter notebooks,
and the back-end for [`ElectronOutput`](@ref) and [`ServerOutput`](@ref).


### Arguments:
- `init`: initialisation Array or NamedTuple of arrays.

### Keyword Arguments:
- `ruleset`: the ruleset to run in the interface simulations.
- `tspan`: `AbstractRange` timespan for the simulation
- `fps::Real`: frames per second to display the simulation
- `store::Bool`: whether ot store the simulation frames for later use
- `processor::GridProcessor
- `minval::Number`: minimum value to display in the simulation
- `maxval::Number`: maximum value to display in the simulation
"""
mutable struct InteractOutput{T,F<:AbstractVector{T},E,GC,IC,RS<:Ruleset,Pa,IM,TI} <: AbstractInteractOutput{T}
    frames::F
    running::Bool 
    extent::E
    graphicconfig::GC
    imageconfig::IC
    ruleset::RS
    page::Pa
    image_obs::IM
    t_obs::TI
end
# Most defaults are passed in from the generic ImageOutput constructor
function InteractOutput(; 
    frames, running, extent, graphicconfig, imageconfig,
    ruleset, extrainit=Dict(), throttle=0.1, interactive=true, kwargs...
)
    # Observables that update during the simulation
    image_obs = Observable{Any}(dom"div"())
    t_obs = Observable{Int}(1)

    # Page and output construction
    page = vbox()
    output = InteractOutput(
         frames, running, extent, graphicconfig, imageconfig, ruleset, page, image_obs, t_obs
    )

    # Widgets
    timedisplay = time_text(t_obs)
    controls = control_widgets(output, ruleset)
    sliders = rule_sliders(ruleset, throttle, groups, interactive)

    # Put it all together into a web page
    output.page = vbox(hbox(output.image_obs), timedisplay, controls, sliders)

    # Initialise image Observable
    simdata = DynamicGrids.SimData(extent, ruleset)
    image_obs[] = _webimage(DG.grid2image(o, simdata, o[1], 1, first(extent.tspan)))

    return hbox(sim, resume, stop, fps_slider, init_drop...)
end

# Base interface
Base.display(o::InteractOutput) = display(o.page)
Base.show(o::InteractOutput) = show(o.page)

# DynamicGrids interface
DynamicGrids.isasync(o::InteractOutput) = true
function DynamicGrids.showimage(image::AbstractArray, o::InteractOutput, f, t)
    println("frame: $f at: $t")
    # Update simulation image, makeing sure any errors are printed in the REPL
    try
        o.t_obs[] = f
        o.image_obs[] = _webimage(image)
    catch e
        println(e)
    end
    return nothing
end

_webimage(image) = dom"div"(image)



# Widget buliding

function time_text(t_obs::Observable)
    timedisplay = Observable{Any}(dom"div"("0"))
    map!(timedisplay, t_obs) do t
        dom"div"(string(t))
    end
    return timedisplay
end

function rule_sliders(ruleset, throttle, groups, interactive)
    if interactive 
        return ModelParameters.attach_sliders!(ruleset; throttle=throttle, grouped=grouped) 
    else
        return dom"div"()
    end
end

function control_widgets(o::InteractOutput, ruleset)
    # We use the init dropdown for the simulation init, even if we don't 
    # show the dropdown because it only has 1 option.
    extrainit[:init] = deepcopy(init(extent))
    init_dropdown = dropdown(extrainit, value=extrainit[:init], label="Init")
    maybe_init_dropdown = length(extrainit) > 1 ? (init_dropdown,) : ()

    fps_slider = slider(1:200, value=fps(graphicconfig), label="FPS")

    # Buttons
    sim = button("sim")
    resume = button("resume")
    stop = button("stop")

    # Control mappings. Make errors visible in the console.
    on(observe(sim)) do _
        try
            !isrunning(o) && sim!(o, ruleset; init=init_dropdown[])
        catch e
            println(e)
        end
    end
    on(observe(resume)) do _
        try
            !isrunning(o) && resume!(o, ruleset; tstop=last(tspan(o)))
        catch e
            println(e)
        end
    end
    on(observe(stop)) do _
        try
            setrunning!(o, false)
        catch e
            println(e)
        end
    end
    on(observe(fps_slider)) do fps
        try
            setfps!(o, fps)
            settimestamp!(o, o.t_obs[])
        catch e
            println(e)
        end
    end

    return hbox(sim, resume, stop, fps_slider, maybe_init_dropdown...)
end
