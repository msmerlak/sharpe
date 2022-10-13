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
