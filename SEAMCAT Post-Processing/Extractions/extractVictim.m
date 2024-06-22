function [victimRx, victimTx] = extractVictim(elements)
    numElements = elements.getLength;

    % Initialize empty arrays to grow dynamically
    victimRx = []; % To hold rx_x, rx_y
    victimTx = []; % To hold tx_x, tx_y
    
    for k = 0:numElements-1
        element = elements.item(k);
        linkResults = element.getElementsByTagName('linkResult');
        
        for j = 0:linkResults.getLength-1
            linkResult = linkResults.item(j);

            rx_x = char(linkResult.getAttribute('rx_x'));
            rx_y = char(linkResult.getAttribute('rx_y'));
            tx_x = char(linkResult.getAttribute('tx_x'));
            tx_y = char(linkResult.getAttribute('tx_y'));
            
            % Append new coordinates to the arrays
            if ~isempty(rx_x) && ~isempty(rx_y)
                victimRx = [victimRx; str2double(rx_x), str2double(rx_y)];
            end
            
            if ~isempty(tx_x) && ~isempty(tx_y)
                victimTx = [victimTx; str2double(tx_x), str2double(tx_y)];
            end
        end
    end
    
    % Remove duplicates while preserving the original order
    victimRx = unique(victimRx, 'rows', 'stable');
    victimTx = unique(victimTx, 'rows', 'stable');
end
