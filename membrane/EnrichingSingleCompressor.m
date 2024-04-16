function [T,Recycle,Product,Area] = EnrichingSingleCompressor(Feed,nE,alpha,phi,theta,Pi)

% Create Feed Stream
F_Enriching = Stream.create_table(nE+1);
F_Enriching(1) = Feed;

% Create the Side Stream
R_Enriching = Stream.create_table(nE);

% Create Area Vector


% Create Enriching Stage Membrane
for i = 1:nE
    Membrane_enriching(i) = Membr(alpha,phi(i),theta(i));
    Membrane_enriching(i) = Membr.MemCounterFlow(Membrane_enriching(i),F_Enriching(i),Pi);
    R_Enriching(i) = Membrane_enriching(i).Retentate;
    F_Enriching(i+1) = Membrane_enriching(i).Permeate;
    Area(i) = Membrane_enriching(i).Area;
end

% Create Table
S = [F_Enriching(1)];
title = ["FE0"];
for i = 1:nE
    S = [S,R_Enriching(i),F_Enriching(i+1)];
    title = [title;"RE"+num2str(i);"FE"+num2str(i)];
end

% CONSTRUCT STREAM TABLE
T.Stream = title;
T.Flowrate = [S.Flowrate]';
T.Pressure = [S.Pressure]';
T.xA = [S.xA]';
T.xB = [S.xB]';

%Recycle Stream
F = sum([R_Enriching.Flowrate]);
P = min([R_Enriching.Pressure]);
xA = sum([R_Enriching.Flowrate].*[R_Enriching.xA])/F;
xB = 1 - xA;
Recycle = Stream(F,P,xA,xB);

%Product Stream
Product = F_Enriching(nE+1);
end

