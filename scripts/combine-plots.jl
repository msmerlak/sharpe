using DrWatson; @quickactivate
include(scriptsdir("retail.jl"))
include(scriptsdir("funds.jl"))

plot(funds_plot, retail_plot, size = (1000, 500), dpi = 500,
left_margin=5Plots.mm, bottom_margin=5Plots.mm
)
savefig(plotsdir("sharpe-funds-retail"))