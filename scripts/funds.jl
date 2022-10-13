using DrWatson
@quickactivate

include(srcdir("utils.jl"))

using CSV, DataFrames
using StatsPlots
using Distributions
using Dates

## US funds (https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs)

data = CSV.read(datadir("kaggle-funds", "MutualFunds.csv"), DataFrame) 
allyears = ["fund_return_" * year for year in string.(collect(2000:2020))]
# colnames = copy(allyears)
# insert!(colnames, 1, "fund_symbol")
funds = data[:, allyears]
dropmissing!(funds)


# Riskfree rate
IRX = CSV.read(datadir("^IRX.csv"), DataFrame)
@transform!(IRX, :Year = Year.(:Date))
Rf = combine(groupby(IRX, :Year), :Close => mean => :IRX).IRX/100

funds_excess = copy(funds)
for row in eachrow(funds_excess)
    row .= collect(row) .- Rf
end

## Distribution of monthly returns 
p1 = plot(xlabel = "Annual Return")
for year in 2000:2020
    plot!(returns[:, "fund_return_" * string(year)], seriestype = :stephist, xlims = (-1, 1), label = string(year))
end
vline!([0], color = :black, label = false)

## Correlation between Sharpe ratio and annualized return?
s = mean.(eachrow(returns[:, allyears]))./std.(eachrow(returns[:, allyears]))
a = annualized_return.(eachrow(returns[:, allyears]))

ρ = corspearman(s, a)
fund_plot = scatter(
    s,
    a,
    xlabel = "Sharpe Ratio of Annual Returns (riskfree rate = 0)",
    ylabel = "Annualized Returns",
    xlims = (-1, 3),
    ylims = (-.5, .5),
    label = "Spearman ρ = $(round(ρ; digits = 3))",
    legend = :topleft
)
hline!([0], color = :black, label = false)
vline!([0], color = :black, label = false)


## Correlation between Sharpe ratio and annualized return?
sharpe(x) = sharpe_ratio(x; log_returns = false)
s = sharpe.(eachrow(excess_returns[:, allyears]))
a = annualized_return.(eachrow(returns[:, allyears]))

ρ = corspearman(s, a)
p3 = scatter(
    s,
    a,
    xlabel = "Sharpe Ratio of Annual Returns (riskfree rate = 3-month T-bills)",
    ylabel = "Annualized Returns",
    label = "Spearman ρ = $(round(ρ; digits = 3))",
    legend = :topleft
)
hline!([0], color = :black, label = false)
vline!([0], color = :black, label = false)

plot(p2, p3, size = (1000, 600), dpi = 500)
savefig(plotsdir("sharpe-funds"))




plot(fund_plot, retail_plot)