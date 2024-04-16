function [T,Recycle,Product,Area] = StrippingSingleCompressor(Feed,nS,alpha,phi,theta,Pi)
% Create Feed Stream
F_Stripping = Stream.create_table(nS+1);
F_Stripping(1) = Feed;

% Create the Side Stream
R_Stripping = Stream.create_table(nS);

% Create Enriching Stage Membrane
for i = 1:nS
    Membrane_stripping(i) = Membr(alpha,phi(i),theta(i));
    Membrane_stripping(i) = Membr.MemCounterFlow(Membrane_stripping(i),F_Stripping(i),Pi);
    R_Stripping(i) = Membrane_stripping(i).Permeate;
    F_Stripping(i+1) = Membrane_stripping(i).Retentate;
    Area(i) = Membrane_stripping(i).Area;
end

% Create Table
S = [F_Stripping(1)];
title = ["FS0"];
for i = 1:nS
    S = [S,R_Stripping(i),F_Stripping(i+1)];
    title = [title;"RS"+num2str(i);"FS"+num2str(i)];
end

% CONSTRUCT STREAM TABLE
T.Stream = title;
T.Flowrate = [S.Flowrate]';
T.Pressure = [S.Pressure]';
T.xA = [S.xA]';
T.xB = [S.xB]';

%Recycle Stream
F = sum([R_Stripping.Flowrate]);
P = min([R_Stripping.Pressure]);
xA = sum([R_Stripping.Flowrate].*[R_Stripping.xA])/F;
xB = 1 - xA;
Recycle = Stream(F,P,xA,xB);

%Product Stream
Product = F_Stripping(nS+1);
end

