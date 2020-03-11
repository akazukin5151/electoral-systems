module elections
using StatsBase
using Distributions
using ProgressMeter
using DataFrames
using Plots
gr()

export fptp, approval, borda, irv, score, election, loop_elections, unfold!, plotter

function fptp(distance_list)
    fptp_votes = argmin.(eachrow(distance_list))
    winner = StatsBase.countmap(fptp_votes)
    collectkeys = collect(keys(winner))
    collectvalues = collect(values(winner))
    return collectkeys[argmax(collectvalues)]
end

function approval(distance_list, a=0, b=1)
    # TODO: implement probability of bullet voting
    approval_radii = rand(Distributions.LogNormal(0,0.5), size(distance_list)[1])
    approval_list = distance_list .<= approval_radii
    winner = argmax(count.(eachcol(approval_list)))
    return winner
end

function unfold!(A::Array{Array{Int64, 1}, 1})::Array{Int64, 2}
    cols = size(A)[1]
    rows = size(A[1])[1]
    a = zeros(Int64, (cols, rows))
    for i in 1:cols
        for j in 1:rows
            a[i, j] = A[i][j]
        end
    end
    return a::Array{Int64, 2}
end

function borda(distance_list)
    d_sorted = sortperm.(eachrow(distance_list))
    unfolded = unfold!(d_sorted)
    borda_count = StatsBase.countmap.(eachcol(unfolded))

    # columns are candidates, rows are their borda scores to be summed
    res = fill(0, size(candidate_x_coord)[2], size(borda_count)[1])

    for i in 1:size(borda_count)[1]
        for (k,v) in borda_count[i]
            # res[row][column]
            res[i, k] = v*i
        end
    end

    borda_sum = sum(res,dims=1)
    borda_winner = argmin(borda_sum)[2]
    return borda_winner
end

function score(distance_list)
    # TODO: variable score radii -- why not use Approval's LogNormal?
    # each 'bin' gets a higher mean? but some values might be lower than the prev bin
    # rand(Distributions.LogNormal(0,0.5), 1)
    distlst = replace!(x -> x<=0.5 ? 10 : x, distance_list)
    distlst = replace!(x -> x>3 && x!=10 ? 0 : x, distance_list)
    distlst = replace!(x -> 0.5<x<=1 ? 8 : x, distance_list)
    distlst = replace!(x -> 1<x<=2 ? 7 : x, distance_list)
    distlst = replace!(x -> 2<x<=3 ? 5 : x, distance_list)
    score_sum = sum(distlst, dims=1)
    score_winner_pos = argmax(score_sum)[2]
    return score_winner_pos
end

function irv(distance_list)
    d_sorted = sortperm.(eachrow(distance_list))
    unfolded::Array{Int64, 2} = unfold!(d_sorted)
    #println(unfolded)

    first_pref = unfolded[:,1]

    while true
        bincount = StatsBase.countmap(first_pref)
        collectkeys = collect(keys(bincount))
        collectvalues = collect(values(bincount))
        pos_of_max = collectkeys[argmax(collectvalues)]

        #println(collectvalues)
        if bincount[pos_of_max] >= sum(collectvalues)/2
            return pos_of_max
        else
            lowest_cand = collectkeys[argmin(collectvalues)][1]
            #println(lowest_cand)
            @inbounds for i in 1:size(findall(first_pref.==lowest_cand))[1]
                row_num = findnext(first_pref.==lowest_cand, i)
                first_pref[row_num] = unfolded[row_num, 2]
            end
            #println(first_pref)
        end
    end
end

function election(voter_mean_x, voter_mean_y, stdev, number_of_voters, candidate_x_coord, candidate_y_coord)
    v_x = rand(Distributions.Normal(voter_mean_x, stdev), number_of_voters)
    v_y = rand(Distributions.Normal(voter_mean_y, stdev), number_of_voters)

    # DISTANCES
    #diff_x = v_x .- candidate_x_coord
    #diff_y = v_y .- candidate_y_coord
    distance_list = hypot.(v_x .- candidate_x_coord, v_y .- candidate_y_coord)

    fptp_winner::Integer = fptp(distance_list)
    approval_winner::Integer = approval(distance_list)
    borda_winner::Integer = borda(distance_list)
    irv_winner::Integer = irv(distance_list) # There's a bizzare bug where calling score() first will mess up this function's order
    score_winner::Integer = score(distance_list)

    return (fptp_winner, approval_winner, borda_winner, irv_winner, score_winner)
