% BLSLOOKBACKIMPV - Perform calibration process for the Black-Scholes implied 
% volatility of exotic lookback options. The goal is to find the volatility value 
% that minimizes the error between the obtained option prices and the target prices.
% Minimization of the error functionis performed via the Nelder-Mead Simplex algorithm.
%
% [volatility] = blsLookbackImpv(targetPrice,S0,MinMax,Time,Rate)
% [volatility] = blsLookbackImpv(targetPrice,S0,MinMax,Time,Rate,Yield,Type,calibrateAll)
%
% Inputs:
%	targetPrice - The target price of the options. The target price might be 
%		the actual market value of the options. Alternatively, it might also be the
%		option values that were obtained via another option pricing model.
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
%	CalibrateAll - 
%		If true, then the global implied volatility will be computed. 
%		If false, then the implied volatility for each individual option 
%		will be computed separately (assuming that there are multiple 
%	    input options). Default value is true.
%
% Output:
%   Volatility - The implied volatility
%
% Example 1:
%   Consider a stock trading at 50$. 
%   The stock does not pay dividends. The price of a lookback option
%   with time until maturity half a year is 10.78. The minimum price observed so
%	far is 48$. The risk free rate is 5% per annum. 
%	The following command will compute the implied volatility of this option
% 
% 	volatility = blsLookbackImpv(10.78, 50, 48, 1.5, 0.05, 0, 0)
%
% Example 2:
%	Consider a more involved example where we compute both the global and 
% 	individual implied volatility's of 3 different call lookback
%	options and 3 put lookback options that each have distinct underlying assets. 
%	Assume that time to maturity is 0.5 years and interest rate is 0.1 for all options.
%	Option prices are given as defined below:
%	targetPrice = [13.9472 8.7086 11.9530; 15.8545 10.3374 5.9310];
%	S0 = [100 110 120; 100 110 120];
%	M = [95 105 120; 105 110 128];
%	q = [0 0.05 0.02; 0 0 0];
%	type = [0 0 0; 1 1 1];
%	volGlobal = blsLookbackImpv(targetPrice,S0,M,0.5,0.1,q,type,1);
%	volSeparate = blsLookbackImpv(targetPrice,S0,M,0.5,0.1,q,type,0);
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
% See also: BLSLOOKBACK, BLSLOOKBACKDELTA, BLSLOOKBACKGAMMA, BLSLOOKBACKVEGA, 
% BLSLOOKBACKTHETA, BLSLOOKBACKRHO, BLSLOOKBACKSQUAREDERRORS

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
function [impliedVolatility] = blsLookbackImpv(targetPrice,St,M,T,r,q,type,calibrateAll)

if(nargin < 5)
	error('Not enough input parameters. Type "help blsLookbackImpv" for more information');
end;
if(nargin < 6 || isempty(q))
	q=0;
end;
if(nargin < 7 || isempty(type))
	warning('No lookback type input argument: call option(s) by default!');
	type = 0;
end;
if(nargin < 8 || isempty(calibrateAll))
	calibrateAll = 1;
end;

optimizationSettings=optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',10000);

if(calibrateAll) % compute implied volatility over the whole dataset
	impliedVolatility = fminsearch(@(sigma)blsLookbackSumSquaredErrors(sigma,targetPrice,St,M,T,r,q,type),0.25,optimizationSettings);
else  %% compute implied volatility for each option separately
	maxRows = 1; maxColumns = 1;
	inputCell = {targetPrice,St,M,T,r,q,type};
	if(not(isempty(find(cellfun(@isscalar,inputCell)==0))))
		maxRows = max([cellfun(@(x) size(x,1),inputCell)]);
		maxColumns = max([cellfun(@(x) size(x,2),inputCell)]);
		
		% Convert scalars to vector / matrix of maxsize, if necessary
		logicalVector = find(cellfun(@isscalar,inputCell)==1);
		if not(isempty(logicalVector))
			inputCell(logicalVector) = cellfun(@(x) repmat(x,maxRows,maxColumns), inputCell(logicalVector),'uni',false);
			targetPrice = cell2mat(inputCell(1));
			St = cell2mat(inputCell(2));
			M = cell2mat(inputCell(3));
			T = cell2mat(inputCell(4));
			r = cell2mat(inputCell(5));
			q = cell2mat(inputCell(6));
			type = cell2mat(inputCell(7));
		end;
	end;
	maxSize = [maxRows, maxColumns];

	impliedVolatility = zeros(maxSize);
	for i=1:maxSize(1)
		for j=1:maxSize(2)
			impliedVolatility(i,j)= fminsearch(@(sigma)blsLookbackSumSquaredErrors(sigma,targetPrice(i,j),St(i,j),M(i,j),T(i,j),r(i,j),q(i,j),type(i,j)),0.25,optimizationSettings);
		end;
	end;
end;