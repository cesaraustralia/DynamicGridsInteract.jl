using DynamicGrids, DynamicGridsInteract, Test, Colors, ColorSchemes

# life glider sims

init =  [0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 1 1 1;
         0 0 0 0 0 1;
         0 0 0 0 1 0]
               
test =  [0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 0 1 1;
         0 0 0 1 0 1;
         0 0 0 0 0 1;
         0 0 0 0 0 0]

test2 = [0 0 0 0 0 0;
         0 0 0 0 0 0;
         1 0 0 0 1 1;
         1 0 0 0 0 0;
         0 0 0 0 0 1;
         0 0 0 0 0 0]

g0 = RGB24(0)
g1 = RGB24(1)
grey2 = [g0 g0 g0 g0 g0 g0;
         g0 g0 g0 g0 g0 g0;
         g1 g0 g0 g0 g1 g1;
         g1 g0 g0 g0 g0 g0;
         g0 g0 g0 g0 g0 g1;
         g0 g0 g0 g0 g0 g0]

processor = ColorProcessor(ColorSchemes.leonardo, nothing, nothing)

@testset "InteractOutput" begin
    l0 = RGB24(get(ColorSchemes.leonardo, 0))
    l1 = RGB24(get(ColorSchemes.leonardo, 1))

    leonardo2 = [l0 l0 l0 l0 l0 l0;
                 l0 l0 l0 l0 l0 l0;
                 l1 l0 l0 l0 l1 l1;
                 l1 l0 l0 l0 l0 l0;
                 l0 l0 l0 l0 l0 l1;
                 l0 l0 l0 l0 l0 l0]

    ruleset = Ruleset(Life(); init=init, overflow=WrapOverflow())
    output = InteractOutput(init, ruleset; store=true, processor=processor); 
    sim!(output, ruleset; init=init, tspan=(1, 2)) 
    sleep(5)
    resume!(output, ruleset; tstop=5)
    sleep(5)

    @test output[3] == test
    @test output[5] == test2

    @testset "output image matches colorscheme" begin
        @test output.image_obs[].children.tail[1] == leonardo2
    end
end



@testset "ElectronOutput" begin
    ruleset = Ruleset(Life(); init=init, overflow=WrapOverflow())
    output = ElectronOutput(init, ruleset; store=true, processor=processor) 
    DynamicGrids.setrunning!(output, false)
    sim!(output.interface, ruleset; init=init, tspan=(1, 3)) 
    sleep(5)
    DynamicGrids.setrunning!(output, false)
    resume!(output.interface, ruleset; tstop=5)
    sleep(5)

    @test output[3] == test
    @test output[5] == test2
    close(output.window)
end

