using DynamicGrids, DynamicGridsInteract, Test, Colors, ColorSchemes, ImageMagick

# life glider sims

init =  [0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 1 1 1;
         0 0 0 0 0 1;
         0 0 0 0 1 0]

test3 = [0 0 0 0 0 0;
         0 0 0 0 0 0;
         0 0 0 0 1 1;
         0 0 0 1 0 1;
         0 0 0 0 0 1;
         0 0 0 0 0 0]

test5 = [0 0 0 0 0 0;
         0 0 0 0 0 0;
         1 0 0 0 1 1;
         1 0 0 0 0 0;
         0 0 0 0 0 1;
         0 0 0 0 0 0]

g0 = ARGB32(0)
g1 = ARGB32(1)
grey2 = [g0 g0 g0 g0 g0 g0;
         g0 g0 g0 g0 g0 g0;
         g1 g0 g0 g0 g1 g1;
         g1 g0 g0 g0 g0 g0;
         g0 g0 g0 g0 g0 g1;
         g0 g0 g0 g0 g0 g0]

processor = ColorProcessor(scheme=ColorSchemes.leonardo)

@testset "InteractOutput" begin
    l0 = ARGB32(get(ColorSchemes.leonardo, 0))
    l1 = ARGB32(get(ColorSchemes.leonardo, 1))

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

    @test output[1] == init
    @test output[3] == test3
    @test output[5] == test5

    @testset "output image matches colorscheme" begin
        @test output.image_obs[].children.tail[1] == leonardo2
    end

    @testset "output works with store=false" begin
        output = InteractOutput(init, ruleset; store=false, processor=processor);
        sim!(output, ruleset; init=init, tspan=(1, 2))
        sleep(5)
        resume!(output, ruleset; tstop=5)
        sleep(5)
        @test output[1] == test5
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

    @test output[3] == test3
    @test output[5] == test5
    close(output.window)
end

@testset "ServerOutput" begin
    ruleset = Ruleset(Life(); init=init, overflow=WrapOverflow())
    ServerOutput([init], ruleset; port=8080, processor=processor)
    # TODO: test the server somehow
end

using DynamicGrids, DynamicGridsGtk, ColorSchemes, Colors

const DEAD = 1
const ALIVE = 2
const BURNING = 3

# Define the Rule struct
struct ForestFire{R,W,N,PC,PR} <: NeighborhoodRule{R,W}
    neighborhood::N
    prob_combustion::PC
    prob_regrowth::PR
end
ForestFire(; grid=:_default_, neighborhood=RadialNeighborhood{1}(), prob_combustion=0.0001, prob_regrowth=0.01) =
    ForestFire{grid,grid}(neighborhood, prob_combustion, prob_regrowth)

# Define an `applyrule` method to be broadcasted over the grid for the `ForestFire` rule
@inline DynamicGrids.applyrule(rule::ForestFire, data, state::Integer, index, hoodbuffer) =
    if state == ALIVE
        if BURNING in DynamicGrids.neighbors(rule, hoodbuffer)
            BURNING
        else
            rand() <= rule.prob_combustion ? BURNING : ALIVE
        end
    elseif state in BURNING
        DEAD
    else
        rand() <= rule.prob_regrowth ? ALIVE : DEAD
    end

# Set up the init array, ruleset and output (using a Gtk window)
init = fill(ALIVE, 400, 400)
textconfig = TextConfig("arial", 
ruleset = Ruleset(ForestFire(); init=init)
processor = ColorProcessor(scheme=ColorSchemes.rainbow, zerocolor=RGB24(0.0))
output = GtkOutput(init; fps=25, minval=DEAD, maxval=BURNING, processor=processor)

# Run the simulation
sim!(output, ruleset; tspan=(1, 200))

# Save the output as a gif
savegif("forestfire.gif", output)
