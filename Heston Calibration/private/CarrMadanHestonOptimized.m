% Perform carr madan for the options that mature at timestamp T
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
function [y] = CarrMadanHestonOptimized(K,T,S0,r,q,type,cmPrecomputed,charPrecomputed)

rho = exp(-r.*T).*HestonCharacteristicOptimized(cmPrecomputed.u,T,r,q,charPrecomputed)./cmPrecomputed.rhoDenominator;  
a = real(fft(rho.*cmPrecomputed.fftMultiplier, cmPrecomputed.N));
CallPrices = (1/pi)*exp(-cmPrecomputed.alpha*cmPrecomputed.k).*a;       

y = spline(cmPrecomputed.realStrikes,CallPrices,K);
y(type==1) = y(type==1) + K(type==1)*exp(-r*T)- exp(-q*T)*S0; 