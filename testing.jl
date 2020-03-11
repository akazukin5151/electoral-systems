module testing
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
    @inferred election(1, 1, 1, 100, [1 2 3], [3 2 1])
    @inferred loop_elections(Iterators.product(-2:1:2, -2:1:2), [1 2 3], [3 2 1])
end

@testset "unfold" begin
    @test unfold!(sortperm.(eachrow(test_distance_list))) == [[1 2 3]; [1 2 3]; [1 2 3]; [1 2 3]]
    @inferred unfold!(sortperm.(eachrow(test_distance_list))) == [[1 2 3]; [1 2 3]; [1 2 3]; [1 2 3]]
end

@code_warntype borda(test_distance_list)
# and irv shows yellow on Union{Nothing, ...}
# This is just the loop over the iterator, which returns the next value, or nothing if at end

end
