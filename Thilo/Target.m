%Thilo Joshua
%Studienarbeit auswertung Range
%Ziel: 
%Inkonsistenzen des Sensors ausgleichen indem aus mehreren Messwerten
%Mittelwerte gebildet werden
%Vorgehen:
%Jedes vom Sensor gefundene Target wird als solches gespeichert
%Liegt ein gefundenes Target, innerhalb einer gewissen Toleranz
%(messungenauigkeit des Sensors) um ein schon gefundenes Target wird das
%Target diesem schon gefundenen Zugeordnet und ein Counter z�hlt hoch
%Nur wenn ein Target, innerhalb der Frames, oft genug gefunden wurde, wird
%das Target betrachtet

%%Klasse Target 
classdef Target
    properties(Access = public)
        Count
        averagerange
        Werterange = zeros(20, 1);
        averageangle
        Werteangle = zeros(20, 1);
        InUse = false;
    end 
    methods (Access = public)
        function avr = Buildaveragerange(this)
            countr=0;
            Sumr=0;
            for i=1:20
                if this.Werterange(i)~=0
                    countr = countr +1;
                    Sumr = Sumr + this.Werterange(i);
                end
            end
            avr = Sumr / countr;
        end
        function ava = Buildaverageangle(this)
            counta=0;
            Suma=0;
            for i=1:20
                if this.Werteangle(i)~=0
                    counta = counta +1;
                    Suma = Suma + this.Werteangle(i);
                end
            end
            ava = Suma / counta;
        end
    end
end
