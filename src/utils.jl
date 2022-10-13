using StatsBase

function sharpe_ratio(returns; log_returns = true)
    if log_returns 
        returns = log.(1 .+ collect(returns))
    else
        returns = collect(returns)
    end
    return mean(returns)/(std(returns) + 1e-10)
end

compounding_return(returns) = StatsBase.geomean(1 .+ collect(returns)) - 1
