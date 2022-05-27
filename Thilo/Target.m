%Thilo Joshua
%Studienarbeit auswertung Range
%Ziel: 
%Inkonsistenzen des Sensors ausgleichen indem aus mehreren Messwerten
%Mittelwerte gebildet werden
%Vorgehen:
%Jedes vom Sensor gefundene Target wird als solches gespeichert
%Liegt ein gefundenes Target, innerhalb einer gewissen Toleranz
%(messungenauigkeit des Sensors) um ein schon gefundenes Target wird das
%Target diesem schon gefundenen Zugeordnet und ein Counter zählt hoch
%Nur wenn ein Target, innerhalb der Frames, oft genug gefunden wurde, wird
%das Target betrachtet

%%Klasse Target 
classdef Target
    properties(Access = public)
        Count
        average
        Werte = zeros(20, 1);
        InUse = false;
    end 
    methods (Access = public)
        function av = Buildaverage(this)
            count=0;
            Sum=0;
            for i=1:20
                if this.Werte(i)~=0
                    count = count +1;
                    Sum = Sum + this.Werte(i);
                end
            end
            av = Sum / count;
        end
    end
end
