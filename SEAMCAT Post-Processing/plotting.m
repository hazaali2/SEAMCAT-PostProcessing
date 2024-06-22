zipFilePath = 'results.swr';
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

interferenceMappings = extractInterferenceCalculations(resultsDoc);

% Prompt the user to select the type of interference measurement
disp('Available interference measurements:');
fieldNames = fieldnames(interferenceMappings);
for i = 1:length(fieldNames)
    fprintf('%d: %s\n', i, fieldNames{i});
end
selection = input('Select an interference measurement by entering its number: ');
if selection >= 1 && selection <= length(fieldNames)
    selectedInterference = fieldNames{selection};
else
    error('Invalid selection.');
end

% Prompt the user for the threshold value
threshold = input('Enter the interference threshold value (e.g., -6): ');

[victimRx, victimTx, offendingInterferers, interferers] = extractLocations(resultsDoc, interferenceMappings.(selectedInterference), threshold);

plotPoints(victimRx, victimTx, offendingInterferers, interferers);


function plotPoints(victimRx, victimTx, offendingInterferers, interferers)
    figure; % Create a new figure window
    hold on; % Hold on to plot multiple sets of points
    
    % Plot victimRx locations with red circles if available
    if ~isempty(victimRx)
        plot(victimRx(:,1), victimRx(:,2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'VictimRx');
    end
    
    % Plot victimTx locations with blue crosses if available
    if ~isempty(victimTx)
        plot(victimTx(:,1), victimTx(:,2), 'bx', 'MarkerSize', 8, 'DisplayName', 'VictimTx');
    end
    
    % Plot offendingInterferers locations with green triangles if available
    if ~isempty(offendingInterferers)
        plot(offendingInterferers(:,1), offendingInterferers(:,2), 'g^', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', 'Offending Interferers');
    end
    
    % Plot interferers locations with yellow squares if available
    if ~isempty(interferers)
        plot(interferers(:,1), interferers(:,2), 'ys', 'MarkerSize', 8, 'MarkerFaceColor', 'y', 'DisplayName', 'Interferers');
    end
    
    legend show; % Show legend
    xlabel('Longitude'); % Label x-axis
    ylabel('Latitude'); % Label y-axis
    title('Extracted Locations'); % Title for the plot
    grid on; % Enable grid
    hold off; % Release the plot hold

    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @myupdatefcn);

    function txt = myupdatefcn(~, event_obj)
        % Get the position of the point clicked on
        pos = get(event_obj, 'Position');
        
        % Initialize the tooltip text with just the longitude and latitude
        txt = {['Longitude: ', num2str(pos(1))], ['Latitude: ', num2str(pos(2))]};
    
        % Find the index of the point in offendingInterferers
        idx = find(offendingInterferers(:,1) == pos(2) & offendingInterferers(:,2) == pos(1), 1, 'first');
        
        % If the point is found, update the tooltip text with additional information
        if ~isempty(idx)
            additionalInfoForPoint = offendingInterferers(idx, 3);
            txt = [txt, {['Interference Ratio: ', num2str(additionalInfoForPoint)]}];
        end
    end
end