#HESTON MODEL CALIBRATION TOOLKIT

Calibrate the Heston model parameters on an asset and its market options. Calibration is done through a randomized 75 percent training, 25 percent testing cross validation using the Nelder-Mead simplex method and a weighted bid-ask adjusted RMSE criterion. Feller condition and other computational considerations are taken into account for maximal performance.

Type `help <filename.m>` at the command prompt for a full explanation of the inputparameters and some additional examples.

- `HestonCalibration.m`: Calibrate the Heston Model Parameters on an asset and its available market options.
- `CalibrationExample.m`: This script contains an example on how to use the CalibrationProcedure. View `calibrationresults.png` for a graphical illustration.
- `./optiondata`: This folder contains example prices, optiondata and dividend information for the XLB index and also some information on US treasury rates. This data was generated around May 2015 and is used for demonstration purposes inside the example script.
- `./private`: This folder contains a range of technical subfunctionalities that are utilized during the calibrationprocedure. The functions will be documented more extensively in the future.

## Heston Calibration Help
###Running the procedure

`[hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,Strike,Time,optionMidMarket,optionType,BidPrices,AskPrices,Rate)`
`[hestonParameters, outOfSampleRMSE, outOfSampleRMSEAdjusted] = HestonCalibration(S0,Strike,Time,optionMidMarket,optionType,BidPrices,AskPrices,Rate,Yield,WeightsType,PrintOption))`

### Mandatory Inputs

- `S0` - Current stock price of the underlying asset
- `Strike` - Vector containing the strike prices of the available market options
- `Time` - Vector containing the Time to expiration of the available market options, expressed in years
- `OptionMidMarket` - Vector containing The (mid) market prices of the available market options.
- `OptionType` - Vector containing the option types of the available market options. 0 for call, 1 for put.
- `BidPrices` - Vector containing the bid prices of the available market options.
- `AskPrices` - Vector Containing the ask prices of the available market options.
- `Rate` - Vector containing the Annualized continuously compounded risk-free rates of return over
       the life of the options, expressed as a positive decimal number.

### Optional Inputs:
- `Yield` - Annualized continuously compounded yield of the underlying asset over the life of the option, expressed as a decimal number. For example, this could represent the dividend yield and foreign risk-free interest rate for options written on stock indices and currencies, respectively. If empty or missing, the default is zero.
- `WeightsType` - Indication of the weights that are given to individual options during the calibration process:
	- 1: (Inverted) implied volatility weighting
	- 2: (Inverted) bid-ask weighting
	- 0 or default: Equal weighting

- `PrintOption` - True if a graphical illustration of the calibration results should be generated upon completion. False otherwise. Default is false.

### Outputs
- `HestonParameters`: The Calibrated Heston Model parameters. The vector contains the the following values:
	- `Kappa`: Heston Model Parameter: "Speed of mean reversion". The rate at which Vt reverts to `Theta` (`Kappa` > 0)
	- `Eta` - Heston Model Parameter: "vol-of-vol", the volatility of the variance. Determines the variance of Vt. (`Eta` > 0)
	- `Theta` - Heston Model Parameter: "Level of mean reversion". This is the long variance, or long run average price variance (`Theta` > 0)
	- `Correlation` - Heston Model Parameter: Correlation between movements in the stock and its variance. (-1 < `Correlation` < 1)
	- `V0` - Heston Model Parameter: Initial vol (`V0` > 0)
		
- `outOfSampleRMSE` - The RMSE between the option mid market prices
		and the calibrated prices computed on the out of sample testset.

- `outOfSampleRMSEAdjusted` - The bid-ask adjusted RMSE between the option mid market prices and the calibrated prices computed on the out of sample testset. Note: Only calibrated prices that fall outside the bid-ask range are considered as errors by the RMSEAdjusted criterion.