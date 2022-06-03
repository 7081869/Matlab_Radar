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
angle_tolerance = 10;
appearance_border=6;
max_objects = 10;

Object_count = 0;
zugeordnet = false;
position=1;
%%
clear object_array
clear output_array
for k = 1:max_objects
    object_array(k) = Target;
end

for x=1:20
    for y = 1:3
        %Mit bisher Vorhandenen Objekten vergleichen, wenn kein Treffer
        %gefunden neues Objekt erstellen
        if ~isnan(range(x,y))
            zugeordnet = false;
            for k = 1:Object_count
                if Nearto(range(x,y), object_array(k).averagerange, Range_tolerance, angle(x,y), object_array(k).averageangle, angle_tolerance)
                    object_array(k).Count = object_array(k).Count+1;
                    object_array(k).Werterange(object_array(k).Count)=range(x,y);
                    object_array(k).Werteangle(object_array(k).Count)=angle(x,y);
                    fprintf('Wert %f zu Durchschnitt %f hinzugef�gt, Winkel %f zu Durchschnitt %f hinzugef�gt; Objekt %d\n', range(x,y), object_array(k).averagerange,angle(x,y), object_array(k).averageangle, Object_count)
               
                    object_array(k).averagerange=object_array(k).Buildaveragerange();
                    object_array(k).averageangle=object_array(k).Buildaverageangle();
                    zugeordnet = true;
                    
                    break;

                end
            end
            if not(zugeordnet)
                if Object_count>=max_objects
                    disp('Zu viele Fehlerhafte Targets Erkannt')
                    break;
                else
                   Object_count = Object_count +1;
                   object_array(Object_count).Count = 1;
                   object_array(Object_count).Werterange(1) = range(x,y);
                   object_array(Object_count).Werteangle(1) = angle(x,y);
                   object_array(Object_count).InUse = true;
                   object_array(Object_count).averagerange=object_array(Object_count).Buildaveragerange();
                   object_array(Object_count).averageangle=object_array(Object_count).Buildaverageangle();
                   fprintf('Neues Objekt erstellt an Position %d mit Wert %f und Winkel %f\n', Object_count, range(x,y), angle(x,y))
                end   
            end
        end
    end
end
for k = 1:max_objects
    output_array(k) = FTarget;
end
for k = 1:max_objects
    if object_array(k).Count >= appearance_border
        output_array(position).range = object_array(k).averagerange;
        output_array(position).angle = object_array(k).averageangle;
        position = position +1;
    end
end
object_array;
