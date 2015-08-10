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
function calibratedHestonParameters = HestonCalibrationLocalOptimization(initialGuessHeston,K,T,S0,r,q,optionType,carrMadanPrecomputed,optionMidMarket,weightsOptimization,earlyStopping,maxEval)

kappa=initialGuessHeston(1); eta=initialGuessHeston(2); theta=initialGuessHeston(3);
fellerConstraint=2*kappa*eta-theta^2; % Avoid negative variance: Value must be greater than or equal to zero.
initialGuessFeller = [fellerConstraint initialGuessHeston(2:5)];

lowerBound = [0 0 0 -1 0]; upperBound = [20 1 5 0 1];
if(earlyStopping) % use StopFunction
	optimizationSettings = optimset('OutputFcn',@StopFunction,'TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',10000);
else % do not use StopFunction
	if nargin < 12
		maxEval=10000; % Full Convergence
	end
	optimizationSettings = optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',maxEval);
end;

[calibratedParams,fval,exitflag,output] = fminsearchbnd(@(paramsToCalibrate) MinimizationCriterionHeston(paramsToCalibrate,K,T,S0,r,q,optionType,carrMadanPrecomputed,optionMidMarket,weightsOptimization),initialGuessFeller,lowerBound,upperBound,optimizationSettings);
calibratedParams(1) = (calibratedParams(1)+calibratedParams(3)^2)/(2*calibratedParams(2)); % extract kappa from fellerConstraint

calibratedHestonParameters = calibratedParams;