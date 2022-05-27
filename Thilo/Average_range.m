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
%% Variablen speichern
Range_tolerance = 1; %In Metern
Object_count = 0;
max_objects = 10;
zugeordnet = false;
%%

for k = 1:max_objects
    object_array(k) = Target;
end

for x=1:20
    for y = 1:3
        %Mit bisher Vorhandenen Objekten vergleichen, wenn kein Treffer
        %gefunden neues Objekt erstellen
        zugeordnet = false;
        for k = 1:Object_count
        disp('Objekt_: ')
        
            if Nearto(range(x,y), object_array(k).average, Range_tolerance)
                object_array(k).Count = object_array(k).Count+1;
                object_array(k).Werte(object_array(k).Count)=range(x,y);
                object_array(k).Buildaverage();
                zugeordnet = true;
                break
            
            end
        end
        if not(zugeordnet)
            if Object_count>=max_objects
                disp('Zu viele Fehlerhafte Targets Erkannt')
            else
               Object_count = Object_count +1;
               object_array(Object_count).Count = 1;
               object_array(Object_count).Werte(1) = range(x,y);
               object_array(Object_count).InUse = true;
               object_array(Object_count).Buildaverage();
            end   
        end
    end
end
