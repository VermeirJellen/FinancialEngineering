% Our reverse convertible is composed of a long position in a zero-coupon
% note (paying 100% of the notional at maturity) and a short position in a
% European put option with maturity T and strike K.
% K and T also represent the strike price and the maturity of our Reverse 
% Convertible.
%
% There is currently no at the money option for Stock price S0 on the
% issue date. We will use the first out-of the money put with highest
% strike price to structure the RC. This will maximize the fixed coupon 
% that can be paid but will also result in more downside risk for the 
% investor.

% We assume that the issue date is December 14th 2014. The maturity of the
% shorted put options (and our reverse convertible) is January 15th 2016.

% The 3 month, 6 month and 1 year treasury yields represent the interest
% rates that are used to perform the discounting of the 1st, 2nd and 4th 
% coupon payment
yieldm3 = 0.0002; % discount rate for coupon of March 14th 2015
yieldm6 = 0.0009; % disocunt rate for coupon of June 14th 2015
yieldy1 = 0.0019; % disocunt rate for coupon of December 14th 2015
yieldy2 = 0.0056;

% We also need the 9 month and 1 year + 32 days interest rates to perform 
% the discounting of the 3rd and 5th coupon payment (we also need it for 
% the discounting of the notional amount). There are no treasury yields for
% these maturities, so we obtain estimates through simple linear
% regression between the closest existing maturities.
yieldm9 = (yieldm6+yieldy1)/2; % discount rate for coupon of September 14 th 2015

% We assume an Actual/Actual daycount convention to estimate the interest
% rate at maturity
yieldMaturity = yieldy1 + (yieldy2-yieldy1)*32/365; % discount rate for coupon of January 15th 2016


%%%%%%%%%%%%%%%%%%%%%%% Structuring process *****************************
N = 11000; % The notional = amount invested by the investor.
S0 = 55.77; % Current stock price of Ebay inc
K = 55; % Strike price for our reverse convertible
putPrice = 4.75; % Price of the option with maturity 15th January 2016 and strike price K
profitMargin = 0.01; % As the bank we keep 1 percent of the notional as profit

fprintf('Investor buys the reverse convertible for %dUSD (N).\n',N);
fprintf('The Current price of Ebay Inc is %.2fUSD (S0).\n',S0);
fprintf('The Strike price of our reverse convertible is %dUSD (K).\n',K);
fprintf('The maturity date of the RC is January 15th 2016 (T).\n');
fprintf('The product will be structured so that the payoff at maturity equals min(N,alpha*St) with alpha = N/K and St = the stock price at maturity.\n')
fprintf('In addition, 4 quarterly coupon payments plus an extra coupon at maturity on January 15th 2016 will be payed out.\n');
fprintf('Note that the investor will get back the full notional at maturity if St >= K.\n\n');

fprintf('Structuring will be performed as follows:\n');
% At maturity the payoff for the investor should be min(N,alpha*St), where
% St is the stock price at maturity and alpha = N/K = face value/Strike price. 
% Note: We can not set (K = S0) because there is no at the money option
% available with strike price S0. This effectively means that the investor will receive
% back the full notional if the stock price at maturity >= K.
%
% From the investment bank point of view we have the following:
% Amount to spend at issue date(N) - profitBank = discountedNotional(Bankaccount) - alpha*putPrice(received premiums) + pvCoupon(Bankaccount)

% We need to be able to pay back the notional at maturiy (if the price of
% the stock >= K). For this purpose, we put the discountedNotional on the
% bank account.
% discountedNotional = notional * e^(-rT)
discountedNotional = N*exp(-yieldMaturity*(1+32/365));
fprintf('- We put %.2fUSD in the bank. This amount can be used to pay back the full notional at maturity when St >= K.\n',discountedNotional);

% We sell a certain maximal amount of put options with strike K and
% maturity T so that the issuer is still covered when the stock price of
% the underlying goes to 0 (worst case scenario). When this happens the
% investor will loose the full notional amount and only receives the
% coupon payments. The maximal loss for each individual put that we sold is the strike
% price K. This means that we can sell up to N/K = alpha puts.
% Hence, when the stock price goes to zero the investor will loose alpha*K
% = N = the full amount of the notional.
alpha = N/K;

% Calculate the total premium we receive by selling this amount of puts
premiumPuts = alpha*putPrice;
fprintf('- We sell %.2f puts with strike K and maturity T for a total premium of %.2fUSD.\n',alpha,premiumPuts)

