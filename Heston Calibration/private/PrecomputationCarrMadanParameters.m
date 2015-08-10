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
function output = PrecomputationCarrMadanParameters(N,alpha,gridSpace,simpsonIntegrand)

lambda=2*pi/N/gridSpace;
b=lambda*N/2;
k=[-b:lambda:b-lambda];
v = [0:gridSpace:(N-1)*gridSpace];
u = v-(alpha+1)*1i;

% Following (sub)parameters are used in the calculation of the carr madan formula.
% They are independent of the actual (heston) model parameters. Hence, they can be precomputed one time for performance purposes.
rhoDenominator = alpha^2+alpha-v.^2+1i*(2*alpha+1)*v;
fftMultiplier = exp(1i*v*b).*gridSpace;
realStrikes = exp(k);
if(simpsonIntegrand==1)
	simpson_1 = (1/3); 
	simpson = ((3 + (-1).^(2:1:N))/3); simpson = [simpson_1 simpson];
	fftMultiplier = fftMultiplier.*simpson;
end;

CarrMadanPrecomputed = struct('N',N, ...
					'alpha',alpha, ...
					'gridSpace',gridSpace, ...
					'lambda',lambda, ...
					'b',b, ...
					'k',k, ...
					'v',v, ...
					'u',u, ...
					'rhoDenominator',rhoDenominator, ...
					'fftMultiplier',fftMultiplier, ...
					'realStrikes',realStrikes ...
					);
					
output=CarrMadanPrecomputed;