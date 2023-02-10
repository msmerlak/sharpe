# Not So Sharpe

Matteo Smerlak, Oct. 13th 2022

---

How bad would it be if one of the most commonly used measure of portfolio performance was not actually correlated with portfolio performance? 

That measure is the Sharpe ratio: the average excess returns of some portfolio (with respect to a riskfree asset, e.g. cash or short-term government bonds) divided by the standard deviation of these returns. Its interpretation is seemingly clear: if the same average returns can be achieved with lower volatility, the Sharpe ratio will be higher, and this will signal more consistent performance. 

All readers of this paper know that past returns do not predict future performance. This applies in particular to the Sharpe ratio, and so, if something has a Sharpe Ratio of 8.38, you should definitely not [sell your grandmother down the river and buy it](https://www.ft.com/content/08a2c6b6-0965-32b3-b016-cdaa736e8d09). The fact that strong, predictable returns do not tend to persist indefinitely is the reason why fund managers and quants are constantly thinking up new strategies. 

But this is not my point here. I am saying that a higher historical Sharpe ratio does not imply a stronger historical performance. In fact, the best investments in the long run tend to have mediocre Sharpe ratios, at odds with the standard practice of advertising funds on the basis for their Sharpe ratios.  

Two large datasets make this clear. The first consists of the annual returns of ~4,000 US mutual funds and ETFs in continued existence between 2000-2020 [scraped from Yahoo Finance](https://www.kaggle.com/datasets/stefanoleone992/mutual-funds-and-etfs); the second involves the monthly profits (and losses) of ~10,000 retail customers of a large brokerage from the mid-nineties, the so-called [LDB dataset](https://onlinelibrary.wiley.com/doi/abs/10.1111/0022-1082.00226). In both cases, the best performing portfolios had subpar Sharpe ratios of 1 or less; conversely, the portfolios with the largest Sharpe ratios provided meager annualized returns of 5% or less. In fact, in the case of funds, the Sharpe ratio provides no information about performance whatsoever: its (Spearman) correlation coefficient with annualized returns is -0.03. 

Why Sharpe's ratio fails so completely at characterizing the long-term performance of portfolios is not mysterious. Two facts explain it. First, large fluctuations ("black swans") are relatively common, a. Second, returns don't add up---they multiply. Computing the mean and standard deviation of returns, as in Sharpe's ratio, misses this point completely. 


















Of course, the Sharpe ratio is not the only performance indicator, and it would be inconsiderate to base major investment decisions on a single number anyway. Nevertheless, the Sharpe ratio has been a key selling point for funds and assets managers for decades. Perhaps it is time to acknowledge that Sharpe's ratio isn't sharp enough for this purpose after all. 

The code for these analyses is freely available [here](https://www.github.com/msmerlak/sharpe). 

![image](../plots/sharpe-funds-retail.png)


