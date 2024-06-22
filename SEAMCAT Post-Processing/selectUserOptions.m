    function [selectedInterference, threshold, plotMode] = selectUserOptions(interferenceMappings)
        % Available interference measurements
        fieldNames = fieldnames(interferenceMappings);
        
        % Prompt for selecting the interference measurement
        [selection, ok] = listdlg('PromptString', 'Select an interference measurement:', ...
                                  'SelectionMode', 'single', ...
                                  'ListString', fieldNames);
        
        % Check if the user made a selection
        if ok && ~isempty(selection)
            selectedInterference = fieldNames{selection};
        else
            error('You must select an interference measurement.');
        end
        
        % Prompt for the threshold value
        prompt = {'Enter the interference threshold value (e.g., -6):'};
        dlgtitle = 'Input Threshold';
        dims = [1 35];
        definput = {'-6'}; % Default value or previously used value
        thresholdInput = inputdlg(prompt, dlgtitle, dims, definput);
        
        % Check if the user entered a value
        if ~isempty(thresholdInput)
            threshold = str2double(thresholdInput{1});
            if isnan(threshold)
                error('Invalid threshold value. Please enter a numeric value.');
            end
        else
            error('You must enter a threshold value.');
        end
        
        % Prompt for selecting the plot mode
        plotModes = {'Normal Plotting', 'Heatmap Plotting'};
        [plotSelection, plotOk] = listdlg('PromptString', 'Select the plot mode:', ...
                                          'SelectionMode', 'single', ...
                                          'ListString', plotModes);
        
        % Check if the user made a selection
        if plotOk && ~isempty(plotSelection)
            plotMode = plotModes{plotSelection};
        else
            error('You must select a plot mode.');
        end
    end
