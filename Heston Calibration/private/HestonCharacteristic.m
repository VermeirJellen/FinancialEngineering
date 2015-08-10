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
function [y] = HestonCharacteristic(u,t,r,q,S0,hestonParameters)

kappa=hestonParameters(1);
eta=hestonParameters(2);
theta=hestonParameters(3);
corr=hestonParameters(4);
sig=hestonParameters(5);

d=((corr*theta*u*1i-kappa).^2-theta^2*(-1i.*u-u.^2)).^(1/2);
g=(kappa-corr*theta*u*1i-d)./(kappa-corr*theta*u*1i+d);
y=exp(1i.*u.*(log(S0)+(r-q).*t)).*exp(eta.*kappa.*theta^(-2).*((kappa-corr*theta*u*1i-d).*t-2*log((1-g.*exp(-d*t))./(1-g)))).*exp(sig^2*theta^(-2)*(kappa-corr*theta*u*1i-d).*(1-exp(-d.*t))./(1-g.*exp(-d.*t)));