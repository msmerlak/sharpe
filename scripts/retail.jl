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

cauchy_fit = fit(Cauchy, convert(Vector{Float64}, returns.return))
histogram(returns.return, normed = true, label = "Monthly returns", seriestype = :stephist, xlims = (-.4, .4))
plot!(x->pdf(cauchy_fit, x), xlims = (-.4, .4), label = "Cauchy fit")

accounts = groupby(returns, :account)
@subset!(accounts, isconsecutive(:date))
@subset!(accounts, length(:date) .== 70)

@transform!(accounts, :sharpe = mean(:return)./std(:return))
@transform!(accounts, :compounding = compounding_return(:return))

retail = combine(accounts, :sharpe => first => :sharpe, :annualized => first => :compounding)
retail = filter(row -> all(x -> !(x isa Number && isnan(x)), row), retail)


ρ = corspearman(retail.sharpe, retail.compounding)
retail_plot = @df retail scatter(
    sqrt(12) .*:sharpe, 
    (1 .+:compounding).^12 .- 1, 
    xlims = (-1, 3),
    ylims = (-1.5, 1),
    
    ylabel="Compounding Annualized Return", xlabel="Sharpe Ratio", legend=false)
hline!([0], color = :black, label = false)
vline!([0], color = :black, label = false)
savefig(plotsdir("sharpe-retail"))

