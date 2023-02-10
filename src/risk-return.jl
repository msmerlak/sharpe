using StatsBase

function sharpe_ratio(log_returns)
    return mean(log_returns)/(std(log_returns) + 1e-10)
end

function sortino_ratio(log_returns)
    downside = log_returns[log_returns .< 0]
    return mean(log_returns)/(std(downside) + 1e-10)
end