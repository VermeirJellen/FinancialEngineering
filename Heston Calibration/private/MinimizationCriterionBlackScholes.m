function minimizationCriterionBlackScholes = MinimizationCriterionBlackScholes(sigmaCalibration,S0,K,r,q,T,optionType,marketPrice)

pricesBS = BS(sigmaCalibration,S0,K,r,q,T,optionType);
minimizationCriterionBlackScholes = sum((pricesBS-marketPrice).^2);