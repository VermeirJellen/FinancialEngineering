% HESTONCALIBRATION - Calibrate the Heston model parameters on an asset and its market options.
%	Calibration is done through a randomized 75 percent training, 25 percent testing cross validation
%	using the Nelder-Mead simplex method and a weighted bid-ask adjusted RMSE criterion.
%	Feller condition and other computational considerations are taken into account for maximal performance.
%
% [hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,Strike,Time,optionMidMarket,optionType,BidPrices,AskPrices,Rate)
% [hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,Strike,Time,optionMidMarket,optionType,BidPrices,AskPrices,Rate,Yield,WeightsType,PrintOption))
%
% Inputs
%	S0 - Current stock price of the underlying asset
%
%	Strike - Vector containing the strike prices of the available market options
%
%	Time - Vector containing the Time to expiration of the available market options, 
%		expressed in years
%
%	OptionMidMarket - Vector containing The (mid) market prices of the available market options.
%
%	OptionType - Vector containing the option types of the available market options.
%		0 for call, 1 for put.
%
%	BidPrices - Vector containing the bid prices of the available market options.
%
%	AskPrices - Vector Containing the ask prices of the available market options.
%
%	Rate - Vector containing the Annualized continuously compounded risk-free rates of return over
%       the life of the options, expressed as a positive decimal number.
%
% Optional Inputs:
%	Yield - Annualized continuously compounded yield of the underlying asset
%     over the life of the option, expressed as a decimal number. For example,
%     this could represent the dividend yield and foreign risk-free interest
%     rate for options written on stock indices and currencies, respectively.
%     If empty or missing, the default is zero.
%
%	WeightsType - Indication of the weights that are given to individual options
%		during the calibration process:
%			1 - (Inverted) implied volatility weighting
%			2 - (Inverted) bid-ask weighting
%			0 or default: Equal weighting
%
%	PrintOption - True if a graphical illustration of the calibration results should be
%		generated upon completion. False otherwise. Default is false.
%	
%
% Outputs
%	HestonParameters - The Calibrated Heston Model parameters. The vector contains the
%		the following values:
%		Kappa - Heston Model Parameter: "Speed of mean reversion".
%			The rate at which Vt reverts to Theta (Kappa > 0)
%
%  		 Eta - Heston Model Parameter: "vol-of-vol", the volatility
%		of the variance. Determines the variance of Vt. (Eta > 0)
%
%   	Theta - Heston Model Parameter: "Level of mean reversion".
%			This is the long variance, or long run average price variance (Theta > 0)
%
%   	Correlation - Heston Model Parameter: Correlation between movements
%			in the stock and its variance. (-1 < Correlation < 1)
%
%		V0 - Heston Model Parameter: Initial vol (V0 > 0)
%
%
%   outOfSampleRMSE - The RMSE between the option mid market prices
%		and the calibrated prices computed on the out of sample testset.
%
%	outOfSampleRMSEAdjusted - The bid-ask adjusted RMSE between the option 
%		mid market prices and the calibrated prices computed on the out of sample testset.
%		Note: Only calibrated prices that fall outside the bid-ask range are considered
%			as errors by the RMSEAdjusted criterion.
% 
% Example:
%	View CalibrationExample.m for an example
%
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
function [hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,K,T,optionMidMarket,optionType,bid,ask,r,q,weightsOption,printOption)

if(nargin < 8)
	error('Not enough inputparameters: type help "HestonCalibration" for more information on the input requirements.');
end;
if(nargin < 9 || isempty(q))
	q = 0;
end;
if(nargin < 10 || isempty(weightsOption))
	weightsOption = 0; % Use equal weighting for options
end;
if(nargin < 11 || isempty(printOption))
	printOption = false;
end;

marketData = struct('S0',S0,'q',q,'T',T,'K',K,'optionType',optionType,'optionMidMarket',optionMidMarket,'bid',bid,'ask',ask,'r',r);
%% Default Carr Madan Parameters
N=4096; alpha=1.5; gridSpace=0.25; simpsonIntegrand=1;
carrMadanPrecomputed = PrecomputationCarrMadanParameters(N,alpha,gridSpace,simpsonIntegrand); % Precompute modelindependent carr-madan parameters and variables

% Initial educated guess for Heston Model Parameters
% Note: Alternative Greek symbol specification: Parameters eta and theta are switched during the calculations.
% Parameters are switched again before returning their values in order to comply to literature convention.
kappa=7; eta=0.7; theta=0.7; corr=-0.5; sig=0.18;
initialGuessHeston = [kappa eta theta corr sig];

if weightsOption==1
	weightsOptimization = 1./BlackScholesImpliedVolatility(S0,K,r,q,T,optionType,optionMidMarket,false);
elseif weightsOption==2
	weightsOptimization = 1./abs(ask-bid);
else
	weightsOptimization = ones(1,length(K));
end;
	
[hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = CalibrateHestonParametersCrossValidation(marketData,carrMadanPrecomputed,initialGuessHeston,weightsOptimization,printOption);
hestonParameters([2 3]) = hestonParameters([3 2]); % Note: switch eta and theta! (alternative greek symbol specification)