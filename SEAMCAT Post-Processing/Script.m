zipFilePath = 'results.swr';
extractTo = pwd;

try
    unzip(zipFilePath, extractTo);
    disp('File unzipped successfully.');
catch
    disp('Error: The file may not be a zip file or it is corrupted.');
end

filePath = 'results.xml';
xmlDoc = xmlread(filePath); % Outside function call

vectorName = 'I / N [unwanted, blocking]';
vectorElement = findVector(xmlDoc.getDocumentElement, vectorName);

eventMapping = containers.Map('KeyType', 'double', 'ValueType', 'double');

if ~isempty(vectorElement)
    valuesElement = vectorElement.getElementsByTagName('values').item(0);
    if ~isempty(valuesElement)
        values = extractValues(valuesElement);
        for eventNumber = 1:length(values)
            eventMapping(eventNumber) = values(eventNumber);
        end
    end
end

victims = xmlDoc.getElementsByTagName('victim'); 
interferers = xmlDoc.getElementsByTagName('interferer'); 

victimLinkResults = extractLinkResults(victims);
interfererLinkResults = extractLinkResults(interferers);

victim = extractValuesAndCreateTuples(victimLinkResults);

[offendingInterferer, interferer] = processInterfererLinkResults(interfererLinkResults, eventMapping);

plotScatters(interferer, offendingInterferer, victim, 25);

function linkResults = extractLinkResults(parentElements)
    numElements = parentElements.getLength;
    linkResults = []; 
    for k = 0:numElements-1
        parent = parentElements.item(k);
        linkResults = [linkResults; parent.getElementsByTagName('linkResult')]; 
    end
end

function tuplesList = extractValuesAndCreateTuples(linkResults)
    numResults = linkResults.getLength;
    tuplesList = zeros(numResults, 4); 
    count = 0;
    for k = 0:numResults-1
        linkResult = linkResults.item(k);
        rx_x = char(linkResult.getAttribute('rx_x'));
        rx_y = char(linkResult.getAttribute('rx_y'));
        tx_x = char(linkResult.getAttribute('tx_x'));
        tx_y = char(linkResult.getAttribute('tx_y'));
        
        if ~isempty(rx_x) && ~isempty(rx_y) && ~isempty(tx_x) && ~isempty(tx_y)
            count = count + 1;
            tuplesList(count, :) = [str2double(rx_x), str2double(rx_y), str2double(tx_x), str2double(tx_y)];
        end
    end
    tuplesList = unique(tuplesList(1:count, :), 'rows');
end

function [offendingInterferer, interferer] = processInterfererLinkResults(linkResults, eventMapping)
    numResults = linkResults.getLength;
    offendingInterferer = zeros(numResults, 2); 
    interferer = zeros(numResults, 2); 
    countOff = 0;
    countInt = 0;
    for k = 0:numResults-1
        linkResult = linkResults.item(k);
        eventNumber = str2double(char(linkResult.getAttribute('eventNumber')));
        tx_x = char(linkResult.getAttribute('tx_x'));
        tx_y = char(linkResult.getAttribute('tx_y'));
        if eventMapping(eventNumber+1) > -6
            countOff = countOff + 1;
            offendingInterferer(countOff, :) = [str2double(tx_x), str2double(tx_y)];
        else
            countInt = countInt + 1;
            interferer(countInt, :) = [str2double(tx_x), str2double(tx_y)];
        end
    end
    offendingInterferer = offendingInterferer(1:countOff, :); 
    interferer = interferer(1:countInt, :); 
end

function result = findVector(element, vectorName)
    result = [];
    if strcmp(element.getNodeName, 'Vector') && strcmp(element.getAttribute('name'), vectorName)
        result = element;
        return;
    end
    childNodes = element.getChildNodes;
    numChildren = childNodes.getLength;
    for i = 0:numChildren-1
        child = childNodes.item(i);
        result = findVector(child, vectorName);
        if ~isempty(result)
            return;
        end
    end
end

function values = extractValues(valuesElement)
    valuesList = valuesElement.getElementsByTagName('value');
    numValues = valuesList.getLength;
    values = zeros(1, numValues); 
    for i = 0:numValues-1
        valueElement = valuesList.item(i);
        values(i+1) = str2double(valueElement.getAttribute('value'));
    end
end

function plotScatters(interferer, offendingInterferer, victim, arrowLength)
    figure;
    hold on;

    if ~isempty(interferer)
        scatter(interferer(:, 1), interferer(:, 2), 'blue', 'DisplayName', 'Interferer');
    end

    if ~isempty(offendingInterferer)
        scatter(offendingInterferer(:, 1), offendingInterferer(:, 2), 'red', 'DisplayName', 'Offending Interferer');
    end

    if ~isempty(victim)
        scatter(victim(:, 1), victim(:, 2), 'green', 'DisplayName', 'Victim TX');
        for i = 1:size(victim, 1)
            tx_x = victim(i, 1);
            tx_y = victim(i, 2);
            rx_x = victim(i, 3);
            rx_y = victim(i, 4);

            direction_x = rx_x - tx_x;
            direction_y = rx_y - tx_y;
            length = sqrt(direction_x^2 + direction_y^2);

            if length > 0
                direction_x = (direction_x / length) * arrowLength;
                direction_y = (direction_y / length) * arrowLength;
                quiver(tx_x, tx_y, direction_x, direction_y, 0, 'MaxHeadSize', 0.5, 'Color', 'green', 'AutoScale', 'off', 'DisplayName', 'Link Direction');
            end
        end
    end

    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    title('Interferers and Victim Locations');
    legend('show');
    grid on;
    hold off;
end
