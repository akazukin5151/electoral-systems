using elections
using Plots

const candidate_x_coord = [0.93 0.79 0.27]
const candidate_y_coord = [0.49 0.42 0.45]
const voter_grid = Iterators.product(-2:0.1:2, -2:0.1:2)

looped = loop_elections(voter_grid, candidate_x_coord, candidate_y_coord);
println("Please wait...")
chart = plotter(looped, candidate_x_coord, candidate_y_coord)

png(chart, "juliachart")
