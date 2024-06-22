function interferenceCalculations = extractInterferenceCalculationsTemplateScenario(xmlDoc)
    % Get all Vector elements which represent the interference values
    unwantedVectors = xmlDoc.getElementsByTagName('Vector');
    numVectors = unwantedVectors.getLength;

    % Prepare containers for interference values
    unwantedValues = [];
    blockingValues = [];
    totalInterferenceValues = [];

    % Iterate over all Vector tags
    for i = 0:numVectors-1
        vector = unwantedVectors.item(i);
        vectorName = char(vector.getAttribute('name'));
        
        % Check if this Vector tag corresponds to Unwanted or Blocking
        if contains(vectorName, 'iRSS Unwanted')
            % Extract the link number
            linkNumber = sscanf(vectorName, 'iRSS Unwanted: Link %d');
            if ~isempty(linkNumber)
                valueElement = vector.getElementsByTagName('value').item(0);
                unwantedValue = str2double(valueElement.getAttribute('value'));
                unwantedValues(linkNumber) = unwantedValue;
            end
        elseif contains(vectorName, 'iRSS Blocking')
            % Extract the link number
            linkNumber = sscanf(vectorName, 'iRSS Blocking: Link %d');
            if ~isempty(linkNumber)
                valueElement = vector.getElementsByTagName('value').item(0);
                blockingValue = str2double(valueElement.getAttribute('value'));
                blockingValues(linkNumber) = blockingValue;
            end
        end
    end

    % Calculate total interference for each link that has both unwanted and blocking values
    linkNumbers = min(length(unwantedValues), length(blockingValues));
    for j = 1:linkNumbers
        if ~isempty(unwantedValues(j)) && ~isempty(blockingValues(j))
            totalInterferenceValues(j) = unwantedValues(j) + blockingValues(j);
        else
            totalInterferenceValues(j) = NaN; % Handle cases where one of the values might be missing
        end
    end

    % Store arrays in a struct with specified field names
    interferenceCalculations.Unwanted = unwantedValues;
    interferenceCalculations.Blocking = blockingValues;
    interferenceCalculations.Unwanted_Plus_Blocking = totalInterferenceValues;
end
