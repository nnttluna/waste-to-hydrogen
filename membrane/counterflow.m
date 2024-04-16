function [yP,W,esp] = counterflow(xF,alpha,phi,theta)
log_xR = fzero(@minfunc,[0,xF]);
options = optimset('Display','off','TolFun',1e-12);
%log_xR = fsolve(@minfunc,xF,options)
%log_xR = fmincon(@minfunc,(log10(xF))/15,[],[],[],[],-4,log10(xF),[],options);
xR = log_xR;
esp = (minfunc(log_xR));
yP = (xF - (1-theta)*xR)/(theta);

% MEMBRANE AREA
[qhat,x] = ode15s(@dxdq,[1, 1/(1-theta)], xR);
y(1) = 1/2*phi*(xR + 1/phi + 1/(alpha - 1) - sqrt((xR + 1/phi ...
            + 1/(alpha - 1))^2 - (4*alpha*xR)/(phi*(alpha-1))));
ws(1) = (1-theta)*phi*alpha/((alpha - 1)*(phi*x(1)-y(1)) + phi - 1);

for i = 2:length(x)
    y(i) = (qhat(i)*x(i) - xR)/(qhat(i)-1);
    ws(i) = (1-theta)*phi*alpha/((alpha - 1)*(phi*x(i)-y(i)) + phi - 1);
end

W = trapz(qhat,ws');

% SOLVE FUNCTION
function esp = minfunc(xR_est)
global x1
x1 = xR_est;
options1=odeset('RelTol',1e-8,'AbsTol',1e-8);
[~,xm] = ode15s(@dxdq,[1,1/(1-theta)], x1,options1);
xF_est = xm(length(xm));
esp = (xF - xF_est);
end

% ODE FUNCTION  
function dx = dxdq(q,x)
    dx = (-x + alpha/(alpha-1+(phi-1)/(phi*x - fy(x,q))))/q;
end

% PERMEATE COMPOSITION FUNCTION
function y = fy(x,q)
    global x1
    if q == 1
        y = 1/2*phi*(x + 1/phi + 1/(alpha - 1) - sqrt((x + 1/phi ...
            + 1/(alpha - 1))^2 - (4*alpha*x)/(phi*(alpha-1))));
    
    elseif q > 1
        y = (q*x - x1)/(q-1);
    
    else
        y = 0;
        disp('Something wrong in membrane module')
    end
        
end
end
