function minimizationCriterionHeston = MinimizationCriterionHeston(paramsCalibration,K,T,S0,r,q,optionType,CarrMadanPrecomputed,optionMidMarket,weights)

kappa = (paramsCalibration(1)+paramsCalibration(3)^2)/(2*paramsCalibration(2)); % extract kappa from fellerCondition
pricesHeston = HestonPricer([kappa, paramsCalibration(2:5)],K,T,S0,r,q,optionType,CarrMadanPrecomputed); % Run HestonPricer with precomputation support
% pricesHeston = HestonPricerWithoutPrecomputation([kappa, paramsCalibration(2:5)],K,T,S0,r,q,optionType); % Run HestonPricer without precomputation support

minimizationCriterionHeston = sum(weights.*((pricesHeston-optionMidMarket).^2));