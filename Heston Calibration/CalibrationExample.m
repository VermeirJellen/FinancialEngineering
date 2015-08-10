clc; clear;

% Fetch May 2015 XLB option data previously generated via an R script.
% Alternatively.. use option chain downloader to download fresh data for other assets..
option = xlsread('optionData/OptionData_Example','OptionData');
dividend = xlsread('optionData/OptionData_Example','Dividend');
interestRates = xlsread('optionData/OptionData_Example','InterestRates');
stock = xlsread('optionData/OptionData_Example','Stock');

S0 = stock; q = dividend; T = option(:,2)'; K = option(:,3)';
optionType = option(:,4)'; % 0 = call, 1 = put
optionMidMarket = option(:,5)'; bid = option(:,6)'; ask = option(:,7)';
r = spline(interestRates(:,1), interestRates(:,2), T);
T = T/365; % maturity in years

weights = 1; % Use (inverted) implied volatility for RMSE weights
plotOption = true; % plot the calibration results

% Run the calibration procedure
tic;
[hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,K,T,optionMidMarket,optionType,bid,ask,r,q,weights,plotOption);
toc

hestonParameters
outOfSampleRMSE
outOfSampleRMSEAdjusted