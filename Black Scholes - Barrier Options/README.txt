Barrier Options - Pricing, Greeks & Implied Volatility Calibration (Black-Scholes)

Type "help <filename.m>" at the command prompt for a full explanation of the inputparameters and some additional examples. 
1 - blsBarrier.m - Pricing of Barrier options under Black-Scholes (Closed form solution) 
2 - blsBarrierImpv - Compute the implied volatility for exotic barrier options given the market or "target prices" as inputs. The goal of the calibration process is to obtain the volatility value that minimizes an error function computed from the calculated option prices and the target prices. Minimization of the error function is performed using the Nelder-Mead Simplex algorithm. 
3 - blsBarrierSumSquaredErrors - The error function that will be minimized during the implied volatility calibration process. The error function represents the sum of squared errors between the computed prices and the target prices. 
4 - blsBarrierDelta.m - Compute the Delta of the options via central finite difference approximation for the first derivative of the option price with respect to the underlying. 
5 - blsBarrierGamma.m - Compute the Gamma of the options via central finite difference approximation for the second derivative of the option price with respect to the price of the underlying. 
6 - blsBarrierVega.m - Compute the Vega of the options via forward finite difference approximation for the first derivative of the option price with respect to the volatility of the underlying. 
7 - blsBarrierTheta.m - Compute the Theta of the options via forward finite difference approximation for the first derivative of the option price with respect to time until maturity change. 
8 - blsBarrierRho.m - Compute the Rho of the options via forward finite difference approximation for the first derivative of the option price with respect to interest rate changes.