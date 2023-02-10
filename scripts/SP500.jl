using MarketData

returns(P) = values(P)[2:end] ./ values(P)[1:end-1] .- 1
log_returns(P) = log.(values(P)[2:end] ./ values(P)[1:end-1])
X = log_returns(P)

begin
    mean_sharpe = plot()
    conditional_sharpe = plot()

    all_means = []
    all_sharpes = []

    for symbol in ("EMM", "IEMG", "^FCHI", "TSLA")
        P = yahoo(symbol, YahooOpt(interval="1mo")).AdjClose

        years = unique(year.(timestamp(P)))
        samples = log_returns.(to(from(P, Date(y)), Date(y + 1)) for y in years)
        #samples = samples[length.(samples).==maximum(length(samples))]

        m = mean.(samples)
        s = sqrt(12) * mean.(samples) ./ std.(samples)
        push!(all_sharpes, s)
        push!(all_means, m)

        scatter!(mean_sharpe,
            m, s, markers=:auto, label=symbol, legend=:topleft)
    end
    plot(mean_sharpe)
end


all_sharpes = vcat(all_sharpes...)
all_means = vcat(all_means...)
m_range = range(-0.05, 0.1; length=20)

cond_sharpe = map(r -> meanse(all_sharpes[all_means.>= r]), m_range)

scatter(m_range,
            cond_sharpe,
            label=false
)

histogram(all_means)