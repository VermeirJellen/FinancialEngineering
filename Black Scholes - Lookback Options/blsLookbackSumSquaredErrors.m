% BLSLOOKBACKSUMSQUAREDERRORS - Helper function that is utilized during 
% the calibration process of the Black-Scholes implied volatility computation 
% of lookback options.
% 
% This function first calculates the option prices that match a particular input
% volatility value. The function then returns the sum of squared errors between 
% the obtained prices and the target prices of the options.
% The target prices may be the actual market values of the options. 
% Alternatively, they may also be optionvalues that were obtained
% via another option pricing model.
%
% sumSquaredError = blsLookbackSumSquaredError(sigmaCalibration,targetPrice,S0,MinMax,Time,Rate,Yield,Type)
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
%   sumSquaredError - The sum of squared errors between the obtained option
%		price and the target option price.
%
% Example 1:
%   Consider a stock trading at 50$. 
%   The stock does not pay dividends. The price of a lookback option
%   with time until maturity half a year is 10.78. The minimum price observed so
%	far is 48$. The risk free rate is 5% per annum. 
%	The following command will compute the implied volatility of this option
% 	If we guess that the implied volatility
%	for this option is 15% then the following command will output the
%	sum of squared errors between the obtained price and the target price:
% 
% 	error = blsLookbackSumSquaredErrors(0.15, 10.78,50, 48, 1.5, 0.05, 0, 0)
%
% Example 2:
%	Consider a more involved example where we know the prices of
%	3 different call lookback options and 3 put lookback options that each have distinct 
%	underlying assets. 
%	Assume that time to maturity is 0.5 years and interest rate is 0.1 for all options.
%	If we guess that the implied volatility for the options is 15% then the following 
%	command will output the sum of squared errors between the obtained prices and 
%	the target prices:
%	targetPrice = [13.9472 8.7086 11.9530; 15.8545 10.3374 5.9310];
%	S0 = [100 110 120; 100 110 120];
%	M = [95 105 120; 105 110 128];
%	q = [0 0.05 0.02; 0 0 0];
%	type = [0 0 0; 1 1 1];
%	error = blsLookbackSumSquaredErrors(0.15,targetPrice,S0,M,0.5,0.1,q,type);
%	
% Notes:
% (1) The input arguments targetPrice, St, MinMax, Time, Rate and Yield
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
% See also: BLSLOOKBACKIMPV
function sumSquaredError = blsLookbackSumSquaredErrors(sigmaCalibration,targetPrice,St,M,T,r,q,type)

if(nargin < 6)
	error('Not enough input parameters. Type "help blsLookbackSumSquaredErrors" for more information');
end
if(nargin < 7 || isempty(q))
	q=0;
end
if(nargin < 8 || isempty(type))
	warning('No lookback type input argument: Pricing call option(s) by default!');
	type = 0;
end

calibratedPrice = blsLookback(sigmaCalibration,St,M,T,r,q,type);
sumSquaredError = sum(sum((calibratedPrice-targetPrice).^2));