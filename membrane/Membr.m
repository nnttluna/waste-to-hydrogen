classdef Membr
    % THIS CLASS INCLUDES ALL EQUIPMENT NEED FOR MEMBRANE GAS SEPARATION
    
    properties
        Selectivity
        PressureRatio
        StageCut
        Feed
        Retentate
        Permeate
        Area
    end
    
    methods (Static)
        function obj = Membr(alpha,phi,theta)
            %UNTITLED Construct an instance of this class
            obj.Selectivity = alpha;
            obj.PressureRatio = phi;
            obj.StageCut = theta;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function obj = MemCounterFlow(obj,Feed,Pi)
            obj.Feed = Feed;
            [yP,W,~] = counterflow(obj.Feed.xA,obj.Selectivity,obj.PressureRatio,...
                obj.StageCut);
            xR = (obj.Feed.xA - obj.StageCut * yP)/(1-obj.StageCut);
            
            Per = Stream(obj.Feed.Flowrate*obj.StageCut,obj.Feed.Pressure/...
                obj.PressureRatio,yP,1-yP);
            obj.Permeate = Per;
            
            Ret = Stream(obj.Feed.Flowrate*(1-obj.StageCut),obj.Feed.Pressure,...
                xR,1-xR);
            obj.Retentate = Ret;
            obj.Area = (W * obj.Feed.Flowrate) / (obj.Feed.Pressure * 1e5 * Pi);
        end
        
        function OUT = Compress(IN,DischargePressure)
            OUT = Stream(0,1,0.5,0.5);
            OUT = IN;
            OUT.Pressure = DischargePressure;
        end
        
        
        function OUT = Mixer(IN1,IN2,IN3)
            OUT = Stream(0,1,0.5,0.5);
            OUT.Flowrate = IN1.Flowrate + IN2.Flowrate + IN3.Flowrate;
            OUT.Pressure = min(IN1.Pressure , IN2.Pressure);
            OUT.xA = (IN1.xA * IN1.Flowrate + IN2.xA * IN2.Flowrate + ...
                IN3.xA * IN3.Flowrate)/OUT.Flowrate;
            OUT.xB = 1 - OUT.xA;
        end
        
        function [OUT1,OUT2] = Split(IN,fraction)
            OUT1 = Stream(0,1,0.5,0.5);
            OUT2 = Stream(0,1,0.5,0.5);
            OUT1 = IN;
            OUT2 = IN;
            OUT1.Flowrate = IN.Flowrate*fraction;
            OUT2.Flowrate = IN.Flowrate*(1-fraction);
        end
        
        function esp = Recycle(IN1,IN2)
            esp_Q = abs(IN1.Flowrate - IN2.Flowrate)/IN1.Flowrate;
            esp_x = abs(IN1.xA - IN2.xA)/IN1.xA;
            esp = norm([esp_Q,esp_x]);
        end
        
        function Ws = DutyComp(Qin,Pr)
            gamma = 1.4;        % ideal gas Cv/Cp
            a = (gamma-1)/gamma;
            R = 8.314;          % Universal Constant [J/molK]
            T = 25 + 273;       % Ambient Temperature [K]
            Nstage = ceil(log10(Pr)/log10(4)); % Pressure ratio 1 stage < 4
            phi = Pr^(1/Nstage);
            Ws = Qin * R * T * (1/a) * (phi^a - 1) * Nstage * 1e-3;
        end
       
    end
end

