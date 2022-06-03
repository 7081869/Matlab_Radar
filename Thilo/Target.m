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
        Count;
        averagerange;
        Werterange = NaN(20, 1);
        averageangle;
        Werteangle = NaN(20, 1);
        InUse = false;
        Wertespeed = NaN(20, 1);
        averagespeed;
    end 
    methods (Access = public)
        function avr = Buildaveragerange(this)
            countr=0;
            Sumr=0;
            for i=1:20
                if ~isnan(this.Werterange(i))
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
                if ~isnan(this.Werteangle(i))
                    counta = counta +1;
                    Suma = Suma + this.Werteangle(i);
                end
            end
            ava = Suma / counta;
        end
        function avs = Buildaveragespeed(this)
            counts=0;
            Sums=0;
            for i=1:20
                if ~isnan(this.Wertespeed(i))
                    counts = counts +1;
                    Sums = Sums + this.Wertespeed(i);
                end
            end
            avs = Sums / counts;
        end
    end
end
