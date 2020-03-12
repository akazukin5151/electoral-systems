# Electoral Systems

![Preview](https://raw.githubusercontent.com/twenty5151/electoral-systems/master/Julia%20Ideal.png)

Simulates virtual elections using different electoral systems, with voters and candidates on a 2D plane.

Inspired by Ka Yee-Ping's [Voting Simulation Visualizations](http://zesty.ca/voting/sim/) and Nicky Case's [To build a better ballot](https://ncase.me/ballot/)

This is a Julia re-write of a previous version that was written in Python. Python is too slow for the number crunching needed here, and actually Altair fails to plot the graph anyway. So Julia it is.

## Note: the first run on both JupyterLab and .jl/REPL is extremely slow, because all the dependencies have to be compiled

Slow in the scale of minutes.

Look at PackageCompiler to precompile them. Precompiling JuliaPlots by following [this](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots/) worked for me.

# Usage (with JupyterLab, recommended)

1. Unfortunately, Binder is stuck on an ancient version of iJulia, so you need to install JupyterLab yourself and just open the .ipynb file
2. Run all cells

# Usage (with .jl file)

Run with `julia "path_to_folder/elections.jl"`

Alternatively it can be used as a module called `elections`. 

1. Inside Julia (REPL), type `push!(LOAD_PATH, "path_of_your_folder")`. You may want to add it to your startup.jl as well
2. In a new .jl file, type `using elections` to start using the functions

To get the "ideal" image shown above, change the `0.1` to `0.01` in [this line](https://github.com/twenty5151/electoral-systems/blob/e3ce899621789d23f357dfb9c43dd855d8e2bcf9/elections.jl#L165). **Warning: will use lots of memory and take minutes.**

# Testing

Unit tests require `Test` and `InteractiveUtils` to be installed. The latter doesn't need to be explicitly `using`'ed if you're running the tests the Jupyter notebook

1. Move elections.jl and testing.jl to the same folder
2. Inside Julia (REPL), type `push!(LOAD_PATH, "path_of_your_folder")`. You may want to add it to your startup.jl as well
2. Type (in Julia REPL), `include("path_of_your_folder/testing.jl")`. The tests will immediately run
