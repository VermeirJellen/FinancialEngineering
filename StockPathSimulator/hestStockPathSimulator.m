% HESTSTOCKPATHSIMULATOR - Perform stock path simulations 
% under the Heston model using an Euler-Milstein scheme.
% Antithetic stock paths are also generated during the simulation process.
%
% [stock antiStock] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,S0,Time,Rate)
% [stock antiStock] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,S0,Time,Rate,Yield,maturity,nrPeriods,nrPaths,Z1,Z3)
%
% Inputs:
%   Kappa - Heston Model Parameter: "Speed of mean reversion".
%		The rate at which Vt reverts to Theta (Kappa > 0)
%
%   Theta - Heston Model Parameter: "Level of mean reversion".
%		This is the long variance, or long run average price variance (Theta > 0)
%
%   Eta - Heston Model Parameter: "vol-of-vol", the volatility
%		of the variance. Determines the variance of Vt. (Eta > 0)
%
%   Correlation - Heston Model Parameter: Correlation between movements
%		in the stock and its variance. (-1 < Correlation < 1)
%
%	V0 - Heston Model Parameter: Initial vol (V0 > 0)
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
%	Z1 - matrix of size nrPaths x nrPeriods. When left empty, the matrix
%		is generated randomly.
%
%	Z3 - matrix of size nrPaths x nrPeriods. When left empty, the matrix
%		is generated randomly.
%
% Output:
%   stock - Simulated stock prices
%
%	antiStock - Simulated stock prices that are generated based on 
%	random variables with opposite sign.
%
% Example 1:
%   Assume that the following Heston Parameters have been obtained during
%	a calibration process:
%	Kappa=2.5; 
%	Theta=0.05; 
%	Eta=0.5; 
%	Correlation=-0.85; 
%	V0=0.12;
%	We want to simulate the price in 1 year time for an asset that is currently
%	priced at 100 using the Heston Model. There is no dividend yield and 
%	the risk free interest rate is 10%.
%	In order to obtain the simulated prices we can perform the following command:
%
%	[stock antiStock] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,100,1,0.10);
%
% Example 2:
%	Assume the same market conditions as in example 1. However, we now want to
%	Simulate both the 1 year and 2 year asset prices. For the 1 year simulation 
%	we use 100 discrete steps, for the 2 year period we use 200 discrete steps. 
%	Furthermore, we would like to perform 100000 simulations
%	for each distinct run. We also preallocate the random matrices that are used 
%	during the simulation process. Finally, we want to obtain the complete stockpaths  
%	at every discrete point for the 2 year time period (instead of only 
%	the final stockvalues). All this can be done with the following commands:
%
%	Kappa=2.5; 
%	Theta=0.05; 
%	Eta=0.5; 
%	Correlation=-0.85; 
%	V0=0.12;
%	nrPaths = 100000;
%	nrPeriods = 100;
%	T = 1;
%	maturity = 1; % Default
%	Z1 = normrnd(0,1,nrPaths,nrPeriods);
%	Z3 = normrnd(0,1,nrPaths,nrPeriods);
%
%	[stock1 antiStock1] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,100,T,0.10,0,maturity,nrPeriods,nrPaths,Z1,Z3);
%
%	T = 2;
%	maturity = 0;
%	nrPeriods = 200;
%	Z1 = normrnd(0,1,nrPaths,nrPeriods);
%	Z3 = normrnd(0,1,nrPaths,nrPeriods);
%	[stock2 antiStock2] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,100,T,0.10,0,maturity,nrPeriods,nrPaths,Z1,Z3);
%
%	Copyright 2015 Jellen Vermeir 
%	jellenvermeir@gmail.com	
%
% See also: BLSSTOCKPATHSIMULATOR
function [stock antiStock] = hestStockPathSimulator(Kappa,Theta,Eta,Correlation,V0,S0,T,r,q,maturity,nrPeriods,nrPaths,Z1,Z3)

if(nargin < 8)
	error('Not enough inputparameters: type help "hestStockPathSimulator" for more information on the input requirements.');
end;
if(nargin < 9 || isempty(q))
	q = 0;
end;
if(nargin < 10 || isempty(maturity))
	maturity = 1;
end;
if(nargin < 11 || isempty(nrPeriods))
	nrPeriods = 100;
end;
if(nargin < 12 || isempty(nrPaths))
	nrPaths = 50000;
end;

M=nrPaths;
N=nrPeriods;
dt = T/N;

if(nargin < 13 || isempty(Z1))
	Z1 = normrnd(0,1,M,N);
end;
if(nargin < 14 || isempty(Z3))
	Z3 = normrnd(0,1,M,N);
end;

if(Kappa < 0 | Theta < 0 | Eta < 0 | abs(Correlation) > 1 | V0 < 0)
	error('One or more of the Heston Parameters are incorrectly defined: type help "SimulationStockPathsHeston" for more information on the input requirements.');
end;
	
kappa=Kappa;
eta=Theta; % Note: switch eta and theta in computation! (alternative greek symbol specification)
theta=Eta; % Note: switch eta and theta in computation! (alternative greek symbol specification)
cor=Correlation;
sig=V0;

Z2 = cor*Z1 + (sqrt(1-cor^2)*Z3);

zerosMatrix = zeros(M,N); onesVector = ones(M,1);
S = [S0*onesVector, zerosMatrix];
V = [sig^2*onesVector,zerosMatrix];
Sneg = S;
Vneg = V;

% Simulation of N-step trajectories for the Variance and price of the underlying asset (Euler-Milstein)
for i = 1:N
    V(:,i+1) = V(:,i) + (kappa*(eta-V(:,i))-theta^2/4)*dt + theta*sqrt(V(:,i)).*Z2(:,i)*sqrt(dt) + (theta^2*dt*(Z2(:,i).^2))/4;
    V(:,i+1) = V(:,i+1).*(V(:,i+1)>0); % keep values positive
	S(:,i+1) = S(:,i).*(1+(r-q)*dt + sqrt(V(:,i))*sqrt(dt).*Z1(:,i));
	
	% Antithetic stock paths
	Vneg(:,i+1) = Vneg(:,i) + (kappa*(eta-Vneg(:,i))-theta^2/4)*dt - theta*sqrt(Vneg(:,i)).*Z2(:,i)*sqrt(dt) + (theta^2*dt*(Z2(:,i).^2))/4;
	Vneg(:,i+1) = Vneg(:,i+1).*(Vneg(:,i+1)>0); % keep values positive
	Sneg(:,i+1) = Sneg(:,i).*(1+(r-q)*dt - sqrt(Vneg(:,i))*sqrt(dt).*Z1(:,i));
end;

if(maturity) % Return simulated stock prices at maturity
	stock=S(:,N+1);
	antiStock=Sneg(:,N+1);
else % Return full simulated paths
	stock=S;
	antiStock=Sneg;
end;