function plotLocationsGoogleMaps(victimRx, victimTx, offendingInterferers, interferers)
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

    % Plot offendingInterferers locations with green triangles if available
    if ~isempty(offendingInterferers)
        plot(offendingInterferers(:,2), offendingInterferers(:,1), 'g^', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    end
    
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

    % Plot interferers locations with yellow squares if available
    if ~isempty(interferers)
        plot(interferers(:,2), interferers(:,1), 'ys', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
    end

    % Overlay the Google Map
    plot_google_map('MapType', 'roadmap', 'ShowLabels', 1, 'APIKey', apiKey);

    % Customize the plot
    title('Location Overview');
    xlabel('Longitude');
    ylabel('Latitude');
    legend('VictimRx', 'VictimTx', 'Offending Interferers', 'Interferers');
    hold off;
end
