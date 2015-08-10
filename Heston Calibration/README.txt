HESTONCALIBRATION - Calibrate the Heston model parameters on an asset and its market options. Calibration is done through a randomized 75 percent training, 25 percent testing cross validation using the Nelder-Mead simplex method and a weighted bid-ask adjusted RMSE criterion. Feller condition and other computational considerations are taken into account for maximal performance.

Type "help <filename.m>" at the command prompt for a full explanation of the inputparameters and some additional examples.
1 - HestonCalibration.m - Calibrate the Heston Model Parameters on an asset and its available market options.
2 - CalibrationExample.m - This script contains an example on how to use the CalibrationProcedure.
3 - ./optiondata - This folder contains example prices, optiondata and dividend information for the XLB index and also some information on US treasury rates. This data was generated around May 2015 and is used for demonstration purposes inside the example script.
4 - ./private - This folder contains a range of technical subfunctionalities that are utilized during the calibrationprocedure. The functions will be documented more extensively in the future.