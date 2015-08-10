install.packages('quantmod')
install.packages('XML')
library('quantmod')

Symbol = "XLB"
exp=c("2015-05-22",
      "2015-05-29",
      "2015-06-05",
      "2015-06-12",
      "2015-06-19",
      "2015-06-26",
      "2015-09-18",
      "2015-12-18",
      "2016-01-15",
      "2017-01-20");

XLB <- getOptionChain("XLB",Exp=exp);

dates = lapply(exp,strptime,format="%Y-%m-%d")
daysToMaturity = ceiling(do.call("rbind",lapply(dates,"difftime",as.POSIXlt(Sys.time()),units="days")))


l = list(10)
for(i in 1:length(XLB))
{
  options = XLB[[i]]
  calls = options$calls
  puts = options$puts
  
  strikes = c(calls$Strike, puts$Strike);
  bid = c(calls$Bid, puts$Bid);
  ask = c(calls$Ask, puts$Ask);
  midPrice = (bid+ask)/2
  spread = (ask-bid);
  optionType = c(rep(0,nrow(calls)), rep(1,nrow(puts)));
  maturity = rep(daysToMaturity[i],nrow(calls)+nrow(puts))
  
  l[[i]] = data.frame(Time=maturity,Strike=strikes,CPFlag=optionType,midMarket=midPrice,bid=bid,ask=ask,spread=spread)
}

data = do.call("rbind",l)
write.csv(data, file = "MyDataFull.csv")

nrSamples = dim(data)[1];
randomOutOfSample = sample(1:nrSamples,ceiling(nrSamples*0.2))
outOfSample = data[randomOutOfSample,]
inSample = data[-randomOutOfSample,]

write.csv(inSample, file="inSampleData.csv")
write.csv(outOfSample, file="outOfSampleData.csv")
