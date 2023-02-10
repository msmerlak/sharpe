using DrWatson
@quickactivate

#include(srcdir("utils.jl"))

using CSV, DataFramesMeta
using StatsPlots
using Distributions
using Dates

## US funds (https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs)

funds_data = CSV.read(
    datadir("kaggle-funds", "MutualFunds.csv"), DataFrame
    )
rates_data = CSV.read(datadir("RIFLGFCY01NA.csv"), DataFrame)
riskfree = rates_data[39:59, 2]/100

years = 2000:2020

for t in 0:20
    year = 2000 + t
    funds_data[:, "excess_return_" * string(year)] = funds_data[:, "fund_return_" * string(year)] .- riskfree[t + 1]
    funds_data[:, "excess_log_return_" * string(year)] = log.(funds_data[:, "excess_return_" * string(year)] .+ 1)
end

R = ["excess_log_return_" * year for year in string.(years)]
complete = completecases(funds_data[:, R])
data = funds_data[complete, :]

scatter(
    mean.(eachrow(X)),
    mean.(eachrow(X))./std.(eachrow(X))
)

grouped = groupby(data, :fund_category)
sizes = [size(group, 1) for group in grouped]
grouped = grouped[reverse(sortperm(sizes))]

m_range = range(0, .1, length = 50)

begin
    mean_variance = plot(legend = :outertopright, size = (700, 300))
    mean_sharpe = plot(legend = :outertopright, size = (700, 300))
    conditional_sharpe = plot(legend = :outertopright, size = (700, 300))

    for group in grouped[1:5]

        name = group[1, :fund_category]
        M = mean.(eachrow(group[:, R]))
        S = std.(eachrow(group[:, R]))

        scatter!(
            mean_variance, 
            M,
            S,
            markers = :auto,
            label = false,#name,
            xlabel = "m",
            ylabel = "s"
        )
        scatter!(
            mean_sharpe,
            M, 
            M./S,
            label = false,
            markers = :auto
        )

        scatter!(
            conditional_sharpe,
            m_range,
            map(r -> meanse(S[M .> r]), m_range),
            label = false
        )

    end
    
    plot(mean_variance, mean_sharpe, conditional_sharpe, 
    layout = (3, 1), size = (700, 600), dpi = 500)
end


savefig(plotsdir("funds-by-category"))

# Riskfree rate
IRX = CSV.read(datadir("^IRX.csv"), DataFrame)
@transform!(IRX, :Year = Year.(:Date))
Rf = combine(groupby(IRX, :Year), :Close => mean => :IRX).IRX/100

funds_excess = copy(funds)
for row in eachrow(funds_excess)
    row .= collect(row) .- Rf
end
