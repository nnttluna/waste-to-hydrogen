function [newAlpha,newPi,res]= EquilvalentStage(Enriched_Product,Depleted_Product,Pressure,Area)

% COLLECTING DATA FROM STREAM
QF = Enriched_Product.Flowrate + Depleted_Product.Flowrate;
yP = Enriched_Product.xA;
xR = Depleted_Product.xA;
theta = Enriched_Product.Flowrate / QF;
xF = theta * yP + (1-theta)*xR;
Smin = log(xR/xF*(1-theta))/log(((1-xR)/(1-xF))*(1-theta));

% NEW ALPHA SHOULD BE BELOW 1000
maxAlpha = 50;
flag_same_sign = func(2)*func(maxAlpha);
if flag_same_sign > 0
    msgbox('over');
    newAlpha = Smin;
else
    newAlpha = fzero(@func,[2,maxAlpha]);
    %newAlpha = Smin;

end


[~,W,~] = counterflow(xF,newAlpha,Pressure,theta);
newPi = W * QF / (Pressure * 1e5 * Area);

res = abs(func(newAlpha))

% Choose alpha to fit the data or RET and PER
    function res = func(alpha)
    [yP1,~,esp] = counterflow(xF,alpha,Pressure,theta);
    res = (yP-yP1);
    end
end