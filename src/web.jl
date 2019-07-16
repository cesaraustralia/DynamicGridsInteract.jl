
const csskey = AssetRegistry.register(joinpath(dirname(pathof(CellularAutomataWeb)), "../assets/web.css"))

# TODO update themes
# Custom css theme
# struct WebTheme <: WidgetTheme end

# libraries(::WebTheme) = vcat(libraries(InteractBulma.BulmaTheme()), [csskey])


"Web outputs, such as BlinkOutput and MuxServer"
abstract type AbstractWebOutput{T} <: AbstractGraphicOutput{T} end


" The backend interface for BlinkOuput and MuxServer"
@ImageProc @Graphic @Output mutable struct WebInterface{P,IM,TI} <: AbstractGraphicOutput{T}
    page::P
    image_obs::IM
    t_obs::TI
end

"""
    WebInterface(frames::AbstractVector, ruleset; fps=25, showfps=fps, store=false,
             processor=GreyscaleProcessor(), extrainit=Dict())
"""
WebInterface(frames::AbstractVector, ruleset; fps=25, showfps=fps, store=false,
             processor=GreyscaleProcessor(), extrainit=Dict(), slider_throttle=0.1) = begin

    # settheme!(theme)

    init = deepcopy(frames[1])

    # Standard output and controls
    image_obs = Observable{Any}(dom"div"())

    timedisplay = Observable{Any}(dom"div"("0"))
    t_obs = Observable{Int}(1)
    map!(timedisplay, t_obs) do t
        dom"div"(string(t))
    end

    timespan_obs = Observable{Int}(1000)
    timespan_text = textbox("1000")
    map!(timespan_obs, observe(timespan_text)) do ts
        parse(Int, ts)
    end

    extrainit[:init] = init
    init_drop = dropdown(extrainit, value=init, label="Init")

    sim = button("sim")
    resume = button("resume")
    stop = button("stop")
    replay = button("replay")

    buttons = store ? (sim, resume, stop, replay) : (sim, resume, stop)
    fps_slider = slider(1:200, value=fps, label="FPS")
    basewidgets = hbox(buttons..., vbox(dom"span"("Frames"), timespan_text), fps_slider, init_drop)

    rulesliders = buildsliders(ruleset, slider_throttle)


    # Construct the interface object
    timestamp = 0.0; tref = 0; tlast = 1; running = false

    # Put it all together into a webpage
    page = vbox(hbox(image_obs), timedisplay, basewidgets, rulesliders)

    interface = WebInterface{typeof.((frames, fps, timestamp, tref, processor, page, image_obs, t_obs))...}(
                             frames, running, fps, showfps, timestamp, tref, tlast, store,
                             processor, page, image_obs, t_obs)

    # Initialise image
    image_obs[] = webimage(interface, normaliseframe(ruleset, frames[1]), 1)

    # Control mappings
    on(observe(sim)) do _
        sim!(interface, ruleset; init=init_drop[], tstop = timespan_obs[])
    end
    on(observe(resume)) do _
        resume!(interface, ruleset; tadd = timespan_obs[])
    end
    on(observe(replay)) do _
        replay(interface)
    end
    on(observe(stop)) do _
        setrunning!(interface, false)
    end
    on(observe(fps_slider)) do fps
        interface.fps = fps
        settimestamp!(interface, interface.t_obs[])
    end

    interface
end

buildsliders(ruleset, slider_throttle) = begin
    params = Flatten.flatten(ruleset.rules)
    fnames = fieldnameflatten(ruleset.rules)
    lims = metaflatten(ruleset.rules, FieldMetadata.limits)
    ranges = buildrange.(lims, params)
    parents = parentnameflatten(ruleset.rules)
    descriptions = metaflatten(ruleset.rules, FieldMetadata.description)
    attributes = (p, n, d) -> Dict(:title => "$p.$n: $d").(parents, fnames, descriptions)


    sliders = make_slider.(params, fnames, ranges, attributes)
    slider_obs = map((s...) -> s, throttle.(slider_throttle, observe.(sliders))...)
    on(slider_obs) do s
        ruleset.rules = Flatten.reconstruct(ruleset.rules, s)
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


make_slider(val, lab, rng, attr) = slider(rng; label=string(lab), value=val, attributes=attr)

buildrange(lim::Tuple{AbstractFloat,AbstractFloat}, val::T) where T = 
    T(lim[1]):(T(lim[2])-T(lim[1]))/400:T(lim[2])
buildrange(lim::Tuple{Int,Int}, val::T) where T = T(lim[1]):1:T(lim[2])

webimage(interface, frame, t) = dom"div"(frametoimage(interface, frame, t))


# CellularAutomataBase interface
CellularAutomataBase.isasync(o::WebInterface) = true

CellularAutomataBase.showframe(o::WebInterface, frame::AbstractArray, t) = begin
    o.image_obs[] = webimage(o, frame, t)
    o.t_obs[] = t
end
