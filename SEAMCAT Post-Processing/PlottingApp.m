classdef PlottingApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        SelectFileButton       matlab.ui.control.Button
        PlotOptionButtonGroup  matlab.ui.container.ButtonGroup
        NormalPlottingButton   matlab.ui.control.RadioButton
        HeatmapPlottingButton  matlab.ui.control.RadioButton
        InterferenceDropDown   matlab.ui.control.DropDown
        ThresholdEditField     matlab.ui.control.NumericEditField
        PlotButton             matlab.ui.control.Button
        UIPanel                matlab.ui.container.Panel 
        Axes                   
        FilePath               string
        resultsDoc
        scenarioDoc
        interferenceMapping
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            hideComponents(app); % Initially hide components
        end

        % Hide all components except the Select File button
        function hideComponents(app)
            app.PlotOptionButtonGroup.Visible = false;
            app.InterferenceDropDown.Visible = false;
            app.ThresholdEditField.Visible = false;
            app.PlotButton.Visible = false;
            app.UIPanel.Visible = false;
        end

        % Show all components based on selection
        function showComponents(app)
            app.PlotOptionButtonGroup.Visible = true;
            app.InterferenceDropDown.Visible = true;
            app.PlotButton.Visible = true;
            app.UIPanel.Visible = true;
            % Only show ThresholdEditField if 'Normal Plotting' is selected
            app.ThresholdEditField.Visible = strcmp(app.PlotOptionButtonGroup.SelectedObject.Text, 'Normal Plotting');
        end

        % Button pushed function: SelectFileButton
        function SelectFileButtonPushed(app, event)
            [file, path] = uigetfile('*.swr', 'Select a SWR file');
            if isequal(file, 0)
                disp('User selected Cancel');
                hideComponents(app);
            else
                disp(['User selected ', fullfile(path, file)]);
                app.FilePath = fullfile(path, file); % Save the file path
                updateInterferenceOptions(app, app.FilePath);
                showComponents(app);
            end
        end

        % Update the dropdown with interference calculations from XML
        function updateInterferenceOptions(app, filePath)
            extractTo = fullfile(pwd, 'extractedFiles'); 
            
            % Create the directory if it doesn't exist
            if ~exist(extractTo, 'dir')
                mkdir(extractTo);
            end
        
            try
                unzip(filePath, extractTo);
                disp('File unzipped successfully.');
            catch
                disp('Error: The file may not be a zip file or it is corrupted.');
            end

            resultsPath = fullfile(extractTo, 'results.xml');
            scenarioPath = fullfile(extractTo, 'scenario.xml');
            app.resultsDoc = xmlread(resultsPath);
            app.scenarioDoc = xmlread(scenarioPath);
            
            % Call the function to extract interference calculations
            app.interferenceMapping = extractInterferenceCalculations(app.resultsDoc);
            app.InterferenceDropDown.Items = fieldnames(app.interferenceMapping);
        end

        % Selection changed function: PlotOptionButtonGroup
        function PlotOptionButtonGroupSelectionChanged(app, event)
            app.ThresholdEditField.Visible = strcmp(app.PlotOptionButtonGroup.SelectedObject.Text, 'Normal Plotting');
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            cla(app.UIPanel);
            interference = app.InterferenceDropDown.Value; 
            selectedOption = app.PlotOptionButtonGroup.SelectedObject.Text;

            workspaceElement = app.scenarioDoc.getElementsByTagName('Workspace').item(0);

            latAttr = workspaceElement.getAttribute('lat');
            lat = str2double(latAttr);

            lonAttr = workspaceElement.getAttribute('lon');
            lon = str2double(lonAttr); 
            
        
            if strcmp(selectedOption, 'Normal Plotting')
                threshold = app.ThresholdEditField.Value;
                [victimRx, victimTx, offendingInterferers, interferers] = extractLocationsUsingTerrain(app.resultsDoc, app.interferenceMapping.(interference), threshold, lat, lon, false);
                plotLocations(app, victimRx, victimTx, offendingInterferers, interferers);

            elseif strcmp(selectedOption, 'Heatmap Plotting')
                [victimRx, victimTx, offendingInterferers, interferers] = extractLocationsUsingTerrain(app.resultsDoc, app.interferenceMapping.(interference), -6, lat, lon, false);
                plotHeatMap(app, victimRx, victimTx, offendingInterferers, interferers);
            end
        end
    end

    % Component initialization
    methods (Access = private)
        function createComponents(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600]; 
            app.UIFigure.Name = 'MATLAB App';
        
            % Create UIPanel to hold the geoaxes
            app.UIPanel = uipanel(app.UIFigure);
            app.UIPanel.Position = [50 50 700 400];  
            
            % Create SelectFileButton
            app.SelectFileButton = uibutton(app.UIFigure, 'push');
            app.SelectFileButton.ButtonPushedFcn = createCallbackFcn(app, @SelectFileButtonPushed, true);
            app.SelectFileButton.Position = [25 555 100 22];
            app.SelectFileButton.Text = 'Select File';
        
            app.PlotOptionButtonGroup = uibuttongroup(app.UIFigure);
            app.PlotOptionButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @PlotOptionButtonGroupSelectionChanged, true);
            app.PlotOptionButtonGroup.Position = [150 520 160 80];  % Positioned and sized appropriately
            
            % Create NormalPlottingButton within the button group
            app.NormalPlottingButton = uiradiobutton(app.PlotOptionButtonGroup);
            app.NormalPlottingButton.Text = 'Normal Plotting';
            app.NormalPlottingButton.Position = [10 40 150 22];  % Adjusted to fit within new button group size
            
            % Create HeatmapPlottingButton within the button group
            app.HeatmapPlottingButton = uiradiobutton(app.PlotOptionButtonGroup);
            app.HeatmapPlottingButton.Text = 'Heatmap Plotting';
            app.HeatmapPlottingButton.Position = [10 20 150 22];  % Adjusted to fit within new button group size
        
            % Create InterferenceDropDown
            app.InterferenceDropDown = uidropdown(app.UIFigure);
            app.InterferenceDropDown.Position = [350 555 100 22];
            app.InterferenceDropDown.Items = {'Select a file to see options'};         
            % Create ThresholdEditField to the right of the InterferenceDropDown
            app.ThresholdEditField = uieditfield(app.UIFigure, 'numeric');
            app.ThresholdEditField.Position = [475 555 100 22];  
        
            % Create PlotButton to the right of the ThresholdEditField
            app.PlotButton = uibutton(app.UIFigure, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [600 555 100 22]; 
            app.PlotButton.Text = 'Plot';
        
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PlottingApp

            % Create and configure components
            createComponents(app)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
