using Plots
using Distributions

normal = Normal(.01, .02)
cauchy = Cauchy(.01, .02)

p1 = plot()
for dist ∈ (normal, cauchy)
    a = Float64[]
    s = Float64[]
    for _ in 1:1000
        r = rand(dist, 10)
        r = r[abs.(r) .< 1]
        push!(a, compounding_return(r))
        push!(s, sharpe_ratio(r))
    end
    scatter!(s, a, xlabel="Sharpe Ratio", ylabel="Annualized Return", legend=:bottomright, alpha = 0.5, label = "ρ = $(corspearman(s, a))")
end


p2 = plot(normal, xlabel = "Returns",  xlims = (-.1, .1), label = "Normal returns")
plot!(x -> pdf(cauchy, x), label = "Long-tailed returns")

plot(p2, p1)