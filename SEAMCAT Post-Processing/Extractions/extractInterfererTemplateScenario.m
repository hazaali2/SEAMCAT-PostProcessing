function [offendingInterferer, interferer] = extractInterfererTemplateScenario(elements, interferenceMap, threshold)
    numElements = elements.getLength;
    offendingInterferer = zeros(numElements, 3); 
    interferer = zeros(numElements, 3); 
    countOff = 0;
    countInt = 0;
    
    for k = 0:numElements-1
        element = elements.item(k);
        linkResults = element.getElementsByTagName('linkResult');
        
        for j = 0:linkResults.getLength-1
            linkResult = linkResults.item(j);
            tx_x = char(linkResult.getAttribute('tx_x'));
            tx_y = char(linkResult.getAttribute('tx_y'));
            interferenceValue = interferenceMap(j+1); % Capture the interference value for this event
        
            if interferenceValue > threshold
                countOff = countOff + 1;
                % Add the interference value as the third element in the row
                offendingInterferer(countOff, :) = [str2double(tx_x), str2double(tx_y), interferenceValue];
            else
                countInt = countInt + 1;
                interferer(countInt, :) = [str2double(tx_x), str2double(tx_y), interferenceValue];
            end     
        end
    end
    
    offendingInterferer = offendingInterferer(1:countOff, :);

    interferer = interferer(1:countInt, :); 

end