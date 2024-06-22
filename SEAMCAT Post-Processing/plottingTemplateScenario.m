zipFilePath = 'NewScenario_Original.swr';
extractTo = fullfile(pwd, 'extractedFiles'); % Specify a directory for the extracted files

% Create the directory if it doesn't exist
if ~exist(extractTo, 'dir')
    mkdir(extractTo);
end

try
    unzip(zipFilePath, extractTo);
    disp('File unzipped successfully.');
catch
    disp('Error: The file may not be a zip file or it is corrupted.');
end

% Update filePath to include the directory where files were extracted
filePath = fullfile(extractTo, 'results.xml');
resultsDoc = xmlread(filePath);

interferenceMappings = extractInterferenceCalculationsTemplateScenario(resultsDoc);

[selectedInterference, threshold, plotMode] = selectUserOptions(interferenceMappings);

filePath = fullfile(extractTo, 'scenario.xml');

try
    scenarioDoc = xmlread(filePath);
catch
    error('Failed to read XML file %s.', filePath);
end

% Get the Workspace element (assuming there's only one such element)
workspaceElement = scenarioDoc.getElementsByTagName('Workspace').item(0);

% Check if the Workspace element exists
if ~isempty(workspaceElement)
    % Extract the 'lat' attribute
    latAttr = workspaceElement.getAttribute('lat');
    lat = str2double(latAttr);  % Convert to double for numerical computations

    % Extract the 'lon' attribute
    lonAttr = workspaceElement.getAttribute('lon');
    lon = str2double(lonAttr);  % Convert to double for numerical computations

    % Display extracted values
    fprintf('Latitude: %f\n', lat);
    fprintf('Longitude: %f\n', lon);

    [victimRx, victimTx, offendingInterferers, interferers] = extractLocationsUsingTerrain(resultsDoc, interferenceMappings.(selectedInterference), threshold, lat, lon, true);
    
    if strcmp(plotMode, 'Heatmap Plotting')
        plotHeatMap(victimRx, victimTx, offendingInterferers, interferers);
    else
        plotLocations(victimRx, victimTx, offendingInterferers, interferers);
    end
else
    disp('Workspace element not found in the XML file.');
end

    % plotLocationsWebMap(lat, lon, victimRx, victimTx, offendingInterferers, interferers);
    % plotLocationsGoogleMaps(victimRx, victimTx, offendingInterferers, interferers);
     
    %plotHeatMapGoogleMaps(victimRx, victimTx, offendingInterferers, interferers);