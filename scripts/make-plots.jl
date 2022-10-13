using DrWatson; @quickactivate
include(scriptsdir("retail.jl"))
include(scriptsdir("funds.jl"))

### Retail investors

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

### Funds

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

plot(funds_plot, retail_plot, size = (1000, 500), dpi = 500,
left_margin=5Plots.mm, bottom_margin=5Plots.mm
)
savefig(plotsdir("sharpe-funds-retail"))