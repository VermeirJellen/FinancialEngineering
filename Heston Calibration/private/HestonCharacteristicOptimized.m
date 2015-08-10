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
function [y] = HestonCharacteristicOptimed(u,t,r,q,p)
% p = struct('x0',log(S0),'d',d,'g',g,'param2',param2,'param3',param3,'param4',param4);

p1 = exp(-p.d.*t); % evaluate exp(-dt) only one time
p2 = 1-p.g.*p1;

A = 1i*u*(p.x0+(r-q).*t);
B = p.param3*(p.param2.*t-2*log(p2./(1-p.g)));
C = p.param4*p.param2.*(1-p1)./p2;
y = exp(A+B+C);

end