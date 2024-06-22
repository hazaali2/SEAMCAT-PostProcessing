function linkRatios = calculateRatios(dRSSValues, iRSSUnwantedValues, iRSSBlockingValues, linkResultsValues)
    % Initialize a container to store the calculated ratios
    linkRatios = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % Iterate through each link
    linkKeys = keys(iRSSUnwantedValues);
    for i = 1:length(linkKeys)
        linkKey = linkKeys{i};
        unwantedValues = iRSSUnwantedValues(linkKey);
        blockingValues = iRSSBlockingValues(linkKey);
        noiseFloor = linkResultsValues(linkKey);
        
        % Check if the lengths of the arrays match
        if length(dRSSValues) == length(unwantedValues) && length(dRSSValues) == length(blockingValues)
            numTrials = length(dRSSValues);
            ratiosArray = [];
            
            % Iterate through each trial
            for j = 1:numTrials
                dRSS = dRSSValues(j);
                iUnwanted = unwantedValues(j);
                iBlocking = blockingValues(j);
                N = noiseFloor;
                
                % Calculate the ratios
                ratios = calculate_ratios(dRSS, iBlocking, iUnwanted, N);
                ratiosArray = [ratiosArray; ratios];
            end
            
            % Store the calculated ratios for the link
            linkRatios(linkKey) = ratiosArray;
        else
            error('Length of dRSSValues does not match with iRSSUnwantedValues or iRSSBlockingValues for link %s.', linkKey);
        end
    end
    
    % Display the calculated ratios
    fprintf('Calculated Ratios for Links:\n');
    linkKeys = keys(linkRatios);
    for i = 1:length(linkKeys)
        fprintf('Link %s:\n', linkKeys{i});
        linkRatiosArray = linkRatios(linkKeys{i});
        for j = 1:length(linkRatiosArray)
            fprintf('  Trial %d:\n', j);
            disp(linkRatiosArray(j));
        end
    end
end

function ratios = calculate_ratios(C_dBm, I_block_dBm, I_unwanted_dBm, N_dBm)
    % C/I ratio
    C_I_block = C_dBm - I_block_dBm;
    C_I_unwanted = C_dBm - I_unwanted_dBm;
    C_I_total = C_dBm - 10 * log10(10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10));

    % C/(N+I) ratio
    C_NI_block = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10));
    C_NI_unwanted = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_unwanted_dBm/10));
    C_NI_total = C_dBm - 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10));

    % (N+I)/N ratio
    NI_N_block = 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10)) - N_dBm;
    NI_N_unwanted = 10 * log10(10^(N_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;
    NI_N_total = 10 * log10(10^(N_dBm/10) + 10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;

    % I/N ratio
    I_N_block = I_block_dBm - N_dBm;
    I_N_unwanted = I_unwanted_dBm - N_dBm;
    I_N_total = 10 * log10(10^(I_block_dBm/10) + 10^(I_unwanted_dBm/10)) - N_dBm;

    % Store ratios in a struct
    ratios = struct('C_I_block', C_I_block, 'C_I_unwanted', C_I_unwanted, 'C_I_total', C_I_total, ...
                    'C_NI_block', C_NI_block, 'C_NI_unwanted', C_NI_unwanted, 'C_NI_total', C_NI_total, ...
                    'NI_N_block', NI_N_block, 'NI_N_unwanted', NI_N_unwanted, 'NI_N_total', NI_N_total, ...
                    'I_N_block', I_N_block, 'I_N_unwanted', I_N_unwanted, 'I_N_total', I_N_total);
end