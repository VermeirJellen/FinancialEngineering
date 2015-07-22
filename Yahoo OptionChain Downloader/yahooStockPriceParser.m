% YAHOOSTOCKPRICEPARSER - Parse Stock price data from the yahoo 
% finance website for a given array of inputsymbols.
%
% stockPriceData = yahooStockPriceParser(Symbols)
% stockPriceData = yahooStockPriceParser(Symbols,PrintStatus)
%
% Inputs:
%   Symbols - A cell array of symbols for which the stock prices should be
%       fetched from the yahoo finance website.
% 
% Optional Inputs:
%   PrintStatus - true if statusinformation should be printed at runtime,
%       false otherwise. Default value is true.
%
% Output:
%   stockPriceData - A cell array that contains the stock price data for
%       the array of inputsymbols. The outputarray is structured as follows:
%
%       - Every cell index of the main outputarray contains a struct that
%         holds the ticker symbol and its corresponding stockprice
%
% Example 1:
%   The current EBAY stock price can be fetched by using the following
%   command:
%   ebayInformation = yahooStockPriceParser({'EBAY'});
%
% Example 2:
%   The current available stock prices for Google Inc. and Microsoft corp
%   can be fetched by using the following command. Printing of output
%   information is disabled:
%
% 	stockPrices = yahooStockPriceParser({'GOOG','MSFT'},false);
%
%   The stock price for MSFT can be extracted by using the following
%   command:
%   MSFT_Price = stockPrices{2}.StockPrice;
%
% Copyright 2015 Jellen Vermeir 
% jellenvermeir@gmail.com	

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
function allStockPriceData = yahooStockPriceParser(symbols,printStatus)

if(nargin < 1 | isempty(symbols))
    error('At least one input parameter required: Type <help yahooStockPriceParser> for more information');
end;
if(not(iscellstr(symbols)))
    error('Input argument ''symbols'' should be a cell array of strings: Type <help yahooStockPriceParser> for more information');
end;
if(nargin < 2 | isempty(printStatus))
    printStatus = true;
end;

symbols = upper(symbols); % Upper case symbols required..

import java.io.*;
import java.net.*;
import java.lang.*;

nrSymbols = numel(symbols);
allStockPriceData = cell(nrSymbols,1);

try
    for nr = 1:nrSymbols
        ticker = symbols{nr};
        
        if(printStatus)
            fprintf('Parsing stock price information for symbol with the following ticker: %s\n',ticker);
        end;

        urlBase = 'https://query.yahooapis.com/v1/public/yql?q=';
        yahooFinance = 'select%20*%20from%20html%20where%20url%3D''http%3A%2F%2Ffinance.yahoo.com';
        genericTicker = '%2Fq%2Fop%3Fs%3DtickerSymbol%2BOptions''%20';
        xpathFilter = 'and%20xpath%3D''%2F%2Fspan%5Bcontains(%40id%2C%22yfs_l84%22)%5D''';
        formatString = '&format=xml';
        postFix = '&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

        mTicker = ticker;
        if(ismember(ticker,{'VIX','DJX','SPXPM'}))
            mTicker = ['%255E',ticker];
        end;
        specificTicker = strrep(genericTicker,'tickerSymbol',mTicker);
        urlString = [urlBase,yahooFinance,specificTicker,xpathFilter,formatString,postFix];

        url = URL(urlString);
        con = url.openConnection();   
        xmlFile=xmlread(con.getInputStream());
        con.disconnect();

        elementNode = xmlFile.getElementsByTagName('span');
        if elementNode.getLength() == 1
            stockPrice = str2double(char(xmlFile.getElementsByTagName('span').item(0).getTextContent()));
            allStockPriceData{nr} = struct('Symbol',ticker,'StockPrice',stockPrice);
        else
            warning('Unable to detect stock price data for symbol %s... Ignoring Symbol...\n',ticker);
            continue;
        end;
    end;
    allStockPriceData = allStockPriceData(~cellfun('isempty',allStockPriceData));
catch EX
    display(EX.message);
    warning('Unhandled Exception.. ABORTING...');
    allStockPriceData = [];
end;