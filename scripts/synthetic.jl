using DrWatson
@quickactivate

include(srcdir("utils.jl"))

using Random, StatsBase, Distributions
using DataFrames


# Parameters
μ = nanmean(ETF_returns.x)
σ = nanstd(ETF_returns.x)
T = 252
S = sqrt(T) * μ / σ
ΔS = sqrt(1 + S^2/2)
N = 100_000
Random.seed!(123)


# Generate data
synthetic = DataFrame(ν = Float64[], label=String[], m=Float64[], s=Float64[], sharpe=Float64[], sortino = Float64[])
for ν in (3, Inf)
    dist = isfinite(ν) ? TDist(μ, σ, ν) : Normal(μ, σ)
    label = ν < Inf ? "Student(ν = $ν)" : "Normal"
    for _ in 1:N
        x = rand(dist, T)
        push!(synthetic, 
        [ν, label, mean(x), std(x), sqrt(T) * mean(x)/std(x), sqrt(T) * mean(x)/downside_std(x)])
    end
end