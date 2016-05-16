## Designing a structured product - Reverse Convertible

### Project Overview
This subproject includes a paper and a demo that illustrates the structuring process of a Reverse Convertible with EBAY inc. stock as underlying. A description of the product details and the structuring process are described in `./paper/Structuring_a_Reverse_Convertible.pdf`. View `./ReverseConvertible.m` for the demo implementation.

### Product and market characteristics
The investor buys a Reverse Convertible with EBAY inc. as underlying for 11000USD (N). The issue date of the RC is december 14th 2014 and its maturity date is Januari 15th 2016 (T). The strike price of the RC is 55USD (S0). The stock price of EBAY inc. on the issue date is 55.77USD (S0). The product offers a 7.25% coupon with quarterly payments: This translates to 4 future periodic coupons that are each worth 199.3795USD plus an additional coupon at maturity that is worth 69.92USD.



Risk free interest rates on the issue date are:

- 3 month -  0.02 percent
- 6 month  - 0.09 percent
- 9 month  - 0.14 percent (linear interpolation)
- 1 year   - 0.19 percent
- Maturity - 0.22 percent (linear interpolation)

### Structuring process
The product will be structured so that the payoff at maturity equals min(N,alpha*St) with alpha = N/K and St = the stock price at maturity. Note that the investor will get back the full notional at maturity if St >= K.

- We put 10973.42USD in the bank. This amount can be used to pay back the full notional at maturity when St >= K.
- We sell 200.00 puts with strike K and maturity T for a total premium of 950.00USD.
- We keep 1.00 percent of the notional as profit. This corresponds to 110.00USD.
- In total, We have 866.58 USD left to pay the periodic coupons. We place this money in the bankaccount.

We will use the money on the bankaccount to pay out the coupons. We take the interest rates into account to account to determine the amount for the 5 future periodic payments that were promised to the investor. In more detail:

- 199.3696USD of the 866.58USD on the bankaccount at issue date will be used to pay out 199.3795USD on Mar. 14th 2015
- 199.2898USD of the 866.58USD on the bankaccount at issue date will be used to pay out 199.3795USD on Jun. 14th 2015
- 199.1703USD of the 866.58USD on the bankaccount at issue date will be used to pay out 199.3795USD on Sep. 14th 2015
- 199.0011USD of the 866.58USD on the bankaccount at issue date will be used to pay out 199.3795USD on Dec. 14th 2015
- 69.7504USD of the 866.58USD on the bankaccount at issue date will be used to pay out 69.9194USD on Jan. 15th 2016

This corresponds to a total coupon payment of 867.44USD or an annualized coupon payment of 7.2502 percent. For more details on the calculations, view `./ReverseConvertible.m.`. View `./images/Structure.png` for a graphical illustration on the structuring process.

### Evaluation
The return characteristics of the reverse convertible versus the underlying stock and the risk free rate are illustrated in `./images/pnl.png`. For more details, view the attached paper.