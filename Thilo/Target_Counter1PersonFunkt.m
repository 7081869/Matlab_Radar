% Joshua und Thilo Radar Target Counter 

% Diese Datei bekommt in einem andauernden Array Objekte der Klasse FTarget übergeben 
% Sie wertet dann aus, ob diese aus dem Eingangsbereich oder Raum kommen.
% Anhand dessen und wann das Objekt verschwindet, wird der Counter geändert
% Targets müssen gespeichert werden und Neue Targets müssen entweder neu angelegt werden, 
% wenn Sie das erste Mal in einen der Erkennungsbereiche gefunden werden, 
% mit alten verglichen werden und die Werte aktualisiert werden oder alte Targets dann gelöscht werden 
% und ein Fehler oder der Counter geändert werden

clc;
clear all;

Room_Counter = 0;
Max_RealTargets = 1;

%Übergangsgrenzen
Entrance_LowRangeLimit = 6;  
Entrance_HighRangeLimit = 7;
Room_LowRangeLimit = 2;
Room_HighRangeLimit = 3;

DetectionDistance = 1; 
%max. Abstand zwischen altem und neuem Target, dass er noch als gleiches target erkannt wird 

min_Difference_Location = NaN(Max_RealTargets,Max_RealTargets); %speichert gültige kleine Sbtandsdifferenz werte
Difference = NaN(Max_RealTargets,Max_RealTargets); %speichert die Difference

clear k
%dann mit durchlauf counter ersetzen oder nur beim ersten Durchlauf 
%Targets_aktuell initialisieren
for k = 1:11
fprintf("Room Counter = %d", Room_Counter);
    %hier Übergabe neue Targets
    for i = 1:Max_RealTargets
        Targets(i) = FTarget;
        if i == 1
        Targets(i).range = 7 - 0.5*k;
        else
        Targets(i).range = 2 + 0.5*k;
        end
        
        Targets(i).angle = (i * 10) - k;
        Targets(i).speed = i - 2;
        Targets(i).origin = "Not available";
        range = Targets(i).range
    end

    %hier abgleich mit alten targets

    for i = 1:Max_RealTargets
        
        if k == 1
        Targets_aktuell(i) = Targets(i);
        else
            clear j
                                   
            %sucht das nächste Target, minimaler Abstand suchen
            for j = 1:Max_RealTargets
                Difference(i,j) = abs(Targets_aktuell(i).range - Targets(j).range)
                if (Difference(i,j) <= DetectionDistance) && (~isnan(Difference(i,j)))
                               
                  min_Difference_Location(i,j) = Difference(i,j)    
                  %hier werden schon nur die gefilterten Werte gespeichert
                end    
            end
                                    
        end
    end

    
     
    if k > 1
        
     %Wo ist der minimalste Abstand?
        minValue = 0;
        minRow = 0;
        minColumn = 0;
        minValue = min(min_Difference_Location,[],2,'omitnan')
       [minRow, minColumn] = find(min_Difference_Location == minValue)
        
    for i = 1:Max_RealTargets
        
        
        %Zuweisung neue an aktuell Targets, wenn altes Target gelöscht ist
        if isnan(Targets_aktuell(i).range) &&  isnan(Targets_aktuell(i).speed) && isnan(Targets_aktuell(i).angle) && isnan(Targets_aktuell(i).origin)
            Targets_aktuell(i) = Targets(i);
        else
            
        
        %Zuweisung minimaler Abstand
            if minColumn ~= 0           
            fprintf("Neues Target Range %.4f = Altes Target Range %.4f\n", Targets(minColumn(i)).range, Targets_aktuell(i).range)
            Targets_aktuell(i).range = Targets(minColumn(i)).range;
            Targets_aktuell(i).speed = Targets(minColumn(i)).speed;
            Targets_aktuell(i).angle = Targets(minColumn(i)).angle;
            else
            fprintf("Target mit Range %.4f nicht mehr findbar, gelöscht\n", Targets_aktuell(i).range)
            Targets_aktuell(i) = clearTarget(Targets_aktuell(i)); 
            end
        end
    end
     %wenn kein passendes Target gefunden wurde, neue Zuweisung
    end
    
     
    
    %Hier Logik und Output
    clear i
    for i = 1:Max_RealTargets
        if Targets_aktuell(i).range > Entrance_HighRangeLimit
           fprintf("Target out, Upper Range\n")
           if Targets_aktuell(i).origin == "Lower"
            Room_Counter = Room_Counter - 1;
            fprintf("Target left\nCounter: %d", Room_Counter);
           Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
           end
        end

        if (Targets_aktuell(i).range <= Entrance_HighRangeLimit) && (Targets_aktuell(i).range >= Entrance_LowRangeLimit)
           fprintf("Target in Entrance Area\n")
           if Targets_aktuell(i).origin == "Not available"
            Targets_aktuell(i).origin = "Upper";
           end
        end

        if (Targets_aktuell(i).range > Room_HighRangeLimit) && (Targets_aktuell(i).range < Entrance_LowRangeLimit)
           fprintf("Target in Supervision Area\n")
           if Targets_aktuell(i).origin == "Not available"
            fprintf("Error: Target appeared in the middle, Target deleted\n");
           Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
           end
        end

        if (Targets_aktuell(i).range >= Room_LowRangeLimit) && (Targets_aktuell(i).range <= Room_HighRangeLimit)
           fprintf("Target in Room Area\n")
           if Targets_aktuell(i).origin == "Not available"
            Targets_aktuell(i).origin = "Lower";
           end
        end

        if (Targets_aktuell(i).range < Room_LowRangeLimit)
           fprintf("Target out, Lower Range\n")
           if Targets_aktuell(i).origin == "Upper"
            Room_Counter = Room_Counter + 1;
            fprintf("Target entered\nCounter: %d", Room_Counter);
           Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
           end
        end
    end
end
