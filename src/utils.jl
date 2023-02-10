using Measurements
function meanse(x) 
    x = x[.!isnan.(x)]
    return mean(x) ± std(x)/sqrt(length(x))
end
function medianse(x) 
    x = x[.!isnan.(x)]
    return median(x) ± 1.2533 * std(x)/sqrt(length(x))
end

nanmax(vector) = length(vector) > 0 ? maximum(vector) : NaN
nanmean(x) = mean(filter(!isnan,x))
nanstd(x) = std(filter!(!isnan, x))

using Statistics, Distributions
import Distributions:TDist
TDist(μ, σ, ν) = LocationScale(μ, σ*sqrt((ν - 2)/ν), Distributions.TDist(ν))

