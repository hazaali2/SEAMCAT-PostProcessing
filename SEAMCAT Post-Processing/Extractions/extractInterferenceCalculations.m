function interferenceCalculations = extractInterferenceCalculations(xmlDoc)
    % Get all Vector elements
    allVectors = xmlDoc.getElementsByTagName('Vector');
    numVectors = allVectors.getLength;

    interferenceCalculations = struct;

    for k = 0:numVectors-1
        vector = allVectors.item(k);

        % Check if the Vector is part of the "Interference Calculations" group
        if strcmp(vector.getAttribute('group'), 'Interference Calculations')
            % Extract the name attribute
            vectorName = char(vector.getAttribute('name'));

            valuesList = vector.getElementsByTagName('value');
            numValues = valuesList.getLength;
            values = zeros(1, numValues); 
            for i = 0:numValues-1
                valueElement = valuesList.item(i);
                values(i+1) = str2double(valueElement.getAttribute('value'));
            end
          
            fieldName = sanitizeVectorName(vectorName); % Parse the interference type since it has invalid matlab characters
            interferenceCalculations.(fieldName) = values;
        end
    end
end

function sanitizedVectorName = sanitizeVectorName(vectorName)
    % Insert an underscore at positions where a start bracket '[' is followed by any character
    vectorName = regexprep(vectorName, '\[(\w)', '_$1');

    % Replace "+" with "_plus_" and "/" with "_over_"
    vectorName = strrep(vectorName, '+', '_plus_');
    vectorName = strrep(vectorName, '/', '_over_');

    % Remove remaining spaces, parentheses, and brackets
    vectorName = regexprep(vectorName, '[\s\(\)\[\]]', '');

    % Replace "," with "_"
    vectorName = strrep(vectorName, ',', '_');

    % Use the result as the sanitized vector name
    sanitizedVectorName = vectorName;
end


