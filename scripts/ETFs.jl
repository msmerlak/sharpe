using DrWatson
@quickactivate

include(srcdir("utils.jl"))

using CSV, DataFramesMeta
using Dates
using Statistics, StatsBase


logreturns(prices) = [NaN, log.(prices[2:end]./prices[1:end-1])...]

riskfree_data = CSV.read(datadir("RIFLGFCY01NA.csv"), DataFrame)

riskfree = riskfree = Dict(
    Year(row.DATE) => log(1 + row.RIFLGFCY01NA/100)
    for row in eachrow(riskfree_data)
        )

ETF_metadata = CSV.read(datadir("kaggle-funds/ETFs.csv"), DataFrame)
ETF_data = CSV.read(datadir("kaggle-funds/ETF-prices.csv"), DataFrame)


ETF_returns = @chain innerjoin(ETF_data, ETF_metadata, on = :fund_symbol) begin
    @transform(:year = Year.(:price_date))
    @by([:fund_category, :fund_symbol, :year], 
        :x = logreturns(:adj_close) .- log(1 + riskfree[first(:year)])/length(:year),
        :T = length(:adj_close),
        :year, 
        :fund_category
    )
    @subset(:T .== 252)
    @subset(-Inf .< :x .< Inf)
    #@subset(:fund_category .!== missing)
end

ETF = @chain ETF_returns begin
    @by([:fund_category, :fund_symbol, :year],
    :m = nanmean(:x), 
    :s = nanstd(:x),
    :sharpe = sqrt(length(:year)) .* nanmean(:x) ./ nanstd(:x),
    :sortino = sqrt(length(:year)) .* nanmean(:x) ./ downside_std(:x)
    )
end