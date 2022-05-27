%% Target Counter
% Joshua und Thilo 
% Diese Datei bekommt in einem andauernden Array Objekte der Klasse FTarget übergeben 
% Sie wertet dann aus, ob diese aus dem Eingangsbereich oder Raum kommen.
% Anhand dessen und wann das Objekt verschwindet, wird der Counter geändert
% Targets müssen gespeichert werden und Neue Targets müssen entweder neu angelegt werden, 
% wenn Sie das erste Mal in einen der Erkennungsbereiche gefunden werden, 
% mit alten verglichen werden und die Werte aktualisiert werden oder alte Targets dann gelöscht werden 
% und ein Fehler oder der Counter geändert werden
clc;
clear all;
close all;

Room_Counter = 0;
Max_RealTargets = 1;

%Übergangsgrenzen
Entrance_LowRangeLimit = 6;  
Entrance_HighRangeLimit = 7;
Room_LowRangeLimit = 2;
Room_HighRangeLimit = 3;

%Hier kommen die Werte und Anzahl von Targets
clear k
for k = 1:Max_RealTargets
    RealTarget(k) = FTarget;
    RealTarget(k).range = 2.5;

    % Verbindung schaffen zu möglichen alten Target
    RealTarget(k).origin = "Not available";
    
    
    %Logik
    if RealTarget(k).range > Entrance_HighRangeLimit
       fprintf("Target out, Upper Range\n")
       if RealTarget(k).origin == "Lower"
        Room_Counter = Room_Counter - 1;
        fprintf("Target left\nCounter: %d", Room_Counter);
       end
    end
    
    if (RealTarget(k).range <= Entrance_HighRangeLimit) && (RealTarget(k).range >= Entrance_LowRangeLimit)
       fprintf("Target in Entrance Area\n")
       if RealTarget(k).origin == "Not available"
       RealTarget(k).origin = "Upper"
       end
    end

    if (RealTarget(k).range > Room_HighRangeLimit) && (RealTarget(k).range < Entrance_LowRangeLimit)
       fprintf("Target in Supervision Area\n")
    end

    if (RealTarget(k).range >= Room_LowRangeLimit) && (RealTarget(k).range <= Entrance_HighRangeLimit)
       fprintf("Target in Entrance Area\n")
       if RealTarget(k).origin == "Not available"
       RealTarget(k).origin = "Lower"
       end
    end

    if (RealTarget(k).range < Room_LowRangeLimit)
       fprintf("Target out, Lower Range\n")
       if RealTarget(k).origin == "Upper"
        Room_Counter = Room_Counter + 1;
        fprintf("Target entered\nCounter: %d", Room_Counter);
       end
    end
end




