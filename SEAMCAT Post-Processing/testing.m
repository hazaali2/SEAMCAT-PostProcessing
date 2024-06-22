

filePath = 'results.xml';
xmlDoc = xmlread(filePath);
    interfererElements = xmlDoc.getElementsByTagName('interferer');
    
interferenceMappings = extractInterferenceCalculations(xmlDoc);

 [offendingInterferersList, interferersList] = extractInterferer(interfererElements, interferenceMappings.I_over_N_unwanted_blocking, -6);


    function [offendingInterferer, interferer] = extractInterferer(elements, interferenceMap, threshold)
    numElements = elements.getLength;
    offendingInterferer = zeros(numElements, 2); 
    interferer = zeros(numElements, 2); 
    countOff = 0;
    countInt = 0;
    
    for k = 0:numElements-1
        element = elements.item(k);
        linkResults = element.getElementsByTagName('linkResult');
        
        for j = 0:linkResults.getLength-1
            linkResult = linkResults.item(j);
            eventNumber = str2double(char(linkResult.getAttribute('eventNumber')));
            tx_x = char(linkResult.getAttribute('tx_x'));
            tx_y = char(linkResult.getAttribute('tx_y'));
        
            if interferenceMap(eventNumber+1) > threshold
                countOff = countOff + 1;
                offendingInterferer(countOff, :) = [str2double(tx_x), str2double(tx_y)];
            else
                countInt = countInt + 1;
                interferer(countInt, :) = [str2double(tx_x), str2double(tx_y)];
            end     
        end
    end
    
    offendingInterferer = offendingInterferer(1:countOff, :); 
    interferer = interferer(1:countInt, :); 
end