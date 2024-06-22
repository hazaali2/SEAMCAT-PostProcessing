function [victimRx, victimTx, offendingInterferers, interferers] = extractLocations(xmlDoc, interferenceMap, threshold)
    % Extract victims and interferers
    victimElements = xmlDoc.getElementsByTagName('victim');
    interfererElements = xmlDoc.getElementsByTagName('interferer');
    
    % Extract victim coordinates without conversion
    [victimRxList, victimTxList] = extractVictim(victimElements);
    
    % Initialize empty arrays in case of no victims
    victimRx = [];
    victimTx = [];

    if ~isempty(victimRxList)
        victimRx = victimRxList;
    end

    if ~isempty(victimTxList)
        victimTx = victimTxList;
    end

    % Extract coordinates for offendingInterferers and interferers without conversion
    [offendingInterferersList, interferersList] = extractInterferer(interfererElements, interferenceMap, threshold);

    offendingInterferers = [];
    interferers = [];

    if ~isempty(offendingInterferersList)
        offendingInterferers = offendingInterferersList;
    end

    if ~isempty(interferersList)
        interferers = interferersList(:, 1:2);
    end
end
