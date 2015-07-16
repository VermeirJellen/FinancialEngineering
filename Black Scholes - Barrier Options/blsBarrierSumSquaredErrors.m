% BLSBARRIERSUMSQUAREDERRORS - Helper function that is utilized during 
% the calibration process of the Black-Scholes implied volatility computation 
% of barrier options.
% 
% This function first calculates the option prices that match a particular input
% volatility value. The function then returns the sum of squared errors between 
% the obtained prices and the target prices of the options.
% The target prices may be the actual market values of the options. 
% Alternatively, they may also be option values that were obtained
% via another option pricing model.
%
% sumSquaredError = blsBarrierSumSquaredError(sigmaCalibration,targetPrice,S0,Strike,Barrier,Rebate,Time,Rate,Yield)
%
% Inputs:
%   SigmaCalibration - Current guess for the implied volatility of the option.
%		This parameter can be calibrated externally in order to obtain an option
%		value that minimizes the sum of squared errors.
%
%	targetPrice - The target price of the option
%
%   S0 - Current stock price of the underlying asset
%
%   Strike - Strike (i.e, exercise) price of the option
%
%   Barrier - Barrier price of the option
%
%	Rebate - A fixed amount that will be paid at maturity when one
%		of the following conditions is met:
%		1 - The barrier is never breached during the lifetime of
%			an "in" barrier option.
%		2 - The barrier is breached during the lifetime of an "out"
%			Barrier option.
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
% Type - The barrier type for which the price will be
%   calculated. Possible input values are listed below.
%       'dobc' = down and out barrier call
%       'dibc' = down and in barrier call
%       'uobc' = up and out barrier call
%       'uibc' = up and in barrier call
%       'dobp' = down and out barrier put
%       'dibp' = down and in barrier put
%       'uobp' = up and out barrier put
%       'uibp' = up and in barrier put
%   The default value is dobc
%
% Output:
%   sumSquaredError - The sum of squared errors between the obtained option
%		price and the target option price.
%
% Example 1:
%   Consider a stock trading at 50$.
%   The stock does not pay dividends. We would like to price a DOBC option
%   with time until maturity of 1.5 years.
%   The strike price of the option is 55$, the barrier level is placed 
%   at 40$ and the rebate is 2$. The risk free rate is 5% per annum. 
% 	The OTC price of this option is 4.9$. If we guess that the implied volatility
%	for this option is 15% then the following command will output the
%	sum of squared errors between the obtained price and the target price:
% 
% 	error = blsBarrierSumSquaredError(0.15,4.9,50,55,40,2,1.5,0.05,0,'dobc')
%
% Example 2:
%	Consider a more involved example where we price 9 different "in" type
%	barrier call options with different strikes and barriers. 
%	All other parameters remain the same for all options:
% 	Our "guess" for the implied volatility is 15%. We can obtain the error
% 	value as follows:
%	S0 = 100;
%	target = [13.3 8.7 5.49; 17.825 12.23 8.02; 17.91 12.3744 8.1622];
%	K = [90 100 110; 90 100 110; 90 100 110];
%	B = [97 97 97; 100 100 100; 103 103 103];
%	T = 1.50;
%	R = 2;
%	r = 0.10;
%	q = 0.05;
%	type = {'dibc','dibc','dibc'; 'dibc','dibc','dibc';'uibc','uibc','uibc'};
%	error = blsBarrierSumSquaredError(0.15,target,S0,K,B,R,T,r,q,type);
%	
% Notes:
% (1) The input arguments targetPrice, S0, Strike, Barrier, Rebate, Time, Rate and Yield
%     may be scalars, vectors or matrices. The input argument Type may be
%	  a string or an array of strings. If scalars or string then the relevant
%     value is used during the computations of all options. If more than
%     one of these inputs is a vector, matrix or cell array, then the dimensions 
%	  of all non-scalars (and the potential cell array) must be the same.
% (2) Ensure that Rate, Time and Yield are expressed in consistent units of
%     time.
% (3) Ensure that the barrier options are not already "in" or "out" at inception:
%	  For down and in and down and out options the initial price
%     of the underlying should be higher than the barrier (S0 > B)
%	  For up and in and up and out options the initial price of the underlying
%	  should be less than the barrier (S0 < B)
%
%	Copyright 2015 Jellen Vermeir 
%	jellenvermeir@gmail.com	
%
% See also: BLSBARRIERIMPV

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
function sumSquaredError = blsBarrierSumSquaredError(sigmaCalibration,targetPrice,St,K,B,R,T,r,q,type)

if(nargin < 8)
	error('Not enough input parameters. Type "help blsBarrierSumSquaredErrors" for more information');
end
if(nargin < 9 || isempty(q))
	q=0;
end
if(nargin < 10 || isempty(type))
	warning('No barrier type input argument: Pricing dobc option(s) by default!');
	type = 'dobc';
end
barrierTypes = {'dibc','dobc','uibc','uobc','dibp','dobp','uibp','uobp'};
if(not(isempty(find(ismember(char(type),barrierTypes)==0))))
	error('Unknown option type input argument detected: Type "help blsBarrierSumSquaredErrors" for more information');
end;

calibratedPrice = blsBarrier(sigmaCalibration,St,K,B,R,T,r,q,type);
sumSquaredError = sum(sum((calibratedPrice-targetPrice).^2));