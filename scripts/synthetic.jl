ramp(x) = x > 0 ? x : 1e-10


normal = Normal(.01, .02)
cauchy = Cauchy(.01, .02)
plot()
for dist ∈ (normal, cauchy)
    a = Float64[]
    s = Float64[]
    for _ in 1:1000
        r = rand(dist, 10)
        r = r[abs.(r) .< 1]
        push!(a, compounding_return(r))
        push!(s, sharpe_ratio(r))
    end
    scatter!(s, a, xlabel="Sharpe Ratio", ylabel="Annualized Return", legend=:bottomright, alpha = 0.5, label = "$(corspearman(s, a))")
end
current()

plot(normal, xlims = (-.1, .1), label = "Normal returns")
plot!(x -> pdf(cauchy, x), label = "Long-tailed returns")

ρ = corspearman(a, s)

scatter(s, a, xlabel="Sharpe Ratio", ylabel="Annualized Return", legend=false)
hline!([0], color = :black, label = false)
vline!([0], color = :black, label = false)