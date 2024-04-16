function [StreamTable,Enriched_Product,Depleted_Product,TotalArea,esp,elops] = SingleCompressor(Feed,nS,nE,alpha,phi_F,theta_F,phi_E,theta_E,phi_S,theta_S,CompressPressure,maxint,crit,Pi)
%INITIAL CONDITION
Recycle = Stream(0,1,0.5,0.5);
esp = 0;

% FEED STAGE
F0 = Membr.Compress(Feed,CompressPressure);
for elops = 1:maxint
Membrane_Feed = Membr(alpha,phi_F,theta_F);
Membrane_Feed = Membr.MemCounterFlow(Membrane_Feed,F0,Pi);
FS0 = Membrane_Feed.Retentate;
FE0 = Membrane_Feed.Permeate;
Area_F = Membrane_Feed.Area;
% Enrichinh Section
if nE == 0   
    TE.Stream = ["FE0"]';
    TE.Flowrate = [FE0.Flowrate]';
    TE.Pressure = [FE0.Pressure]';
    TE.xA = [FE0.xA]';
    TE.xB = [FE0.xB]';
    REnrich = Stream(0,1,0.5,0.5);
    Enriched_Product = FE0;
    Area_E = [];
else
    [TE,REnrich,Enriched_Product,Area_E] = EnrichingSingleCompressor(FE0,nE,alpha,phi_E,theta_E,Pi);
end

% Stripping Section
if nS == 0
    TS.Stream = ["FS0"]';
    TS.Flowrate = [FS0.Flowrate]';
    TS.Pressure = [FS0.Pressure]';
    TS.xA = [FS0.xA]';
    TS.xB = [FS0.xB]';
    RStrip = Stream(0,1,0.5,0.5);
    Depleted_Product = FS0;
    Area_S = [];
else
    [TS,RStrip,Depleted_Product,Area_S] = StrippingSingleCompressor(FS0,nS,alpha,phi_S,theta_S,Pi);
end



% Mixing Stage
Recycle = Membr.Mixer(Feed,RStrip,REnrich);
esp = Membr.Recycle(Recycle,F0);
    if esp < crit
        break
    end
F0 = Membr.Compress(Recycle,CompressPressure);
end

% Stream Table
S = [Feed,F0,RStrip,REnrich];
T.Stream = ["Feed","F0","RStrip","REnrich"]';
T.Flowrate = [S.Flowrate]';
T.Pressure = [S.Pressure]';
T.xA = [S.xA]';
T.xB = [S.xB]';

StreamTable.Stream = [T.Stream;TS.Stream;TE.Stream];
StreamTable.Flowrate = [T.Flowrate;TS.Flowrate;TE.Flowrate];
StreamTable.Pressure = [T.Pressure;TS.Pressure;TE.Pressure];
StreamTable.xA = [T.xA;TS.xA;TE.xA];
StreamTable.xB = [T.xB;TS.xB;TE.xB];

TotalArea = [Area_F , Area_S , Area_E];
end















