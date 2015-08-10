function priceBS = BS(sigma, S0, K, r, q, T, flag) 

d_1 = (log(S0./K)+(r - q +sigma.^2./2).*T)./(sigma.*sqrt(T));
d_2 = d_1 - sigma.*sqrt(T);
priceBS = exp(-q.*T)*S0.*normcdf(d_1)-K.*exp(-r.*T).*normcdf(d_2);
priceBS(flag==1)=priceBS(flag==1)+K(flag==1).*exp(-r(flag==1).*T(flag==1))-S0.*exp(-q.*T(flag==1));
