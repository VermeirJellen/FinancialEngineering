% YAHOOOPTIONDATAPARSER - Parse option data information from the yahoo 
% finance website for a given array of inputsymbols.
%
% allOptionsData = yahooOptionDataParser(Symbols)
% allOptionsData = yahooOptionDataParser(Symbols,PrintStatus)
%
% Inputs:
%   Symbols - A cell array of symbols for which option data should be
%       fetched from the yahoo finance website.
% 
% Optional Inputs:
%   PrintStatus - true if statusinformation should be printed at runtime,
%       false otherwise. Default value is true.
%
% Output:
%   allOptionsData - A cell array that contains the optionInformation for
%       the array of inputsymbols. The outputarray is structured as follows:
%
%       - Every cell index of the main outputarray contains a struct that
%         holds all the available information for 1 individual symbol.
%
%       - Each of these substructs contains two elements:
%         1) The name of the ticker symbol
%         2) A cell array that contains the available optiondata 
%            for this symbol. Each element in the array contains
%            information for 1 particular expiration date.
%
%       - The latter cell array contains struct elements holding the 
%         expiration date values and both a call and a put option array.
%
%       - Finally, The call and put option arrays contain information
%         regarding the individual option contracts (represented as
%         structs)
%
%   View example 2 for more details on how to extract the relevant
%   information.
%
%   Note: The call / put structs contain the following information, as
%       presented on the  yahoo finance website:
%
%       - contractId: The unique identifier of the option contract
%
%       - Type: The optiontype, 0 for call, 1 for put
%
%       - Strike: The Strike (i.e, exercise) price of the option
%
%       - Time - Time to expiration of the option, expressed in years.
%         Calculated as follows: (expiration day - current time)/365
%
%       - MidPrice: The average price between the current bid price and the
%         current ask price of the option
%
%       - Bid: Current Bid price of the option
%
%       - Ask: Curent Ask price of the option
%
%       - OpenPrice: Current opening price of the option
%
%       - PreviousClose: previous closing price of the option
%
%       - Volume: Volume (ie, market breadth) of the option
%
%       - OpenInterest: Current number of contracts that are currently open
%
%       - Expiration: Expiration date of the option (string)
%
% Example 1:
%   The currently available option data for Ebay Inc. can be fetched by using
%   the following command:
%   ebayInformation = yahooOptionDataParser({'EBAY'});
%
% Example 2:
%   The currently available option date for both Ebay Inc. and Microsoft
%   corp. can be fetch by using the following command. Printing of output
%   information will be disabled:
%
% 	allOptionData = yahooOptionDataParser({'EBAY','MSFT'},false);
%
%   The first available expiration date for EBAY options can be fetched as
%   follows:
%   allOptionData{1}.expirationDates{1}.ExpirationDate
%
%   We can view the information of one of the Ebay call options that is
%   available on this particular date as follows:
%   allOptionData{1}.expirationDates{1}.callOptions{1}
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
function allOptionData = yahooOptionDataParser(symbols,printStatus)

if(nargin < 1 | isempty(symbols))
    error('At least one input parameter required: Type <help yahooOptionDataParser> for more information');
end;
if(not(iscellstr(symbols)))
    error('Input argument ''symbols'' should be a cell array of strings: Type <help yahooOptionDataParser> for more information');
end;
if(nargin < 2 | isempty(printStatus))
    printStatus = true;
end;

symbols = upper(symbols); % Upper case symbols required..

import java.io.*;
import java.net.*;
import java.lang.*;

nrSymbols = numel(symbols);
allOptionData = cell(nrSymbols,1);

