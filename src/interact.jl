
# const csskey = AssetRegistry.register(joinpath(dirname(pathof(DynamicGridsInteract)), "../assets/web.css"))

# TODO update themes
# Custom css theme
# struct WebTheme <: WidgetTheme end

# libraries(::WebTheme) = vcat(libraries(InteractBulma.BulmaTheme()), [csskey])


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
# Defaults are passed in from ImageOutput constructor
InteractOutput(; frames, running, extent, graphicconfig, imageconfig,
               ruleset, extrainit=Dict(), throttle=0.1, interactive=true, kwargs...) = begin

    # settheme!(theme)

    # Standard output and controls
    image_obs = Observable{Any}(dom"div"())

    timedisplay = Observable{Any}(dom"div"("0"))
    t_obs = Observable{Int}(1)
    map!(timedisplay, t_obs) do t
        dom"div"(string(t))
    end
    page = vbox()
    o = InteractOutput(
         frames, running, extent, graphicconfig, imageconfig, ruleset, page, image_obs, t_obs
    )

    # timespan_obs = Observable{Int}(DynamicGrids.stoptime(ui))
    # timespan_text = textbox("1000")
    # map!(timespan_obs, observe(timespan_text)) do ts
        # parse(Int, ts)
    # end

    extrainit[:init] = deepcopy(init(extent))
    init_drop = dropdown(extrainit, value=extrainit[:init], label="Init")

    sim = button("sim")
    resume = button("resume")
    stop = button("stop")

    buttons = sim, resume, stop
    fps_slider = slider(1:200, value=fps(graphicconfig), label="FPS")
    basewidgets = hbox(buttons..., fps_slider, (length(extrainit) > 1 ? (init_drop,) : ())...)

    rulesliders = interactive ? buildsliders(ruleset, throttle) : dom"div"()

    # Put it all together into a webpage
    o.page = vbox(hbox(o.image_obs), timedisplay, basewidgets, rulesliders)

    # Initialise image
    simdata = DynamicGrids.SimData(extent, ruleset)
    image_obs[] = webimage(DG.grid2image(o, simdata, o[1], 1, first(extent.tspan)))

    # Control mappings. Make errors visible in the console.
    on(observe(sim)) do _
        try
            !isrunning(o) && sim!(o, ruleset; init=init_drop[])
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

    return o
end

# Base interface
Base.display(o::InteractOutput) = display(o.page)
Base.show(o::InteractOutput) = show(o.page)

# DynamicGrids interface
DynamicGrids.isasync(o::InteractOutput) = true

DynamicGrids.showimage(image::AbstractArray, o::InteractOutput, f, t) = begin
    println("frame: $f at: $t")
    try
        o.t_obs[] = f
        o.image_obs[] = webimage(image)
    catch e
        println(e)
    end
end


# Utils

buildsliders(ruleset, _throttle) = begin
    rs = rules(ruleset)
    params = Flatten.flatten(rs)
    fnames = fieldnameflatten(rs)
    bounds_ = metaflatten(rs, FieldMetadata.bounds)
    ranges = buildrange.(bounds_, params)
    parents = Tuple(string(p)[1] == '#' ? "" : p for p in parentnameflatten(rs))
    descriptions = metaflatten(rs, FieldMetadata.description)
    attributes = (p, n, d) -> Dict(:title => "$p.$n: $d").(parents, fnames, descriptions)


    sliders = buildslider.(params, fnames, ranges, attributes)
    slider_obs = map((s...) -> s, throttle.(_throttle, observe.(sliders))...)
    on(slider_obs) do s
        try
            ruleset.rules = Flatten.reconstruct(ruleset.rules, s)
        catch e
            println(e)
        end
    end

    group_title = nothing
    slider_groups = []
    group_items = []
    for i in 1:length(params)
        parent = parents[i]
        if group_title != parent
            group_title == nothing || push!(slider_groups, dom"div"(group_items...))
            group_items = Any[dom"h2"(string(parent))]
            group_title = parent
        end
        push!(group_items, sliders[i])
    end
    push!(slider_groups, dom"h2"(group_items...))

    vbox(slider_groups...)
end


buildslider(val, lab, rng, attr) = slider(rng; label=string(lab), value=val, attributes=attr)

buildrange(lim::Tuple{AbstractFloat,AbstractFloat}, val::T) where T =
    T(lim[1]):(T(lim[2])-T(lim[1]))/1000:T(lim[2])
buildrange(lim::Tuple{Int,Int}, val::T) where T = T(lim[1]):1:T(lim[2])

webimage(image) = dom"div"(image)
