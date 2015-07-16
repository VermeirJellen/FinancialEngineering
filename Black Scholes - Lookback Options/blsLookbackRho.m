% BLSLOOKBACKRHO - Compute the Rho for exotic lookback options 
% under the Black-Scholes model. 
% 
% Computation is done via forward finite difference approximation
% for the first derivative of the option price with respect 
% to interest rate change
%
% [Rho] = blsLookbackRho(sigma,St,MinMax,Time,Rate)
% [Rho] = blsLookbackRho(sigma,St,MinMax,Time,Rate,Yield,Type)
%
% Inputs:
%   Sigma - Black Scholes volatility of the underlying asset
%
%   S0 - Current stock price of the underlying asset
%
%   MinMax - For a call, the current minimum price that the
%		underlying asset has experienced so far during the lifetime
%		of the option (M <= St). For a put, the current maximum
%		price that the asset has experienced so far (M >= St)
%
%   Time - Time to expiration of the option, expressed in years
%
%   Rate - Annualized continuously compounded risk-free rate of return over
%       the life of the option, expressed as a positive decimal number.
% 
% Optional Inputs:
%   Yield - Annualized continuously compounded yield of the underlying asset
%     over the life of the option, expressed as a decimal number. For example,
%     this could represent the dividend yield and foreign risk-free interest
%     rate for options written on stock indices and currencies, respectively.
%     If empty or missing, the default is zero.
%
% 	Type - 0 for call, 1 for put. Default is 0.
%
% Output:
%   Rho - Black scholes sensitivity to interest rate change
%
% Example 1:
%   Consider a stock trading at 50$ with a Black-Scholes volatility of 20%. 
%   The stock does not pay dividends. We would like to price a call lookback option
%   with time until maturity half a year. The minimum price observed so
%	far is 48$. The risk free rate is 5% per annum. 
%	The following command will return the Rho of this lookback option:
% 
% 	Rho = blsLookbackRho(0.20, 50, 48, 1.5, 0.05, 0, 0)
%
% Example 2:
%	Consider a more involved example where we price 3 different call lookback
%	options and 3 put lookback options that each have distinct underlying assets. 
%	Assume that time to maturity is 0.5 years and interest rate is 0.1 for all options.
%	The Rho's can be obtained by giving vectors or matrices as input. For example:
%	S0 = [100 110 120; 100 110 120];
%	M = [95 105 120; 105 110 128];
%	sigma = [0.2 0.1 0.15; 0.30 0.20 0.10];
%	q = [0 0.05 0.02; 0 0 0];
%	type = [0 0 0; 1 1 1];
%	Rhos = blsLookbackRho(sigma,S0,M,0.5,0.1,q,type);
%	
% Notes:
% (1) The input arguments sigma, St, MinMax, Time, Rate and Yield
%     may be scalars, vectors or matrices. If scalars then the relevant
%     value is used during the computations of all options. If more than
%     one of these inputs is a vector or matrix then the dimensions 
%	  of all non-scalars must be the same.
% (2) Ensure that Rate, Time and Yield are expressed in consistent units of
%     time.
% (3) Ensure that MinMax <= St when pricing call lookback options and 
%	  MinMax >= St when pricing put lookback options.
%
%	Copyright 2015 Jellen Vermeir 
%	jellenvermeir@gmail.com	
%
% See also: BLSLOOKBACK, BLSLOOKBACKDELTA, BLSLOOKBACKGAMMA, BLSLOOKBACKVEGA,
% BLSLOOKBACKTHETA, BLSLOOKBACKIMPV

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
function [Rho] = blsLookbackRho(sigma,St,M,T,r,q,type)
if(nargin < 5)
	error('Not enough input parameters. Type "help blsLookbackRho" for more information');
end;
if(nargin < 6 || isempty(q))
	q=0;
end;
if(nargin < 7 || isempty(type))
	warning('No lookback type input argument: Pricing call lookback option(s) by default!');
	type = 0;
end;
if(not(isempty(find(ismember(type,[0 1])==0))))
	error('Unknown option type input argument detected: Type "help blsLookbackRho" for more information');
end;

dR = 0.0001;
Rho = (blsLookback(sigma,St,M,T,r+dR,q,type) - blsLookback(sigma,St,M,T,r,q,type))./(dR);