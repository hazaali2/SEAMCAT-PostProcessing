function [dRSSValues, iRSSUnwantedValues, iRSSBlockingValues, linkResultsValues] = extractFields(xmlStruct)
    % Initialize containers for storing the extracted values
    dRSSValues = [];
    iRSSUnwantedValues = containers.Map('KeyType', 'char', 'ValueType', 'any');
    iRSSBlockingValues = containers.Map('KeyType', 'char', 'ValueType', 'any');
    linkResultsValues = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % Recursively process the structure
    function processStruct(s)
        if isstruct(s)
            % Check if the item has the required attributes and names
            if isfield(s, 'Attributes') && isfield(s.Attributes, 'id') && strcmp(s.Attributes.id, 'seamcatResult')
                if isfield(s.Attributes, 'name')
                    name = s.Attributes.name;
                    if startsWith(name, 'Victim Results')
                        % Process dRSS, iRSS Unwanted, and iRSS Blocking
                        if isfield(s, 'VectorValues') && isstruct(s.VectorValues)
                            processVectors(s.VectorValues.Vector);
                        end
                    elseif startsWith(name, 'Link')
                        % Process individual link results
                        if isfield(s, 'SingleValues') && isstruct(s.SingleValues) && isfield(s.SingleValues, 'Single')
                            singleValues = s.SingleValues.Single;
                            if iscell(singleValues)
                                for j = 1:length(singleValues)
                                    processSingle(singleValues{j}, name);
                                end
                            else
                                processSingle(singleValues, name);
                            end
                        end
                    end
                end
            end
            
            % Recursively process nested fields
            fields = fieldnames(s);
            for i = 1:length(fields)
                processStruct(s.(fields{i}));
            end
        elseif iscell(s)
            % Process each element in the cell array
            for i = 1:length(s)
                processStruct(s{i});
            end
        end
    end

    % Function to process VectorValues
    function processVectors(vectors)
        if iscell(vectors)
            for i = 1:length(vectors)
                processVector(vectors{i});
            end
        else
            processVector(vectors);
        end
    end

    function processSingle(single, itemName)
        if isfield(single, 'Attributes') && isfield(single.Attributes, 'name')
            if strcmp(single.Attributes.name, 'Noise floor')
                linkNumber = extractLinkNumber(itemName, 2);
                linkResultsValues(linkNumber) = str2double(single.Attributes.value);
            end
        end
    end

    % Function to process a single vector
    function processVector(vector)
        if isfield(vector, 'Attributes') && isfield(vector.Attributes, 'name')
            name = vector.Attributes.name;
            values = extractValues(vector);
            if strcmp(name, 'dRSS')
                dRSSValues = values;
            elseif startsWith(name, 'iRSS Unwanted: Link')
                linkNumber = extractLinkNumber(name, 4);
                iRSSUnwantedValues(linkNumber) = values;
            elseif startsWith(name, 'iRSS Blocking: Link')
                linkNumber = extractLinkNumber(name, 4);
                iRSSBlockingValues(linkNumber) = values;
            end
        end
    end

    % Function to extract values from a structure
    function values = extractValues(s)
        values = [];
        if isfield(s, 'values') && isstruct(s.values) && isfield(s.values, 'value')
            valueStruct = s.values.value;
            if iscell(valueStruct)
                for j = 1:length(valueStruct)
                    if isstruct(valueStruct{j}) && isfield(valueStruct{j}, 'Attributes')
                        values = [values, str2double(valueStruct{j}.Attributes.value)];
                    end
                end
            elseif isstruct(valueStruct)
                values = str2double(valueStruct.Attributes.value);
            end
        end
    end

    % Function to extract link number from the name
    function linkNumber = extractLinkNumber(name, pos)
        parts = split(name, ' ');
        linkNumber = parts{pos}; % Assuming the format 'Link # Results'
    end

    % Start processing the structure
    processStruct(xmlStruct);

    % Display the extracted values
    fprintf('dRSS Values: ');
    disp(dRSSValues);
    fprintf('iRSS Unwanted Values: \n');
    unwantedKeys = keys(iRSSUnwantedValues);
    for i = 1:length(unwantedKeys)
        fprintf('Link %s: ', unwantedKeys{i});
        disp(iRSSUnwantedValues(unwantedKeys{i}));
    end
    fprintf('iRSS Blocking Values: \n');
    blockingKeys = keys(iRSSBlockingValues);
    for i = 1:length(blockingKeys)
        fprintf('Link %s: ', blockingKeys{i});
        disp(iRSSBlockingValues(blockingKeys{i}));
    end
    fprintf('Noise Floor Values: \n');
    linkKeys = keys(linkResultsValues);
    for i = 1:length(linkKeys)
        fprintf('Link %s: ', linkKeys{i});
        disp(linkResultsValues(linkKeys{i}));
    end
end