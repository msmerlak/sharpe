using DrWatson; @quickactivate
using Distributions, HawkesProcesses
using Plots

bg = 2
kappa = 0.5
kernel(x) = pdf.(Distributions.Exponential(.1), x)
maxT = 100
simevents = HawkesProcesses.simulate(bg, kappa, kernel, maxT)
plot(simevents)