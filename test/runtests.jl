using CellularAutomataBase, CellularAutomataWeb, Test, Colors, ColorSchemes

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

# Test the simulation with the leonardo colorscheme
l0 = RGB24(get(ColorSchemes.leonardo, 0))
l1 = RGB24(get(ColorSchemes.leonardo, 1))

leonardo2 = [l0 l0 l0 l0 l0 l0;
             l0 l0 l0 l0 l0 l0;
             l1 l0 l0 l0 l1 l1;
             l1 l0 l0 l0 l0 l0;
             l0 l0 l0 l0 l0 l1;
             l0 l0 l0 l0 l0 l0]

ruleset = Ruleset(Life(); init=init, overflow=WrapOverflow())
processor = ColorSchemeProcessor(ColorSchemes.leonardo)
output = BlinkOutput(init, ruleset; store=true, processor=processor) 


sim!(output, ruleset; init=init, tstop=2) 
sleep(1.5)
resume!(output.interface, ruleset; tadd=3)
sleep(1.5)

@test output[3] == test
@test output[5] == test2

# Make sure the image sent to the browser by the observable is showing the 
# final frame with the leonardo colorsheme
@test output.interface.image_obs[].children.tail[1] == leonardo2
replay(output)
sleep(1.5)
@test output.interface.image_obs[].children.tail[1] == leonardo2

close(output.window)
