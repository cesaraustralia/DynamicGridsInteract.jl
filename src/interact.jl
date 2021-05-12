
"""
    AbstractInteractOutput

Abstract supertype of Interact outputs including `InteractOuput` and `ElectronOutput`
"""
abstract type AbstractInteractOutput{T,F} <: ImageOutput{T,F} end

const output_css = Asset(joinpath(@__DIR__, "..", "assets", "style.css"))

"""
    InteractOutput <: AbstractInteractOutput

    InteractOutput(init; ruleset, kw...)

An `Output` for Atom/Juno and Jupyter notebooks,
and the back-end for [`ElectronOutput`](@ref) and [`ServerOutput`](@ref).

# Arguments:

- `init`: initialisation `Array` or `NamedTuple` of arrays.

# Keywords

- `ruleset::Ruleset`: the ruleset to run in the interface simulations.
- `tspan`: `AbstractRange` timespan for the simulation
- `aux`: NamedTuple of arbitrary input data. Use `get(data, Aux(:key), I...)` 
    to access from a `Rule` in a type-stable way.
- `mask`: `BitArray` for defining cells that will/will not be run.
- `padval`: padding value for grids with neighborhood rules. The default is `zero(eltype(init))`.
- `font`: `String` font name, used in default `TextConfig`. A default will be guessed.
- `text`: `TextConfig` object or `nothing` for no text.
- `scheme`: ColorSchemes.jl scheme, or `Greyscale()`
- `renderer`: `Renderer` such as `Image` or `Layout`
- `minval`: minimum value(s) to set colour maximum
- `maxval`: maximum values(s) to set colour minimum

(See DynamicGrids.jl docs for more details)
"""
mutable struct InteractOutput{T,F<:AbstractVector{T},E,GC,IC,RS<:Ruleset,Pa,IM,TI} <: AbstractInteractOutput{T,F}
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
    frames, running, extent, graphicconfig, imageconfig, ruleset, 
    extrainit=Dict(), throttle=0.1, interactive=true, kw...
)
    # Observables that update during the simulation
    image_obs = Observable{Any}(dom"div"())
    t_obs = Observable{Int}(1)

    # Page and output construction
    page = Scope()
    output = InteractOutput(
        frames, running, extent, graphicconfig, imageconfig, ruleset, page, image_obs, t_obs
    )

    # Widgets
    timedisplay = _time_text(t_obs)
    controls = _control_widgets(output, ruleset, extrainit)
    sliders = _rule_sliders(ruleset, throttle, interactive)

    # Put it all together into a web page
    output.page = Scope(
        imports=[output_css],
        dom=vbox(
            dom"div.resizable"(output.image_obs; title="Drag bottom right to resize"), 
            timedisplay, 
            controls, 
            sliders
        ),
    )

    # Initialise image Observable simdata = DynamicGrids.SimData(extent, ruleset) image_obs[] = _webimage(DG.render!(output, simdata))

    return output
end

# Base interface
Base.display(o::InteractOutput) = display(o.page)
Base.show(o::InteractOutput) = show(o.page)

# DynamicGrids interface
DynamicGrids.isasync(o::InteractOutput) = true
function DynamicGrids.showimage(image::AbstractArray, o::InteractOutput, data::AbstractSimData)
    # Update simulation image, makeing sure any errors are printed in the REPL
    try
        o.t_obs[] = currentframe(data)
        o.image_obs[] = _webimage(image)
    catch e
        println(e)
    end
    return nothing
end

_webimage(image) = dom"div"(image)


# Widget buliding

function _time_text(t_obs::Observable)
    timedisplay = Observable{Any}(dom"div"("0"))
    map!(timedisplay, t_obs) do t
        dom"div"(string(t))
    end
    return timedisplay
end

function _rule_sliders(ruleset, throttle, interactive)
    if interactive 
        return InteractModels.attach_sliders!(ruleset; throttle=throttle, submodel=Rule) 
    else
        return dom"div"()
    end
end

function _control_widgets(o::InteractOutput, ruleset, extrainit)
    # We use the init dropdown for the simulation init, even if we don't 
    # show the dropdown because it only has 1 option.
    extrainit[:init] = deepcopy(init(o))
    init_dropdown = dropdown(extrainit, value=extrainit[:init], label="Init")
    maybe_init_dropdown = length(extrainit) > 1 ? (init_dropdown,) : ()

    fps_slider = slider(1:200, value=fps(o), label="FPS")

    # Buttons
    sim = button("sim")
    resume = button("resume")
    stop = button("stop")

    # Control mappings. Make errors visible in the console.
    on(observe(sim)) do _
        try
            !DG.isrunning(o) && sim!(o, ruleset; init=init_dropdown[])
        catch e
            println(e)
        end
    end
    on(observe(resume)) do _
        try
            !DG.isrunning(o) && resume!(o, ruleset; tstop=last(tspan(o)))
        catch e
            println(e)
        end
    end
    on(observe(stop)) do _
        try
            DG.setrunning!(o, false)
        catch e
            println(e)
        end
    end
    on(observe(fps_slider)) do fps
        try
            DG.setfps!(o, fps)
            DG.settimestamp!(o, o.t_obs[])
        catch e
            println(e)
        end
    end

    return hbox(sim, resume, stop, fps_slider, maybe_init_dropdown...)
end
