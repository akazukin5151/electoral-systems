# Electoral Systems [![Preview](https://img.shields.io/badge/preview-nbconvert-orange)](https://nbviewer.jupyter.org/github/akazukin5151/electoral-systems/blob/master/run_elections.ipynb) [![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.txt) [![status](https://img.shields.io/badge/status-inactive-green)](https://img.shields.io/badge/status-inactive-green) 

![Preview](https://raw.githubusercontent.com/akazukin5151/electoral-systems/master/Julia%20Ideal.png)

Simulates virtual elections under different electoral systems. Voters and candidates are distributed on a 2D plane  corresponding to their ideology. For more details read below

Inspired by Ka Yee-Ping's [Voting Simulation Visualizations](http://zesty.ca/voting/sim/) and Nicky Case's [To build a better ballot](https://ncase.me/ballot/)

![Approval bullet](https://github.com/akazukin5151/electoral-systems/blob/master/approval_bullet_ideal.png)

The above is a preview of approval_bullet(). It simulates when some voters under approval voting cast insincere ballots and bullet vote. That means they only approve their top candidate, even though they might approve of others. The title of each graph corresponds to the proportion of voters that are bullet voting.

If everyone is bullet voting, then the election should be exactly the same as under FPTP. However, it appears that bullet voting under approval voting actually is more effect than FPTP in suppressing the third candidate. Or there's something very wrong with my implementation

This is a Julia re-write of a previous version that was written in Python. Python is too slow for the number crunching needed here, and actually Altair fails to plot the graph anyway. So Julia it is.

## Note: the first run on both JupyterLab and .jl/REPL is extremely slow, because all the dependencies have to be compiled

Slow in the scale of minutes.

Look at PackageCompiler to precompile them. Precompiling JuliaPlots by following [this](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots/) worked for me.

# Usage (with JupyterLab, recommended)

1. Unfortunately, Binder is stuck on an ancient version of iJulia, so you need to install JupyterLab yourself and just open `run_elections.ipynb`
2. Run all cells

# Usage (with .jl file)

1. Make sure `elections.jl` and `testing.jl` are in the same folder
2. Run with `julia "path_to_folder/run_elections.jl"`

You can those functions for other purposes as well:

1. Inside Julia (REPL), type `push!(LOAD_PATH, "path_of_your_folder")`. You may want to add it to your startup.jl as well
2. In a new .jl file, put `using elections` in the top
3. Just use the functions like `fptp(...)`

To get the "ideal" image shown above, change the `0.1` to `0.01` in [this line](https://github.com/akazukin5151/electoral-systems/blob/6a8141f6ee995b46fcc8bfc80a951d82d6c9308f/run_elections.jl#L6). **Warning: will use lots of memory and take minutes.**

# Testing

Unit tests require `Test` and `InteractiveUtils` to be installed. The latter doesn't need to be explicitly `using`'ed if you're running the tests the Jupyter notebook

1. Make sure `elections.jl` and `testing.jl` are in the same folder
2. Run with `julia "path_to_folder/testing.jl"`
