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
function out = HestonPricer(hestonParameters,K,T,S0,r,q,optionType,carrMadanPrecomputed)

if nargin < 8
	N=4096; alpha=1.5; gridSpace=0.25; simpsonIntegrand=1;
	carrMadanPrecomputed = PrecomputationCarrMadanParameters(N,alpha,gridSpace,simpsonIntegrand);
end			
characteristicFunctionPrecomputed = PrecomputationHestonCharacteristicFunctionParameters(hestonParameters,carrMadanPrecomputed.u,S0);
			
timeStamps = unique(T);
results = zeros(1,length(T));

% Iterate over the unique timeStamps. Process all options for identical timestamps simultaneously
for(i=1:length(timeStamps))
	logicalVector = (T==timeStamps(i));
	KK = K(logicalVector);
	optionTypeCm = optionType(logicalVector);
	
	first=find(logicalVector,1);
	tCm=T(first);
	rCm=r(first);

	results(logicalVector) = CarrMadanHestonOptimized(KK,tCm,S0,rCm,q,optionTypeCm,carrMadanPrecomputed,characteristicFunctionPrecomputed);
end

out=results;