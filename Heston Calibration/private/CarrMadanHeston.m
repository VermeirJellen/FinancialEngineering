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
function [y] = CarrMadanHeston(K, T, S0, r, q, optionType,hestonParameters)

N=4096;gridSpace=0.25;alpha=1.5;
lambda=2*pi/N/gridSpace;
b=lambda*N/2;
k=[-b:lambda:b-lambda];
KK=exp(k);
v=[0:gridSpace:(N-1)*gridSpace];

rho=exp(-r*T)*HestonCharacteristic(v-(alpha+1)*1i,T,r,q,S0,hestonParameters)./(alpha^2+alpha-v.^2+1i*(2*alpha+1)*v);

sw=(3+(-1).^(1:1:N)); sw(1)=1; sw=sw/3;
A=real(fft(rho.*exp(-1i*v*b)*gridSpace.*sw,N));
price=(1/pi)*exp(-alpha*k).*A;

y=spline(KK,price,K);
y(optionType==1) = y(optionType==1) + K(optionType==1)*exp(-r*T)- exp(-q*T)*S0; 