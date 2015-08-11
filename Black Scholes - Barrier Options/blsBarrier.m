% BLSBARRIER - Compute prices for exotic barrier options under the
% Black-Scholes model.
% 
% [price] = blsBarrier(sigma,S0,Strike,Barrier,Rebate,Time,Rate)
% [price] = blsBarrier(sigma,S0,Strike,Barrier,Rebate,Time,Rate,Yield,Type)
%
% Inputs:
%   Sigma - Black Scholes volatility of the underlying asset
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
%   price - The price of the barrier option
%
% Example 1:
%   Consider a stock trading at 50$ with a Black-Scholes volatility of 20%. 
%   The stock does not pay dividends. We would like to price a DOBC option
%   with time until maturity of 1.5 years.
%   The strike price of the option is 55$, the barrier level is placed 
%   at 40$ and the rebate is 2$. The risk free rate is 5% per annum. 
%	The following command will  return the price of this DOBC barrier option:
% 
% 	price = blsBarrier(0.20, 50, 55, 40, 2, 1.5, 0.05, 0,'dobc')
%
% Example 2:
%	Consider a more involved example where we price 9 different "in" type
%	barrier call options with different strikes and barriers. 
%	All other parameters remain the same for all options:
%	sigma = 0.20;
%	S0 = 100;
%	K = [90 100 110; 90 100 110; 90 100 110];
%	B = [97 97 97; 100 100 100; 103 103 103];
%	T = 1.50;
%	R = 2;
%	r = 0.10;
%	q = 0.05;
%	type = {'dibc','dibc','dibc'; 'dibc','dibc','dibc';'uibc','uibc','uibc'};
%	prices = blsBarrier(sigma,S0,K,B,R,T,r,q,type);
%	
% Notes:
% (1) The input arguments sigma, S0, Strike, Barrier, Rebate, Time, Rate and Yield
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
% References: 
%   Research program in Finance, working paper series (NO. 220)
%	Exotic options, by Mark Rubinstein
%
% See also: BLSBARRIERDELTA, BLSBARRIERGAMMA, BLSBARRIERVEGA, BLSBARRIERTHETA, 
% BLSBARRIERRHO, BLSBARRIERIMPV

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
function [price] = blsBarrier(sigma,St,K,B,R,T,r,q,type)

if(nargin < 7)
	error('Not enough input parameters. Type "help blsBarrier" for more information');
end
if(nargin < 8 || isempty(q))
	q=0;
end
if(nargin < 9 || isempty(type))
	warning('No barrier type input argument: Pricing dobc option(s) by default!');
	type = 'dobc';
end
barrierTypes = {'dibc','dobc','uibc','uobc','dibp','dobp','uibp','uobp'};
if(not(isempty(find(ismember(char(type),barrierTypes)==0))))
	error('Unknown option type input argument detected: Type "help blsBarrier" for more information');
end;
if not(iscellstr(type))
	type = cellstr(type);
end;

maxRows = 1; maxColumns = 1;
inputCell = {sigma,St,K,B,R,T,r,q};
if(not(isempty(find(cellfun(@isscalar,inputCell)==0))) | iscellstr(type))
	cellDim = [1 1];
	if(iscellstr(type))
		cellDim = size(type);
	end;
	maxRows = max([cellfun(@(x) size(x,1),inputCell), cellDim(1)]);
	maxColumns = max([cellfun(@(x) size(x,2),inputCell), cellDim(2)]);
end;
maxSize = [maxRows, maxColumns];

phi = -ones(size(type)); eta = -ones(size(type));
callTypes = {'dibc','dobc','uibc','uobc'};
downTypes = {'dibc','dobc','dibp','dobp'};
phi(ismember(type,callTypes)) = 1;
eta(ismember(type,downTypes)) = 1;

r1 = 1+r;
q1 = 1+q;
mu = log(r1./q1)-(1/2)*sigma.^2;
t = T;

lambda = 1 + (mu./sigma.^2);
a = mu./sigma.^2;
b = (sqrt(mu.^2+2*log(r1).*sigma.^2))./sigma.^2;
z = (log(B./St)./(sigma.*sqrt(t))) + b.*sigma.*sqrt(t);

x = (log(St./K)./(sigma.*sqrt(t))) + lambda.*sigma.*sqrt(t);
x1 = (log(St./B)./(sigma.*sqrt(t))) + lambda.*sigma.*sqrt(t);
y = (log(B.^2./(St.*K))./(sigma.*sqrt(t))) + lambda.*sigma.*sqrt(t);
y1 = (log(B./St)./(sigma.*sqrt(t))) + lambda.*sigma.*sqrt(t);

P1 = phi.*St.*q1.^(-t).*normcdf(phi.*x) - phi.*K.*r1.^(-t).*normcdf(phi.*x-phi.*sigma.*sqrt(t));
P2 = phi.*St.*q1.^(-t).*normcdf(phi.*x1) - phi.*K.*r1.^(-t).*normcdf(phi.*x1-phi.*sigma.*sqrt(t));
P3 = phi.*St.*q1.^(-t).*(B./St).^(2*lambda).*normcdf(eta.*y) - phi.*K.*r1.^(-t).*(B./St).^(2*lambda-2).*normcdf(eta.*y-eta.*sigma.*sqrt(t));
P4 = phi.*St.*q1.^(-t).*(B./St).^(2*lambda).*normcdf(eta.*y1) - phi.*K.*r1.^(-t).*(B./St).^(2*lambda-2).*normcdf(eta.*y1-eta.*sigma.*sqrt(t));
P5 = R.*r1.^(-t).*(normcdf(eta.*x1-eta.*sigma.*sqrt(t)) - (B./St).^(2*lambda-2).*normcdf(eta.*y1-eta.*sigma.*sqrt(t)));
P6 = R.*((B./St).^(a+b).*normcdf(eta.*z) + (B./St).^(a-b).*normcdf(eta.*z-2*eta.*b.*sigma.*sqrt(t)));

if(isequal(size(K),[1 1]) & not(isequal(maxSize,[1 1])))
	K = repmat(K,maxSize);
end;
S1 = ((strcmp(type,'dibc') & K>B) | (strcmp(type,'uibp') & K>B));
S2 = ((strcmp(type,'dibc') & K<=B) | (strcmp(type,'uibp') & K<=B));
S3 = ((strcmp(type,'uibc') & K>B) | (strcmp(type,'dibp') & K<=B));
S4 = ((strcmp(type,'uibc') & K<=B) | (strcmp(type,'dibp') & K>B));
S5 = ((strcmp(type,'dobc') & K>B) | (strcmp(type,'uobp') & K<=B));
S6 = ((strcmp(type,'dobc') & K<=B) | (strcmp(type,'uobp') & K>B));
S7 = ((strcmp(type,'uobc') & K>B) | (strcmp(type,'dobp') & K<=B));
S8 = ((strcmp(type,'uobc') & K<=B) | (strcmp(type,'dobp') & K>B));

price = zeros(maxSize);
price(S1) = P3(S1)+P5(S1);
price(S2) = P1(S2)-P2(S2)+P4(S2)+P5(S2);
price(S3) = P1(S3)+P5(S3);
price(S4) = P2(S4)-P3(S4)+P4(S4)+P5(S4);
price(S5) = P1(S5)-P3(S5)+P6(S5);
price(S6) = P2(S6)-P4(S6)+P6(S6);
price(S7) = P6(S7);
price(S8) = P1(S8)-P2(S8)+P3(S8)-P4(S8)+P6(S8);