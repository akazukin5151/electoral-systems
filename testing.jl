module testing
#=
Unit tests require Test and InteractiveUtils to be installed. The latter doesn't
need to be explicitly using'ed if you're running the tests the Jupyter notebook

1. Move elections.jl and testing.jl to the same folder
2. Inside Julia (REPL), type push!(LOAD_PATH, "path_of_your_folder"). You may 
   want to add it to your startup.jl as well
3. Type (in Julia REPL), include("path_of_your_folder/testing.jl"). The tests
   will immediately run
=#

using elections
using Test
using InteractiveUtils

# Note: columns are candidates and rows are each voter
# The number is the distance between them
# So [1 2 3] means candidate 3 is furthest from this voter
                                   # d_sorted
test_distance_list = [[1 2 3];     # 1 2 3
                      [2 1 3];     # 2 1 3
                      [2 3 1];     # 3 1 2
                      [3 2 1];]    # 3 2 1

@testset "sorter" begin
    @test sorter(test_distance_list) == [1 2 3; 2 1 3; 3 1 2; 3 2 1]
    @inferred sorter(test_distance_list)
end

@testset "FPTP" begin
    @test fptp(test_distance_list) ≈ 3
    @inferred fptp(test_distance_list)
end

@testset "Approval" begin
    @inferred approval(test_distance_list)
end

@testset "Borda" begin
    @test borda(test_distance_list) ≈ 1 #|| 2 || 3
    @inferred borda(test_distance_list)
end

@testset "IRV" begin
    @test irv(test_distance_list) ≈ 3
    @inferred irv(test_distance_list)
end

@testset "Score" begin
    @test score(test_distance_list) ≈ 1 #|| 2
    @inferred score(test_distance_list)
end

@testset "election functions" begin
    @test typeof(election(1, 1, 1, 100, [1 2 3], [3 2 1])) == NTuple{5,Int64}
    @inferred election(1, 1, 1, 100, [1 2 3], [3 2 1])
    @test size(loop_elections(Iterators.product(-2:1:2, -2:1:2), [1 2 3], [3 2 1])) == (25, 7)
    @inferred loop_elections(Iterators.product(-2:1:2, -2:1:2), [1 2 3], [3 2 1])
end

@code_warntype borda(test_distance_list)
# this, irv(), and sorted() shows yellow on Union{Nothing, ...}
# This is just the loop over the iterator, which returns the next value, or 
# nothing if at end
end
