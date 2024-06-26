using DrWatson
using StatsPlots, LaTeXStrings
gr(fontfamily="Computer Modern", dpi=500, left_margin=3Plots.mm, right_margin=3Plots.mm, bins=100, colorbar=false, legend=:topleft)


include(scriptsdir("ETFs.jl"))
include(scriptsdir("synthetic.jl"))

@assert mean(ETF_returns.x) ≈ μ
@assert std(ETF_returns.x) ≈ σ

results = Dict(
    :normal => (
        data=@subset(synthetic, :ν .== Inf), plots=[], m_range=(-5e-3, 5e-3),
        title="A. Normal"
    ),
    :student => (data=@subset(synthetic, :ν .< Inf), plots=[], m_range=(-1e-2, 1e-2),
        title="B. Student(ν = 4)"
    ),
    :ETF => (data=ETF, plots=[], m_range=(-1e-2, 5e-3),
        title="C. ETFs"
    )
)

# Main plot

for (key, case) in results
    push!(case.plots,
        @df case.data histogram2d(:m, :s, xlims=case.m_range,
            title=case.title
        )
    )
    key == :normal && ylabel!("Volatility " * L"s")
    # key == :student && plot!(m -> abs(m) * sqrt(T), label=L"s = \sqrt{T}\vert m\vert ", ylims=(0, 0.2))

    push!(case.plots,
        @df case.data histogram2d(:m, :sharpe,
            xlims=case.m_range, ylims=(-5, 6)
        )
    )
    key == :normal && ylabel!("Sharpe ratio " * L"S")
    key ∈ (:normal, :student) && plot!(m -> sqrt(T)m / σ, label=L"S = \sqrt{T}m/\sigma ")

    Δm = range(case.m_range...; length=50)
    δm = 1e-3

    push!(case.plots,
        scatter(Δm, map(m -> meanse(@subset(case.data, m .<= :m).sharpe), Δm),
            xlabel="Mean return " * L"m",
            label=false
        )
    )
    key == :normal && ylabel!("Conditional Sharpe " * L"\overline{S}(m)")
end

plot(
    [plot(case.plots..., layout=(3, 1)) for case in values(results)]...,
    layout=(1, 3), size=(1000, 800)
)
savefig(plotsdir("main-plot"))

# Returns

@df ETF_returns histogram(:x,
    xlims=(-0.5, 0.5), bins=500,
    normalize=:pdf, yaxis=:log, label="ETFs",
    xlabel="Daily log-returns",
    ylabel="Density", lw=2
)
plot!(x -> pdf(Normal(μ, σ), x), label="Normal", ylims=(5e-5, 1e2), lw=2)
plot!(x -> pdf(TDist(μ, σ, 3), x), label="Student(ν = 3)", lw=2)
savefig(plotsdir("returns-dist"))

μ_vol_scaled = nanmean(ETF_returns.x_vol_scaled)
σ_vol_scaled = nanstd(ETF_returns.x_vol_scaled)
@df ETF_returns histogram(:x_vol_scaled,
    xlims=(-10, 10), bins=500,
    normalize=:pdf, yaxis=:log, label="ETFs",
    xlabel="Daily log-returns (vol-scaled)",
    ylabel="Density", lw=2
)
plot!(x -> pdf(Normal(μ_vol_scaled, 1), x), label="Normal", ylims=(5e-5, 1e0), lw=2)
plot!(x -> pdf(TDist(μ_vol_scaled, 1, 4), x), label="Student(ν = 4)", lw=2)
savefig(plotsdir("returns-vol-scaled-dist"))

# Mean vol

@df @by(ETF_returns, :fund_symbol, :vol = nanstd(:x)) histogram(:vol, normalize=:pdf, bins=100, label=false, xlabel="ETF daily volatility", ylabel="Density")

begin
    plot()
    for g in groupby(ETF_returns_vol_scaled, :fund_category)
        @df g stephist!(:x_vol_scaled, histtype="line", normalize=:pdf, bins=100, yaxis=:log)
    end
    current()
    # Sharpe ratios
end

@df ETF histogram(:sharpe, normalize=:pdf, label="ETFs", xlabel="Sharpe ratio " * L"S", ylabel="Density")
@df synthetic density!(:sharpe, group=:label, lw=2)
plot!(x -> pdf(Normal(S, ΔS), x), lw=2, ls=:dash, color=:black, label="Asymptotic theory [Lo 02]", legend=:topleft, xlims=(-8, 6))
savefig(plotsdir("sharpe-dist"))

# Risk free rate

riskfree_plot = plot(1962:2022, riskfree_data.RIFLGFCY01NA,
    ylabel="Riskfree rate (RIFLGFCY01NA, %)",
    label=false, xticks=1960:10:2022, xlabel="Year", xlims=(1995, 2020), ylims=(0, 7), markers=:auto, lw=2)
savefig(plotsdir("riskfree-rate"))

# Volatility plots
@df @subset(synthetic, :S .> 0, :ν .== Inf) scatter(:m, :s, marker_z=:S, label=false)

@df @subset(synthetic, :S .> 0, :ν .< Inf) scatter(:m, 1 ./ :s, marker_z=:S, label=false, yaxis=:log)

@df @subset(ETF, :S .> 0) scatter(1 ./ :s, :m, marker_z=:S, label=false, yaxis=:log, xaxis=:log)

sort(ETF, :S; rev=true)

# Sortino

@df ETF histogram2d(:m, :S)
@df ETF histogram2d(:m, :sortino)

# Hills plot

function hills(x, k_range)
    n = length(x)
    s = sort(x)
    return [1 / mean(log.(s[n-k:n] / s[n-k])) for k in k_range]
end

k_range = 50:10000
plot(k_range, hills(abs.(ETF_returns.x), k_range), xlabel="Number of order statistics", ylabel="Hill estimator", label="raw daily abs(ETF returns)")
plot!(k_range, hills(abs.(ETF_returns.x_vol_scaled), k_range), xlabel="Number of order statistics", ylabel="Hill estimator", label="vol-scaled daily abs(ETF returns)")
savefig(plotsdir("hill"))