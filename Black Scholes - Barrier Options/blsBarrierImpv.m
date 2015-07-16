% BLSBARRIERIMPV - Perform calibration process for the Black-Scholes implied 
% volatility of exotic barrier options. The goal is to find the volatility value 
% that minimizes the error between the obtained option prices and the target prices.
% Minimization of the error function is performed via the Nelder-Mead Simplex algorithm.
%
% [volatility] = blsBarrierImpv(targetPrice,S0,Strike,Barrier,Rebate,Time,Rate)
% [volatility] = blsBarrierImpv(targetPrice,S0,Strike,Barrier,Rebate,Time,Rate,Yield,Type,calibrateAll)
%
% Inputs:
%	targetPrice - The target price of the options. The target price might be 
%		the actual market value of the options. Alternatively, it might also be 
%		the option values that were obtained via another option pricing model.
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
% 	Type - The barrier type for which the price will be
%   	calculated. Possible input values are listed below.
%       	'dobc' = down and out barrier call
%       	'dibc' = down and in barrier call
%       	'uobc' = up and out barrier call
%       	'uibc' = up and in barrier call
%       	'dobp' = down and out barrier put
%       	'dibp' = down and in barrier put
%       	'uobp' = up and out barrier put
%       	'uibp' = up and in barrier put
%   The default value is dobc
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
%   The stock does not pay dividends. The price of a DOBC option
%   with time until maturity of 1.5 years is 4.90
%   The strike price of the option is 55$, the barrier level is placed 
%   at 40$ and the rebate is 2$. The risk free rate is 5% per annum. 
%	The following command will compute the implied volatility of this option:
% 
% 	vol = blsBarrierImpv(4.9033,50, 55, 40, 2, 1.5, 0.05, 0,'dobc')
%
% Example 2:
%	Consider a more involved example where we compute both the global
%   and individual implied volatilities of 9 barrier call options 
%	with different strikes and barriers.  All other parameters remain 
%	the same for all options. Option prices are defined below:
%	targetPrice = [11.10 8.73 7.64; 21.29 26.94 4.39; 18.57 19.09 3.67];
%	S0 = 100;
%	K = [90 100 110; 90 100 110; 90 100 110];
%	B = [97 97 97; 100 100 100; 103 103 103];
%	T = 1.50;
%	R = 2;
%	r = 0.10;
%	q = 0.05;
%	type = {'dibc','dibc','dibc'; 'dibc','dibc','dibc';'uibc','uibc','uibc'};
%	volGlobal = blsBarrierImpv(targetPrice,S0,K,B,R,T,r,q,type,1); % Global vol
%	volSeparate = blsBarrierImpv(targetPrice,S0,K,B,R,T,r,q,type,0); % Separate vols
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
% See also: BLSBARRIER, BLSBARRIERDELTA, BLSBARRIERGAMMA, BLSBARRIERVEGA, 
% BLSBARRIERTHETA, BLSBARRIERRHO, BLSBARRIERSUMSQUAREDERRORS

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
function [impliedVolatility] = blsBarrierImpv(targetPrice,St,K,B,R,T,r,q,type,calibrateAll)

if(nargin < 7)
	error('Not enough input parameters. Type "help blsBarrierImpv" for more information');
end;
if(nargin < 8 || isempty(q))
	q=0;
end;
if(nargin < 9 || isempty(type))
	warning('No barrier type input argument: dobc option(s) by default!');
	type = 'dobc';
end;
barrierTypes = {'dibc','dobc','uibc','uobc','dibp','dobp','uibp','uobp'};
if(not(isempty(find(ismember(char(type),barrierTypes)==0))))
	error('Unknown option type input argument detected: Type "help blsBarrierImpv" for more information');
end;
if(nargin < 10 || isempty(calibrateAll))
	calibrateAll = 1;
end;

optimizationSettings=optimset('TolX',1e-6,'TolFun',1e-6,'MaxFunEvals',10000);

if(calibrateAll) % compute implied volatility over the whole dataset
	impliedVolatility = fminsearch(@(sigma)blsBarrierSumSquaredErrors(sigma,targetPrice,St,K,B,R,T,r,q,type),0.25,optimizationSettings);
else  %% compute implied volatility for each option separately
	maxRows = 1; maxColumns = 1;
	inputCell = {targetPrice,St,K,B,R,T,r,q};
	if(not(isempty(find(cellfun(@isscalar,inputCell)==0))) | iscellstr(type))
		cellDim = [1 1];
		if(iscellstr(type))
			cellDim = size(type);
		end;
		maxRows = max([cellfun(@(x) size(x,1),inputCell), cellDim(1)]);
		maxColumns = max([cellfun(@(x) size(x,2),inputCell), cellDim(2)]);
		
		% Convert scalars to vector / matrix of maxsize
		logicalVector = find(cellfun(@isscalar,inputCell)==1);
		if not(isempty(logicalVector))
			inputCell(logicalVector) = cellfun(@(x) repmat(x,maxRows,maxColumns), inputCell(logicalVector),'uni',false);
			targetPrice = cell2mat(inputCell(1));
			St = cell2mat(inputCell(2));
			K = cell2mat(inputCell(3));
			B = cell2mat(inputCell(4));
			R = cell2mat(inputCell(5));
			T = cell2mat(inputCell(6));
			r = cell2mat(inputCell(7));
			q = cell2mat(inputCell(8));
		end;
		if not(iscellstr(type))
			type = repmat(cellstr(type),maxRows,maxColumns);
		end;
	end;
	maxSize = [maxRows, maxColumns];

	impliedVolatility = zeros(maxSize);
	for i=1:maxSize(1)
		for j=1:maxSize(2)
			impliedVolatility(i,j)= fminsearch(@(sigma)blsBarrierSumSquaredErrors(sigma,targetPrice(i,j),St(i,j),K(i,j),B(i,j),R(i,j),T(i,j),r(i,j),q(i,j),type(i,j)),0.25,optimizationSettings);
		end;
	end;
end;