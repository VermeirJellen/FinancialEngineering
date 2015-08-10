%	Copyright 2015 Jellen Vermeir 
%	jellenvermeir@gmail.com	

% This file is part of the Financial Engineering Toolkit
%
% Financial Engineering Toolkit is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% at your option) any later version.
%
% Financial Engineering Toolkit is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with Financial Engineering Toolkit.  If not, see <http://www.gnu.org/licenses/>.
function minimizationCriterionHeston = MinimizationCriterionHeston(paramsCalibration,K,T,S0,r,q,optionType,CarrMadanPrecomputed,optionMidMarket,weights)

kappa = (paramsCalibration(1)+paramsCalibration(3)^2)/(2*paramsCalibration(2)); % extract kappa from fellerCondition
pricesHeston = HestonPricer([kappa, paramsCalibration(2:5)],K,T,S0,r,q,optionType,CarrMadanPrecomputed); % Run HestonPricer with precomputation support
% pricesHeston = HestonPricerWithoutPrecomputation([kappa, paramsCalibration(2:5)],K,T,S0,r,q,optionType); % Run HestonPricer without precomputation support

minimizationCriterionHeston = sum(weights.*((pricesHeston-optionMidMarket).^2));