% As the investment bank, we keep a small percentage of the notional as our profit
profitBank = profitMargin*N;
fprintf('- We keep %.2f percent of the notional as profit. This corresponds to %.2fUSD.\n',profitMargin*100,profitBank);

% We can now calculate the present value of the amount that we can
% put on the bankaccount to pay the periodic coupons with.
pvCoupon = N-profitBank-discountedNotional+premiumPuts;
fprintf('- In total, We have %.2f USD left to pay the periodic coupons. We place this money in the bankaccount.\n\n',pvCoupon);

% We want to calculate the yearly annualized coupon percentage C. The
% present value of the coupons is the summation of the discounted future values of the
% 5 coupon payments. We solve the following equation for C:
% pvCoupon = C*N/4*exp(-yieldm3*0.25) + C*N/4*exp(-yieldm6*0.5) + C*N/4*exp(-yieldm9*0.75) + C*N/4*exp(-yieldy1) + C*N*(32/365)*exp(-yieldMaturity*(1+32/365))
% <> pvCoupon = C*(N/4*exp(-yieldm3*0.25)+N/4*exp(-yieldm6*0.5)+N/4*exp(-yieldm9*0.75) + N/4*exp(-yieldy1) + N*(32/365)*exp(-yieldMaturity*(1+32/365))
% <> C = pvCoupon / (N/4*exp(-yieldm3*0.25) + N/4*exp(-yieldm6*0.5) + N/4*exp(-yieldm9*0.75) + N/4*exp(-yieldy1) + N*(32/365)*exp(-yieldMaturity*(1+32/365)))
C = pvCoupon / (N/4*exp(-yieldm3*0.25) + N/4*exp(-yieldm6*0.5) + N/4*exp(-yieldm9*0.75) + N/4*exp(-yieldy1) + N*(32/365)*exp(-yieldMaturity*(1+32/365)));

futureCoupon1to4 = C*N/4;
futureCoupon5 = C*N*(32/365);
totalCoupon = futureCoupon1to4*4 + futureCoupon5;

discountedCoupon1 = C*N/4*exp(-yieldm3*0.25);
discountedCoupon2 = C*N/4*exp(-yieldm6*0.5);
discountedCoupon3 = C*N/4*exp(-yieldm9*0.75);
discountedCoupon4 = C*N/4*exp(-yieldy1);
discountedCoupon5 = C*N*(32/365)*exp(-yieldMaturity*(1+32/365));

fprintf('Risk free interest rates are:\n')
fprintf(' -3 month  - %.2f percent\n',yieldm3*100);
fprintf(' -6 month  - %.2f percent\n',yieldm6*100);
fprintf(' -9 month  - %.2f percent (linear interpolation)\n',yieldm9*100);
fprintf(' -1 year   - %.2f percent\n',yieldy1*100);
fprintf(' -Maturity - %.2f percent (linear interpolation)\n',yieldMaturity*100);
fprintf('Taking these interest rate yields into account, we will be able to pay out 4 future periodic coupons that are each worth %.4fUSD plus an additional coupon at maturity that is worth %.2fUSD.\n',futureCoupon1to4,futureCoupon5);
fprintf('In more detail:\n');
fprintf(' - %.4fUSD of the %.2fUSD on the bankaccount at issue date will be used to pay out %.4fUSD on Mar. 14th 2015\n',discountedCoupon1,pvCoupon,futureCoupon1to4);
fprintf(' - %.4fUSD of the %.2fUSD on the bankaccount at issue date will be used to pay out %.4fUSD on Jun. 14th 2015\n',discountedCoupon2,pvCoupon,futureCoupon1to4);
fprintf(' - %.4fUSD of the %.2fUSD on the bankaccount at issue date will be used to pay out %.4fUSD on Sep. 14th 2015\n',discountedCoupon3,pvCoupon,futureCoupon1to4);
fprintf(' - %.4fUSD of the %.2fUSD on the bankaccount at issue date will be used to pay out %.4fUSD on Dec. 14th 2015\n',discountedCoupon4,pvCoupon,futureCoupon1to4);
fprintf(' - %.4fUSD of the %.2fUSD on the bankaccount at issue date will be used to pay out %.4fUSD on Jan. 15th 2016\n',discountedCoupon5,pvCoupon,futureCoupon5);
fprintf('This corresponds to a total coupon payment of %.2fUSD or an annualized coupon payment of %.4f percent.\n\n',totalCoupon,C*100);




%%%%%%%%%%%%%%%%%%%%%%% Graph the results and perform some analysis *****************************
pnlReverseConvertible=@(St) totalCoupon + min(N,alpha*St) - N; % pnl of the RC is payoff at maturity (including periodic coupon payments) minus notional
pnlStock = @(St) N/S0*St-N; % pnl of the stock is the amount of shares bought at time S0 multiplied by the share price at maturity, minus the initial investment
pnlRiskFree = N*exp(yieldMaturity*(1+32/365))-N; % pnl of the risk free rate. It is independent of the ebay stock price at maturity.

St=0:0.001:70; % Stock price
intersectIndex = find(pnlReverseConvertible(St)-pnlStock(St) < eps,1); % Find pnl intersection (pnlRC - pnlStock == 0)
intersectX = St(intersectIndex); intersectY = pnlReverseConvertible(intersectIndex); % X and Y coordinates of intersection

breakEvenIndex = find(abs(pnlReverseConvertible(St)) < 0.1,1); % find breakevenindex
breakEvenX = St(breakEvenIndex); % This is the stock price St at maturity for which the holder of the RC will break even

intersectRiskFreeIndex = find(pnlReverseConvertible(St)-pnlRiskFree > eps,1);
intersectRiskFree = St(intersectRiskFreeIndex); % This is the stock price St at maturity for which the holder of the RC will generate the same profit as the risk free rate (bank)

figure;
hold on;
hPnl = plot(St,pnlReverseConvertible(St),'-',St,pnlStock(St),'-');
title(sprintf('pnl of RC versus EBAY versus Risk Free Rate (investment of %.0fUSD)',N));
xlabel('Stock price St at time T (USD)') % x-axis label
ylabel('Pnl at maturity (USD)') % y-axis label

hRiskFree = graph2d.constantline(pnlRiskFree, 'LineStyle','-', 'Color','r');
changedependvar(hRiskFree,'y');
hK = graph2d.constantline(K, 'LineStyle','--', 'Color','r');
changedependvar(hK,'x');
hS0 = graph2d.constantline(S0, 'LineStyle','--', 'Color','g');
changedependvar(hS0,'x');

hPnlIntersect = plot(intersectX,intersectY,'ko','MarkerSize',8);
hBreakeven = plot(breakEvenX,0,'ro','MarkerSize',8);

legend('Reverse Convertible','EBAY inc','Risk Free Rate',sprintf('K = %.2fUSD',K),sprintf('S0 = %.2fUSD',S0),sprintf('St = %.2fUSD, pnl = %.2fUSD)',intersectX,intersectY),sprintf('St = %.2fUSD, pnl = %.2fUSD)',breakEvenX,0),'Location','northwest');

h0 = graph2d.constantline(0,'LineStyle','--', 'Color',[.7 .7 .7]);
changedependvar(h0,'y');

fprintf('Pnl of the reverse convertible versus the stock price is illustrated in the generated graph.\n');
fprintf('Note that the strike price of the Reverse Convertible (%.2fUSD) is slightly to the left of the initial ebay stock price (%.2fUSD).\n',K,S0);
fprintf('Hence, graphs are not running in parallel when the stock price at maturity is smaller than %dUSD.\n',K);
fprintf('The capital of the investor is protected a bit below the initial stock price S0.\n');
fprintf('The breakeven point is marked on the graph.\n');
fprintf('The investor will obtain a positive total return when the price of the stock at maturity is no lower than %.2fUSD.\n',breakEvenX);
fprintf('The intersection of the pnl of the RC and the pnl of the underlying stock is also marked.\n');
fprintf('The investor can invest directly in the underlying instead of the RC when (s)he assumes that the price at maturity will be higher than %.2fUSD. \n',intersectX);
fprintf('In this scenario the profit potential of the underlying stock is higher in comparison to the RC.\n');
fprintf('Risk free profit is also represented on the graph but it hangs very close to the zero profit line.\n')
fprintf('If the investor does not invest anything at time 0 but instead adds the money on his bankaccount then he would have generated the very small risk free profit of %.2fUSD.\n',pnlRiskFree);
fprintf('It is not shown on the graph but the intersection of the RC profit and the risk free profit occurs around St=%.2fUSD.\n',intersectRiskFree);
fprintf('Hence, for all St above this price the RC will generate a profit in excess of the risk free return.\n');