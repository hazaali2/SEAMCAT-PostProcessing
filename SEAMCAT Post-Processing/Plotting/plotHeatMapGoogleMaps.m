function plotHeatMapGoogleMaps(victimRx, victimTx, offendingInterferers, interferers)
    % Load the API key into a struct
    apiKeyData = load('api_key.mat');    
    apiKey = apiKeyData.apiKey; % Assuming the variable in the .mat file is named 'apiKey'

    % Create a new figure
    figure;
    hold on;

    % Plot victimRx locations with red circles if available
    if ~isempty(victimRx)
        plot(victimRx(:,2), victimRx(:,1), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    end

    % Plot victimTx locations with blue crosses if available
    if ~isempty(victimTx)
        plot(victimTx(:,2), victimTx(:,1), 'bx', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    end

    % Combine offendingInterferers and interferers for heatmap plotting
    combinedInterferers = [offendingInterferers; interferers];
    
    % Plot the combined interferers as a heatmap
    if ~isempty(combinedInterferers)
        % Extract the interference values for color scaling
        interferenceValues = combinedInterferers(:,3);
        
        % Scatter plot for interferers with colormap based on interference value
        scatter(combinedInterferers(:,2), combinedInterferers(:,1), 50, interferenceValues, 'filled');
        
        % Use a colormap that provides good color variation
        colormap parula; % 'jet' is just one option, others like 'hot', 'parula', 'turbo' might also be suitable
        
        % Add a colorbar to the side of the plot to indicate the interference value gradient
        colorbar;
        
        % Adjust the color limits of the colorbar to span the range of your data
        caxis([-80 6]);
    end

    % Data cursor mode settings
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @myupdatefcn);
   
     function txt = myupdatefcn(~, event_obj)
        % Get the position of the point clicked on
        pos = get(event_obj, 'Position');
        
        % Initialize the tooltip text with just the longitude and latitude
        txt = {['Longitude: ', num2str(pos(1))], ['Latitude: ', num2str(pos(2))]};
    
        % Find the index of the point in offendingInterferers
        idx = find(combinedInterferers(:,1) == pos(2) & combinedInterferers(:,2) == pos(1), 1, 'first');
   
        % If the point is found, update the tooltip text with additional information
        if ~isempty(idx)
            additionalInfoForPoint = combinedInterferers(idx, 3);
            txt = [txt, {['Interference Ratio: ', num2str(additionalInfoForPoint)]}];
        end
     end

    % Overlay the Google Map
    plot_google_map('MapType', 'roadmap', 'ShowLabels', 1, 'APIKey', apiKey);

    % Customize the plot
    title('Location Overview');
    xlabel('Longitude');
    ylabel('Latitude');
    legend('VictimRx', 'VictimTx', 'Interferers', 'Location', 'best'); % Updated legend
    hold off;
end
