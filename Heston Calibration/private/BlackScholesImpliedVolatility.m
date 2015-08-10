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
function [impliedVolatility] = BlackScholesImpliedVolatility(S0,K,r,q,T,optionType,price,calibrateAllData)

optimizationSettings=optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',10000);

if(calibrateAllData) % find implied volatility over the whole dataset
	impliedVolatility = fminsearch(@(sigma)MinimizationCriterionBlackScholes(sigma,S0,K,r,q,T,optionType,price),0.5,optimizationSettings);
else  %% find the implied volatility for each option
	impliedVolatility = zeros(1,length(T));
	for i=1:length(T)
		impliedVolatility(1,i)= fminsearch(@(sigma)MinimizationCriterionBlackScholes(sigma,S0,K(i),r(i),q,T(i),optionType(i),price(i)),0.5,optimizationSettings);
		% impliedVolatilityBuiltIn(1,i) = blsimpv(S0,K(i),r(i),T(i),abs(price(i)),[],q,[],not(optionType(i)));
	end;
end;