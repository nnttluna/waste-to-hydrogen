classdef Stream
    %STREAM Summary of this class goes here
    properties
        Flowrate % mol/s
        Pressure % bar
        xA       % unitless
        xB       % unitless
    end
    
    methods (Static)
        function obj = Stream(Q,P,xA,xB)
            %STREAM Construct an instance of this class
            obj.Flowrate = Q;
            obj.Pressure = P;
            obj.xA = xA/(xA+xB);
            obj.xB = 1-obj.xA;
        end
        
        function S = create_table(n)
            %METHOD1 Summary of this method goes here
            for i = 1:n
                S(i) = Stream(0,1,0.5,0.5);
            end
        end
    end
end

