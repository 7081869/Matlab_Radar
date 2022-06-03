function Targets_aktuell = clearTarget(Targets_aktuell)
%clearTarget Resets Data to NaN
    Targets_aktuell.range = NaN;
    Targets_aktuell.angle = NaN;
    Targets_aktuell.speed = NaN;
    Targets_aktuell.origin = NaN;
end

