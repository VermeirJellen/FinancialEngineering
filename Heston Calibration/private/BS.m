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
function priceBS = BS(sigma, S0, K, r, q, T, flag) 

d_1 = (log(S0./K)+(r - q +sigma.^2./2).*T)./(sigma.*sqrt(T));
d_2 = d_1 - sigma.*sqrt(T);
priceBS = exp(-q.*T)*S0.*normcdf(d_1)-K.*exp(-r.*T).*normcdf(d_2);
priceBS(flag==1)=priceBS(flag==1)+K(flag==1).*exp(-r(flag==1).*T(flag==1))-S0.*exp(-q.*T(flag==1));