end

function loop_elections(voter_grid, candidate_x_coord, candidate_y_coord, number_of_voters=1000, stdev=1)
    voter_grid_tup_arr = vec(collect(voter_grid))
    voter_grid_size = size(voter_grid_tup_arr)[1]
    fptp_winner, approval_winner, borda_winner, irv_winner, score_winner = zeros(Integer, voter_grid_size), zeros(Integer, voter_grid_size), zeros(Integer, voter_grid_size), zeros(Integer, voter_grid_size), zeros(Integer, voter_grid_size)
    a, b = zeros(Float64, voter_grid_size), zeros(Float64, voter_grid_size)

    @showprogress for i in 1:voter_grid_size
        t1::Integer, t2::Integer, t3::Integer, t4::Integer, t5::Integer = election(voter_grid_tup_arr[i][1], voter_grid_tup_arr[i][2], stdev, number_of_voters, candidate_x_coord, candidate_y_coord)
        fptp_winner[i] = t1::Integer
        approval_winner[i] = t2::Integer
        borda_winner[i] = t3::Integer
        irv_winner[i] = t4::Integer
        score_winner[i] = t5::Integer

        a[i] = voter_grid_tup_arr[i][1]
        b[i] = voter_grid_tup_arr[i][2]
    end

    vdf = DataFrame()
    vdf.FPTP = fptp_winner
    vdf.Approval = approval_winner
    vdf.Borda = borda_winner
    vdf.IRV = irv_winner
    vdf.Score = score_winner
    vdf.x = a
    vdf.y = b
    return vdf
end

function plotter(df)
    p1 = plot(df.x, df.y, title="FPTP", seriestype=:scatter, color=df.FPTP, palette=[:red, :lightgreen, :blue], msw=0, markersize=2)
    plot!(candidate_x_coord, candidate_y_coord, seriestype=:scatter, palette=[:green, :blue, :red], msw=1, markersize=5, lims=(-2,2))
    p2 = plot(df.x, df.y, title="Approval", seriestype=:scatter, color=df.Approval, palette=[:red, :lightgreen, :blue], msw=0, markersize=2)
    plot!(candidate_x_coord, candidate_y_coord, seriestype=:scatter, palette=[:green, :blue, :red], msw=1, markersize=5, lims=(-2,2))
    p3 = plot(df.x, df.y, title="Borda", seriestype=:scatter, color=df.Borda, palette=[:red, :lightgreen, :blue], msw=0, markersize=2)
    plot!(candidate_x_coord, candidate_y_coord, seriestype=:scatter, palette=[:green, :blue, :red], msw=1, markersize=5, lims=(-2,2))
    p4 = plot(df.x, df.y, title="IRV", seriestype=:scatter, color=df.IRV, palette=[:red, :lightgreen, :blue], msw=0, markersize=2)
    plot!(candidate_x_coord, candidate_y_coord, seriestype=:scatter, palette=[:green, :blue, :red], msw=1, markersize=5, lims=(-2,2))
    p5 = plot(df.x, df.y, title="Score", seriestype=:scatter, color=df.Score, palette=[:red, :lightgreen, :blue], msw=0, markersize=2)
    plot!(candidate_x_coord, candidate_y_coord, seriestype=:scatter, palette=[:green, :blue, :red], msw=1, markersize=5, lims=(-2,2))
    final_plot = plot(p1, p2, p3, p4, p5, legend = false, size=((900,500)))
    return final_plot
end

const candidate_x_coord = [0.93 0.79 0.27]
const candidate_y_coord = [0.49 0.42 0.45]
const voter_grid = Iterators.product(-2:0.1:2, -2:0.1:2)
looped = loop_elections(voter_grid, candidate_x_coord, candidate_y_coord);

println("Please wait...")
chart = plotter(looped)

png(chart, "juliachart")

end
