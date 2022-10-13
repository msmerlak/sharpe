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



funds_ρ = corspearman( mean.(eachrow(funds[:, allyears]))./std.(eachrow(funds[:, allyears])),
annualized_return.(eachrow(funds[:, allyears]))
)
funds_plot = scatter(
    mean.(eachrow(funds[:, allyears]))./std.(eachrow(funds[:, allyears])),
    annualized_return.(eachrow(funds[:, allyears])),
    title = "$(size(funds, 1)) US funds and ETFs (2000-2020)",
    legend = :bottomright,
    ylabel="Compounding Annualized Return", 
    xlabel="Sharpe Ratio", 
    alpha = .7,
    xlims = (-1, 2),
    ylims = (-.4, .4),
    label = "Spearman ρ = $(round(funds_ρ; digits = 3))"
)
hline!([0], color = :black, label = false, linestyle = :dash)
vline!([0], color = :black, label = false, linestyle = :dash)
