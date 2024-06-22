function [victimRx, victimTx, offendingInterferers, interferers] = extractLocationsUsingTerrain(xmlDoc, interferenceMap, threshold, refLat, refLon, templateScenario)
    mstruct = initMapProjection(refLat, refLon);

    victimElements = xmlDoc.getElementsByTagName('victim');
    interfererElements = xmlDoc.getElementsByTagName('interferer');

    [victimRxList, victimTxList] = extractVictim(victimElements);

    victimRx = [];
    victimTx = [];

    if ~isempty(victimRxList)
        victimRx = convertXYtoLatLon(mstruct, victimRxList);
    end

    if ~isempty(victimTxList)
        victimTx = convertXYtoLatLon(mstruct, victimTxList);
    end

    if (templateScenario)
        [offendingInterferersList, interferersList] = extractInterfererTemplateScenario(interfererElements, interferenceMap, threshold);
    else
        [offendingInterferersList, interferersList] = extractInterferer(interfererElements, interferenceMap, threshold);
    end

    offendingInterferers = [];
    interferers = [];

    if ~isempty(offendingInterferersList)
        offendingInterferers = convertXYtoLatLon(mstruct, offendingInterferersList);
        offendingInterferers = [offendingInterferers, offendingInterferersList(:, 3)];
    end

    if ~isempty(interferersList)
        interferers = convertXYtoLatLon(mstruct, interferersList);
        interferers = [interferers, interferersList(:, 3)];
    end
end

function mstruct = initMapProjection(refLat, refLon)
    mstruct = defaultm("eqdazim");
    
    mstruct.geoid = referenceEllipsoid("sphere","kilometers");
   
    mstruct.origin = [refLat, refLon, 0]; % The third element, rotation, is 0
    
    mstruct = defaultm(mstruct);
end

function latLonOut = convertXYtoLatLon(mstruct, xyPairs)
    latOut = zeros(size(xyPairs, 1), 1);
    lonOut = zeros(size(xyPairs, 1), 1);
    
    for i = 1:size(xyPairs, 1)
        % Extract delta x and delta y from the input pairs
        deltaX = xyPairs(i, 1);
        deltaY = xyPairs(i, 2);
        
        % Convert x, y to latitude and longitude using inverse projection
        [lat, lon] = projinv(mstruct, deltaX, deltaY);
        
        latOut(i) = lat;
        lonOut(i) = lon;
    end
    latLonOut = [latOut, lonOut];
end
