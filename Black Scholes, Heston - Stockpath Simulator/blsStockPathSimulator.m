% BLSSTOCKPATHSIMULATOR - Perform stock path simulations 
% under the Black-Scholes model using an Euler scheme.
% Antithetic stock paths are also generated during the simulation process.
%
% [stock antiStock] = blsStockPathSimulator(Sigma,S0,Time,Rate)
% [stock antiStock] = blsStockPathSimulator(Sigma,S0,Time,Rate,Yield,maturity,nrPeriods,nrPaths,Z1,Z3)
%
% Inputs:
%   Sigma - Black-Scholes volatility parameter
%
%	S0 - Current stock price of the underlying asset
%
%   Time - Time period of the simulation
%
%   Rate - Annualized continuously compounded risk-free rate of return over
%       the time period of the simulation, expressed as a positive decimal number.
% 
% Optional Inputs:
%   Yield - Annualized continuously compounded yield of the underlying asset
%   	over the time period of the simulation, expressed as a decimal number.
%
%	maturity: if true, return only the simulated stock prices at maturity. If false,
%		return the full simulated stock values at every discrete point.
%
%	nrPeriods: The number of discrete steps that are used during the simulations
%		Default value is 100.
%
%	nrPaths: The amount of simulations performed. Default is 100000.
%
%	Z - matrix of size nrPaths x nrPeriods. When left empty, the matrix
%		is generated randomly.
%
% Output:
%   stock - Simulated stock prices
%
%	antiStock - Simulated stock prices that are generated based on 
%		random variables with opposite sign.
%
% Example 1:
%   Assume that the Black-Scholes volatility parameter for the underlying stock
%	is 20%. We want to simulate the price in 1 year time for an asset that is currently
%	priced at 100 using the Black-Scholes Model. There is no dividend yield and 
%	the risk free interest rate is 10%. In order to obtain the simulated prices 
%	we can perform the following command:
%
%	[stock antiStock] = blsStockPathSimulator(0.20,100,1,0.10);
%
% Example 2:
%	Assume the same market conditions as in example 1. However, we now want to
%	Simulate both the 1 year and 2 year asset prices. For the 1 year simulation 
%	we use 100 discrete steps, for the 2 year period we use 200 discrete steps. 
%	Furthermore, we would like to perform 100000 simulations
%	for each distinct run. We also preallocate the random matrices that are used 
%	in the simulation process. Finally, we want to obtain the complete stockpath  
%	at every discrete point for the 2 year time period (instead of only 
%	the final stockvalues). All this can be done with the following commands:
%
%	Sigma = 0.20;
%	nrPaths = 100000;
%	nrPeriods = 100;
%	T = 1;
%	maturity = 1; % Default
%	Z = normrnd(0,1,nrPaths,nrPeriods);
%
%	[stock1 antiStock1] = blsStockPathSimulator(Sigma,100,T,0.10,0,maturity,nrPeriods,nrPaths,Z);
%
%	T = 2;
%	maturity = 0;
%	nrPeriods = 200;
%	Z = normrnd(0,1,nrPaths,nrPeriods);
%	[stock2 antiStock2] = blsStockPathSimulator(Sigma,100,T,0.10,0,maturity,nrPeriods,nrPaths,Z);
%
%	Copyright 2015 Jellen Vermeir 
%	jellenvermeir@gmail.com	
%
% See also: HESTSTOCKPATHSIMULATOR

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
function [stock antiStock] = blsStockPathSimulator(sigma,S0,T,r,q,maturity,nrPeriods,nrPaths,Z)

if(nargin < 4)
	error('Not enough input parameters: type help "blsStockPathSimulator" for more information on the input requirements.');
end;
if(nargin < 5 || isempty(q))
	q = 0;
end;
if(nargin < 6 || isempty(maturity))
	maturity = 1;
end;
if(nargin < 7 || isempty(nrPeriods))
	nrPeriods = 100;
end;
if(nargin < 8 || isempty(nrPaths))
	nrPaths = 50000;
end;

M=nrPaths;
N=nrPeriods;
dt = T/N;

if(nargin < 9 || isempty(Z))
	Z = normrnd(0,1,M,N);
end;

zerosMatrix = zeros(M,N); onesVector = ones(M,1);
S = [S0*onesVector, zerosMatrix];
Sneg = S;

% Simulation of N-step trajectories for the stockpaths 
for i = 1:N
    S(:,i+1) = S(:,i).*(1+(r-q)*dt+sigma*sqrt(dt)*Z(:,i));
    S(:,i+1) = S(:,i+1).*(S(:,i+1)>0); % keep values positive
	
	Sneg(:,i+1) = Sneg(:,i).*(1+(r-q)*dt-sigma*sqrt(dt)*Z(:,i));
    Sneg(:,i+1) = Sneg(:,i+1).*(Sneg(:,i+1)>0); % keep values positive
end

if(maturity) % Return simulated stock prices at maturity
	stock=S(:,N+1);
	antiStock=Sneg(:,N+1);
else % Return full simulated paths
	stock=S;
	antiStock=Sneg;
end;