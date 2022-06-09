 %% Target Counter für Präsentation
clc;
clear all; 
close all;
 
Room_Counter = 0;
Max_RealTargets = 2;

%Übergangsgrenzen
Entrance_LowRangeLimit = 6;  
Entrance_HighRangeLimit = 7;
Room_LowRangeLimit = 2;
Room_HighRangeLimit = 3;

DetectionDistance = 1; 
%max. Abstand in m zwischen altem und neuem Target, dass er noch als gleiches target erkannt wird 
AngleDetectionDistance = 10;

min_Difference_Location = NaN(Max_RealTargets,Max_RealTargets); %speichert gültige kleine Abtandsdifferenz werte
Difference = NaN(Max_RealTargets,Max_RealTargets); %speichert die Differenz der Distance
min_Difference_Angle = NaN(Max_RealTargets,Max_RealTargets); %speichert gültige kleine Winkeldifferenzen
Angle_Difference = NaN(Max_RealTargets,Max_RealTargets); %speichert die Differenz der Angle
    
for i = 1:Max_RealTargets
Targets_aktuell(i) = FTarget;
Targets(i) = FTarget;
end

assignable = 0;
isMinColumnAvailable = 0;
position = 2;
counter = 20;

for k = 1:12
    counter = counter +1;
    fprintf("Room Counter = %d\n", Room_Counter);
                %hier Übergabe neue Targets
                %position = position - 1;
                
                
                for i = 1:position
                    if i == 1
                        Targets(i).range = 7 - 0.5*k;
                    else
                        Targets(i).range = 2 + 0.5*k;
                        if k >= 7 
                            Targets(i).range = 6;
                        end
                    end

                        Targets(i).angle = (i * 10) - k;
                        Targets(i).speed = i - 2;
                
                    NewTargetRange = Targets(i).range
                    NewTargetAngle = Targets(i).angle
                end

                %Erster Durchlauf
                if counter == 21
                    for i = 1:position
                    Targets_aktuell(i) = Targets(i);
                    end
                end
                
                if counter > 21
                    min_Difference_Location = NaN(position,position);
                    min_Difference_Angle = NaN(position,position);
                    Difference = NaN(position,position);
                    Angle_Difference = NaN(position,position);

                    %hier abgleich mit alten targets
                    for i = 1:position                             
                            %sucht das nächste Target, minimaler Abstand suchen
                            for j = 1:position
                                Difference(i,j) = abs(Targets_aktuell(i).range - Targets(j).range);
                                Angle_Difference(i,j) = abs(Targets_aktuell(i).angle - Targets(j).angle);

                                if (Difference(i,j) <= DetectionDistance) && (~isnan(Difference(i,j))) ...
                                  && (Angle_Difference(i,j) <= AngleDetectionDistance) && (~isnan(Angle_Difference(i,j)))

                                  min_Difference_Location(i,j) = Difference(i,j);
                                  min_Difference_Angle(i,j) = Angle_Difference(i,j);
                                  %hier werden schon nur die gefilterten Werte gespeichert
                                end    
                            end
                    end

                 %Wo ist der minimalste Abstand?
                    minValue = -1;
                    minRow = 0;
                    minColumn = 0;
                    minValue = min(min_Difference_Location,[],2,'omitnan');
                   [minRow, minColumn] = find(min_Difference_Location == minValue);
                    assignment_Counter = 0;
                    
                    for i = 1:position

                       if i<size(minColumn, 1)
                        %Überprüfung ob neue Targets 2 mal zugeordnet werden 
                        j = i + 1;    
                            for k = j:size(minColumn, 1)
                                if minColumn(i) == minColumn(k)
                                    % falls gleiche Spalten, nach anderem
                                    % nahen objekt suchen, sonst löschen
                                    % fprintf("Target mit Range %.4f gelöscht, doppelt nahe distanz\n", Targets_aktuell(k).range)
                                    fprintf("2 Targets sehr nah aneindander\n");
                                    % Targets_aktuell(k) = clearTarget(Targets_aktuell(k)); %%2. Target in der Nähe löschen
                                end
                            end
                            clear j;
                        end
                        %Zuweisung neue an aktuell Targets, wenn altes Target gelöscht ist
                        if ~(isnan(Targets_aktuell(i).range) &&  isnan(Targets_aktuell(i).speed) && isnan(Targets_aktuell(i).angle) && (Targets_aktuell(i).origin == ""))
                            %Zuweisung minimaler Abstand
                            assignment_Counter = assignment_Counter +1;
                            assignable = (size(minColumn, 1) >= assignment_Counter);

                            if assignable        
                                fprintf("Neues Target Range %.4f = Altes Target Range %.4f\n", Targets(minColumn(assignment_Counter)).range, Targets_aktuell(i).range)
                                Targets_aktuell(i).range = Targets(minColumn(assignment_Counter)).range;
                                Targets_aktuell(i).speed = Targets(minColumn(assignment_Counter)).speed;
                                Targets_aktuell(i).angle = Targets(minColumn(assignment_Counter)).angle;                            
                            end
                        else
                            %  Zuweisung frische Targets
                            Targets_aktuell(i) = Targets(i);
                            fprintf("Neues Target mit Range %.4f\n", Targets_aktuell(i).range)
                        end
                      
                    end
                 end

                    %Hier werden alte Targets gelöscht, die nicht mehr zuweisbar sind 
                    if position < Max_RealTargets
                        for j = position+1:Max_RealTargets
                           % fprintf("Target mit Range %.4f nicht mehr findbar, gelöscht\n", Targets_aktuell(j).range)
                            Targets_aktuell(j) = clearTarget(Targets_aktuell(j)); 
                            %Target gelöscht, wenn nicht mehr sichtbar
                            clear figure(j)
                        end
                     end

                %Hier Logik und Output und Visualierung 
                for i = 1:position
                    
                set(gcf,'color','w'); % Set Background color white
                figure(i)
                polarplot(deg2rad(Targets_aktuell(i).angle), Targets_aktuell(i).range, 'o')
                legendstr = sprintf('Origin is %s\nCurrent Speed is %f', Targets_aktuell(i).origin, Targets_aktuell(i).speed);
                legend(legendstr)
                titlestr = sprintf("Room Counter = %d", Room_Counter);
                title(titlestr)
                ax = gca;
                ax.ThetaZeroLocation = 'Top';
                
                 if Targets_aktuell(i).range > Entrance_HighRangeLimit
                       fprintf("Target outside, Upper Range\n")
                       if Targets_aktuell(i).origin == "Lower"
                        Room_Counter = Room_Counter - 1;
                        fprintf("Target left\nCounter: %d", Room_Counter);
                       Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end

                    if (Targets_aktuell(i).range <= Entrance_HighRangeLimit) && (Targets_aktuell(i).range >= Entrance_LowRangeLimit)
                       fprintf("Target in Entrance Area\n")
                       if Targets_aktuell(i).origin == ""
                            Targets_aktuell(i).origin = "Upper";
                       end
                    end

                    if (Targets_aktuell(i).range > Room_HighRangeLimit) && (Targets_aktuell(i).range < Entrance_LowRangeLimit)
                       fprintf("Target in Supervision Area\n")
                       if Targets_aktuell(i).origin == ""
                            fprintf("Error: Target appeared in the middle, Target deleted\n");
                            Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end

                    if (Targets_aktuell(i).range >= Room_LowRangeLimit) && (Targets_aktuell(i).range <= Room_HighRangeLimit)
                       fprintf("Target in Room Area\n")
                       if Targets_aktuell(i).origin == ""
                        Targets_aktuell(i).origin = "Lower";
                       end
                    end

                    if (Targets_aktuell(i).range < Room_LowRangeLimit)
                       fprintf("Target outside, Lower Range\n")
                       if Targets_aktuell(i).origin == "Upper"
                        Room_Counter = Room_Counter + 1;
                        fprintf("Target entered\nCounter: %d", Room_Counter);
                       Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end
                end
end