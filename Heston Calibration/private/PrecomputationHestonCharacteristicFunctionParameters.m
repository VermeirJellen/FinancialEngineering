% Precompute characteristic function related variables that are independent of a particular maturity
% These parameters can be precomputed only 1 time when pricing sets of time dependent options, for performance reasons.
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
function characteristicFunctionPrecomputedVariables = PrecomputationHestonCharacteristicFunctionParameters(hestonParameters,u,S0);

kappa=hestonParameters(1);
theta=hestonParameters(3);

param1 = kappa-hestonParameters(4)*theta*u*1i; d = sqrt(param1.^2 - theta^2*(-1i*u-u.^2));
param2 = param1-d;
g = param2./(param1+d);
param3 = kappa*hestonParameters(2)/(theta^2);
param4 = hestonParameters(5)^2/theta^2;

characteristicFunctionPrecomputedVariables = struct('x0',log(S0), ...
													'd',d, ...
													'g',g, ...
													'param2',param2, ...
													'param3',param3, ...
													'param4',param4);