function plotLocationsWebMap(lat, lon, victimRx, victimTx, offendingInterferers, interferers)
    if license('test', 'MAP_Toolbox')
        try
            webmap('OpenStreetMap');  % Open a web map

            allLats = [lat];  % Initialize with workspace latitude
            allLons = [lon];  % Initialize with workspace longitude

            % Plot the main location (workspace location)
            wmmarker(lat, lon, 'FeatureName', 'Workspace Location', 'Color', 'red');

            % Plot victim receivers and transmitters
            plotMarker(victimRx, 'blue', 'VictimRx');
            plotMarker(victimTx, 'cyan', 'VictimTx');

            % Plot offending interferers and interferers
            plotMarker(offendingInterferers, 'green', 'Offender');
            plotMarker(interferers, 'yellow', 'Interferer');

            % Center the map around the average of all plotted points
            avgLat = mean(allLats);
            avgLon = mean(allLons);
            wmcenter(avgLat, avgLon);  % Center the map
            wmzoom(10); 
            disp('Map plotted successfully.');
        catch ME
            disp('Error plotting map:');
            disp(ME.message);
        end
    else
        disp('Mapping Toolbox is not available. Unable to plot on map.');
    end

    % Nested function to plot markers for matrix data and collect coordinates
    function plotMarker(latLonMatrix, color, namePrefix)
        numMarkers = size(latLonMatrix, 1);
    
        % Preallocate memory for allLats and allLons
        tempLats = zeros(numMarkers, 1);
        tempLons = zeros(numMarkers, 1);
    
        for i = 1:numMarkers
            lat = latLonMatrix(i, 1);
            lon = latLonMatrix(i, 2);
            wmmarker(lat, lon, 'FeatureName', sprintf('%s %d', namePrefix, i), 'Color', color);
    
            % Store the lat and lon values in the preallocated arrays
            tempLats(i) = lat;
            tempLons(i) = lon;
        end
    
        % Append the preallocated arrays to allLats and allLons
        allLats = [allLats; tempLats];
        allLons = [allLons; tempLons];
    end
end
