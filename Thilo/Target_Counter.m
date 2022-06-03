% Joshua und Thilo Radar Target Counter 

% Diese Datei bekommt in einem andauernden Array Objekte der Klasse FTarget �bergeben 
% Sie wertet dann aus, ob diese aus dem Eingangsbereich oder Raum kommen.
% Anhand dessen und wann das Objekt verschwindet, wird der Counter ge�ndert
% Targets m�ssen gespeichert werden und Neue Targets m�ssen entweder neu angelegt werden, 
% wenn Sie das erste Mal in einen der Erkennungsbereiche gefunden werden, 
% mit alten verglichen werden und die Werte aktualisiert werden oder alte Targets dann gel�scht werden 
% und ein Fehler oder der Counter ge�ndert werden

clc;
clear all;

Room_Counter = 0;
Max_RealTargets = 3;

%�bergangsgrenzen
Entrance_LowRangeLimit = 6;  
Entrance_HighRangeLimit = 7;
Room_LowRangeLimit = 2;
Room_HighRangeLimit = 3;

DetectionDistance = 1; 
%max. Abstand zwischen altem und neuem Target, dass er noch als gleiches target erkannt wird 

clear k
%dann mit durchlauf counter ersetzen oder nur beim ersten Durchlauf 
%Targets_aktuell initialisieren
for k = 1:3

    %hier �bergabe neue Targets
    clear i
    for i = 1:Max_RealTargets
        Targets(i) = FTarget;
        Targets(i).range = 1.25*i + k;
        Targets(i).angle = (i * 10) - k;
        Targets(i).speed = i - 2;
        Targets(i).origin = "Not available";
    end

    %hier abgleich mit alten targets

    clear i
    for i = 1:Max_RealTargets
        if k == 1
        Targets_aktuell(i) = Targets(i);
        else
            clear j
            min_Difference_Location = Max_RealTargets + 1; %speichert wo geringste �nderung Range
            min_Difference = DetectionDistance + 0.1; %speichert die min Difference
            
            %sucht das n�chste Target
            for j = 1:Max_RealTargets
                Difference = abs(Targets_aktuell(i).range - Targets(j).range)
                if Difference <= DetectionDistance && Difference < min_Difference
                  min_Difference = Difference;
                  min_Difference_Location = j;                    
                end    
            end
            
            if min_Difference_Location ==  Max_RealTargets + 1
               fprintf("Target mit Range %.4d nicht mehr findbar, gel�scht", Targets_aktuell(i).range)
                clear Targets_aktuell(i) 
            else
                fprintf("Neues Target Range %.4d = Altes Target Range %.4d", Targets(min_Difference_Location).range, Targets_aktuell(i).range)
                Targets_aktuell(i).range = Targets(min_Difference_Location).range;
                Targets_aktuell(i).speed = Targets(min_Difference_Location).speed;
                Targets_aktuell(i).angle = Targets(min_Difference_Location).angle;
            end
            
        end
    end


    %Hier Logik und Output
    clear i
    for i = 1:Max_RealTargets
        if Targets_aktuell(i).range > Entrance_HighRangeLimit
           fprintf("Target out, Upper Range\n")
           if Targets_aktuell(i).origin == "Lower"
            Room_Counter = Room_Counter - 1;
            fprintf("Target left\nCounter: %d", Room_Counter);
            clearvars Targets_aktuell(i)
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
            clearvars Targets_aktuell(i);
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
            clearvars Targets_aktuell(i)
           end
        end
    end
end