try
    for nr = 1:nrSymbols
        ticker = symbols{nr};
        fprintf('\nParsing option information for symbol with the following ticker: %s\n',ticker);

        urlBase = 'https://query.yahooapis.com/v1/public/yql?q=';
        yahooFinance = 'select%20*%20from%20html%20where%20url%3D''http%3A%2F%2Ffinance.yahoo.com';
        genericTicker = '%2Fq%2Fop%3Fs%3DtickerSymbol%2BOptions''%20';
        xpathFilter = 'and%20xpath%3D''%2F%2Foption''';
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

        optionDates = xmlFile.getElementsByTagName('option');
        nrDates= optionDates.getLength();

        if(nrDates==0)
            warning('Unable to detect optiondata for symbol %s... Ignoring Symbol...\n',ticker);
            continue;
        end;

        genericOptionPage='%2Fq%2Fop%3Fs%3DtickerSymbol%26date%3DdateKey''%20';
        genericFetchContractsXPathQuery='and%20xpath%3D''%2F%2Fa%5Bcontains(%40href%2C%22tickerSymbol1%22)%5D''';

        optionDataContainer = cell(nrDates,1);

        for i=0:nrDates-1

            optionDate = optionDates.item(i);
            dateString = char(optionDate.getTextContent());
            optionDateKey = char(optionDate.getAttributes().getNamedItem('value').getTextContent());

            if(printStatus)
                fprintf('\nParsing options with expiration date %s:\n',dateString);
            end;

            specificOptionPage = strrep(genericOptionPage,'tickerSymbol',mTicker);
            specificOptionPage = strrep(specificOptionPage,'dateKey',optionDateKey);
            specificFetchContractsXPathQuery = strrep(genericFetchContractsXPathQuery,'tickerSymbol',ticker);

            urlString = [urlBase,yahooFinance,specificOptionPage,specificFetchContractsXPathQuery,formatString,postFix];
            url = URL(urlString);
            con = url.openConnection();
            xmlFile = xmlread(con.getInputStream());
            con.disconnect();

            genericContractPage = '%2Fq%3Fs%3DcontractKey''%20';
            fetchContractDetailsXPathQuery = 'and%20xpath%3D''%2F%2Ftd%5B%40class%3D%22yfnc_tabledata1%22%5D%20%7C%20%2F%2Fh2%5Bcontains(text()%2C%22put%22)%5D''';

            contracts = xmlFile.getElementsByTagName('a');

            nrContracts = contracts.getLength();
            if(nrContracts==0)
                warning('Unable to detect option contracts for date %s.. Ignoring Date..\n',dateString);
                continue;
            end;

            callCell = {}; putCell = {};
            for j=0:contracts.getLength()-1
                contractId = char(contracts.item(j).getTextContent());
                if(printStatus)
                    fprintf('Parsing information for the contract with id %s: ', contractId);
                end;
                specificContractPage = strrep(genericContractPage,'contractKey',contractId);
                urlString = [urlBase,yahooFinance,specificContractPage,fetchContractDetailsXPathQuery,formatString,postFix];
                url = URL(urlString);
                con = url.openConnection();
                contractData = xmlread(con.getInputStream());
                con.disconnect();

                properties = contractData.getElementsByTagName('td');

                if(properties.getLength()>0) % Option is actively traded. Implied vol is not 0.
                    optionType=true;
                    if(contractData.getElementsByTagName('h2').getLength() > 0)
                        optionType = false;
                    end;
                    prevClose = str2double(properties.item(0).getTextContent());
                    open = str2double(properties.item(1).getTextContent());
                    bid = str2double(properties.item(2).getTextContent());
                    ask = str2double(properties.item(3).getTextContent());
                    if isempty(bid)
                        bid = 0;
                    end;
                    if isempty(ask)
                        ask = 0;
                    end;
                    midPrice = (bid+ask)/2;
                    K = str2double(properties.item(4).getTextContent());
                    expirationDate = char(properties.item(5).getTextContent());
                    T = daysact(now,expirationDate)/365;
                    volume = str2double(properties.item(8).getTextContent());
                    openInterest = str2double(properties.item(9).getTextContent());

                    contract = struct('contractId',contractId,'Type',optionType,'Strike',K,'Time',T,'MidPrice',midPrice,'Bid', ...
                        bid,'Ask',ask,'OpenPrice',open,'PreviousClose',prevClose,'Volume',volume, ...
                        'OpenInterest',openInterest,'Expiration',expirationDate);

                    if optionType
                        callCell = [callCell; {contract}];
                    else
                        putCell = [putCell; {contract}];
                    end; 

                    if(printStatus)
                        fprintf('Success! \n');
                    end;
                else
                    if(printStatus)
                        fprintf('No information / Option is not actively traded.. Ignoring Contract..\n');
                    end;
                end;
            end;
            optionDataContainer{i+1} = struct('ExpirationDate',dateString,'callOptions', ...
                    {callCell},'putOptions',{putCell});
        end;

        optionDataContainer = optionDataContainer(~cellfun('isempty',optionDataContainer));
        allOptionData{nr} = struct('Symbol',ticker,'expirationDates',{optionDataContainer});
    end;
    allOptionData = allOptionData(~cellfun('isempty',allOptionData));
catch EX
    display(EX.message);
    warning('Unhandled Exception.. ABORTING...');
    allOptionData = [];
end;
