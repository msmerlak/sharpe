using DrWatson; @quickactivate
include(srcdir("utils.jl"))

using Arrow, DataFramesMeta, StatsPlots
using Distributions
performance = Arrow.Table("../coinvestment/LDB/data/performance.arrow") |> DataFrame

returns = performance[:, [:account, :date, :return]]

isconsecutive(dates) = all(Dates.Day(28) .<= diff(dates) .<= Dates.Day(31))

@subset!(returns, .!ismissing.(:return))
@subset!(returns, .!isnan.(:return))
@subset!(returns, abs.(:return) .< 1.)


accounts = groupby(returns, :account)
@subset!(accounts, isconsecutive(:date))
@subset!(accounts, length(:date) .== 70)

@transform!(accounts, :sharpe = mean(:return)./std(:return))
@transform!(accounts, :compounding = compounding_return(:return))

retail = combine(accounts, :sharpe => first => :sharpe, :compounding => first => :compounding)
retail = filter(row -> all(x -> !(x isa Number && isnan(x)), row), retail)



retail_ρ = corspearman(retail.sharpe, retail.compounding)
retail_plot = @df retail scatter(
    sqrt(12) .*:sharpe, 
    (1 .+:compounding).^12 .- 1,
    title = "$(size(retail, 1)) retail investors (1991-1996)",
    legend = :bottomright,
    xlabel="Sharpe Ratio",
    alpha = 0.7,
    xlims = (-1, 2),
    ylims = (-1, 1),
    label = "Spearman ρ = $(round(retail_ρ; digits = 3))"
)
hline!([0], color = :black, label = false, linestyle = :dash)
vline!([0], color = :black, label = false, linestyle = :dash)
