using DrWatson
using StatsPlots, LaTeXStrings
gr(fontfamily="Computer Modern", dpi=500, left_margin = 3Plots.mm, right_margin = 3Plots.mm, bins = 100, colorbar = false)


include(scriptsdir("synthetic.jl"))
include(scriptsdir("ETFs.jl"))

@assert mean(ETF_returns.x) ≈ μ
@assert std(ETF_returns.x) ≈ σ

results = Dict(
    :normal => (
        data = @subset(synthetic, :ν .== Inf), plots = [], m_range = (-0.005, .005),
        title = "A. Normal"
        ),
    :student => (data = @subset(synthetic, :ν .< Inf), plots = [], m_range = (-.015, .015),
    title = "B. Student(ν = 3)"
    ),
    :ETF => (data = ETF, plots = [], m_range = (-1e-2, 5e-3),
    title = "C. ETFs"
    )
    )
    
# Main plot

for (key, case) in results
    push!(case.plots, 
        @df case.data histogram2d(:m, :s, xlims = case.m_range,
        title = case.title
            )
        )
    key == :normal && ylabel!("Volatility " * L"s")
    push!(case.plots, 
        @df case.data histogram2d(:m, :S, 
            xlims = case.m_range, ylims = (-5, 6)
            )   
        )
    key == :normal && ylabel!("Sharpe ratio " * L"S")
    
    Δm = range(case.m_range...; length = 50)
    δm = 1e-3
    
    push!(case.plots, 
        scatter(Δm, map(m -> meanse(@subset(case.data, m .<= :m).S), Δm),
            xlabel = "Mean return " * L"m", 
            label = false
            )
    )
    key == :normal && ylabel!("Conditional Sharpe " * L"\overline{S}(m)")
end

plot(
    [plot(case.plots..., layout = (3, 1)) for case in values(results)]..., 
    layout = (1, 3), size = (1000, 800)
)
savefig(plotsdir("main-plot"))

# Returns

@df ETF_returns histogram(:x, 
xlims = (-.5, .5), bins = 500, 
normalize = :pdf, yaxis = :log, label = "ETFs",
xlabel = "Daily log-returns",
ylabel = "Density"
)
plot!(x->pdf(TDist(μ, σ, 2.5), x), label = "Student(ν = 3)")
plot!(x->pdf(Normal(μ, σ), x), label = "normal", ylims = (5e-5, 1e2))
savefig(plotsdir("returns-dist"))

# Sharpe ratios

@df ETF histogram(:S, normalize = :pdf, label = "ETFs", xlabel = "Sharpe ratio " * L"S", ylabel = "Density")
@df synthetic density!(:S, group = :label, lw = 2)
plot!(x -> pdf(Normal(S, ΔS), x), lw = 2, ls = :dash, color = :black, label = "Asymptotic theory [Lo 02]", legend = :topleft, xlims = (-8, 6))
savefig(plotsdir("sharpe-dist"))

# Risk free rate

riskfree_plot = plot(1962:2022, riskfree_data.RIFLGFCY01NA,
ylabel = "Riskfree rate (RIFLGFCY01NA, %)",
label = false, xticks = 1960:10:2022, xlabel = "Year")
savefig(plotsdir("riskfree-rate"))