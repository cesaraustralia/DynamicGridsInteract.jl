using DynamicGrids, DynamicGridsInteract, Test, Colors, ColorSchemes, ImageMagick, Aqua

if VERSION >= v"1.5.0"
    # Amibiguities are not owned by DynamicGrids
    # Aqua.test_ambiguities([DynamicGrids, Base, Core])
    Aqua.test_unbound_args(DynamicGridsInteract)
    Aqua.test_undefined_exports(DynamicGridsInteract)
    Aqua.test_project_extras(DynamicGridsInteract)
    # Aqua.test_stale_deps(DynamicGrids)
    Aqua.test_deps_compat(DynamicGridsInteract)
    Aqua.test_project_toml_formatting(DynamicGridsInteract)
end

# life glider sims

init =  Bool[0 0 0 0 0 0
             0 0 0 0 0 0
             0 0 0 0 0 0
             0 0 0 1 1 1
             0 0 0 0 0 1
             0 0 0 0 1 0]

test3 = [0 0 0 0 0 0
         0 0 0 0 0 0
         0 0 0 0 1 1
         0 0 0 1 0 1
         0 0 0 0 0 1
         0 0 0 0 0 0]

test5 = [0 0 0 0 0 0
         0 0 0 0 0 0
         1 0 0 0 1 1
         1 0 0 0 0 0
         0 0 0 0 0 1
         0 0 0 0 0 0]

renderer = Image(
    scheme=ColorSchemes.leonardo, zerocolor=nothing, maskcolor=nothing,
)

@testset "InteractOutput" begin
    l0 = ARGB32(get(ColorSchemes.leonardo, 0))
    l1 = ARGB32(get(ColorSchemes.leonardo, 1))

    leonardo2 = [l0 l0 l0 l0 l0 l0
                 l0 l0 l0 l0 l0 l0
                 l1 l0 l0 l0 l1 l1
                 l1 l0 l0 l0 l0 l0
                 l0 l0 l0 l0 l0 l1
                 l0 l0 l0 l0 l0 l0]

    ruleset = Ruleset(Life(); boundary=Wrap())
    output = InteractOutput(init; 
        tspan=1:2, ruleset=ruleset, store=true, text=nothing, renderer=renderer
    )
    sim!(output, ruleset)
    sleep(10)
    resume!(output, ruleset; tstop=5)
    sleep(2)

    @test output[1] == init
    @test output[3] == test3
    @test output[5] == test5

    @testset "output image matches colorscheme" begin
        @test output.image_obs[].children.tail[1] == leonardo2
    end

    @testset "output works with store=false" begin
        output = InteractOutput(init; 
            ruleset=ruleset, tspan=1:3, store=false, text=nothing, renderer=renderer
        )
        sim!(output, ruleset)
        output.graphicconfig.stoppedframe
        DynamicGrids.stoppedframe(output)
        sleep(10)
        resume!(output, ruleset; tstop=5)
        sleep(2)
        @test output[1] == test5
    end

end

if !Sys.islinux() # No graphic head loaded in CI: TODO add this
    @testset "ElectronOutput" begin
        ruleset = Ruleset(Life(); boundary=Wrap())
        output = ElectronOutput(init; 
            ruleset=ruleset, tspan=1:300, store=true, text=nothing, renderer=renderer
        )
        DynamicGrids.setrunning!(output, false)
        sim!(output.interface, ruleset)
        sleep(10)
        DynamicGrids.setrunning!(output, false)
        resume!(output.interface, ruleset; tstop=5)
        sleep(2)
        @test output[3] == test3
        @test output[5] == test5
        close(output.window)
    end
end

@testset "ServerOutput" begin
    ruleset = Ruleset(Life(); boundary=Wrap())
    ServerOutput(init; ruleset=ruleset, port=8080, renderer=renderer)
    # TODO: test the server somehow
end
