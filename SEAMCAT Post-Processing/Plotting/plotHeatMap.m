function plotHeatMap(app, victimRx, victimTx, offendingInterferers, interferers)
    app.Axes = geoaxes(app.UIPanel);
    app.Axes.Basemap = 'satellite'; 
    hold(app.Axes, 'on');
    
    legendArr = [];

     if ~isempty(victimRx)
        hRx = geoplot(app.Axes, victimRx(:,1), victimRx(:,2), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        legendArr = [legendArr, hRx];
    end

    if ~isempty(victimTx)
        hTx = geoplot(app.Axes, victimTx(:,1), victimTx(:,2), 'LineStyle', 'none', 'Marker', 's', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
        legendArr = [legendArr, hTx];
    end

      % Draw arrows from victimTx to victimRx
    if ~isempty(victimTx) && ~isempty(victimRx)
        % For simplicity, this example assumes each Tx corresponds to a Rx
        % Calculate differences in latitudes and longitudes
        dLat = victimRx(:,1) - victimTx(:,1);
        dLon = victimRx(:,2) - victimTx(:,2);
        
        % Adjust the arrow length for better visibility, if necessary
        scale = 1; % Adjust this scale factor as needed
        
        % Quiver function isn't natively supported in geographic axes, so we use a workaround
        for i = 1:length(dLat)
            % Calculate the end point of the arrow
            endLat = victimTx(i,1) + scale * dLat(i);
            endLon = victimTx(i,2) + scale * dLon(i);
            
            % Use geoplot to draw the arrow line
            geoplot(app.Axes, [victimTx(i,1), endLat], [victimTx(i,2), endLon], 'Color', 'g', 'LineWidth', 1);
        end
    end

    % Combine offendingInterferers and interferers for heatmap plotting
    combinedInterferers = [offendingInterferers; interferers];

    % Plot the combined interferers as a heatmap
    if ~isempty(combinedInterferers)
        % Extract the interference values for color scaling
        interferenceValues = combinedInterferers(:,3);

        geoscatter(app.Axes, combinedInterferers(:,1), combinedInterferers(:,2), 50, interferenceValues, 'filled');
        colormap(app.Axes, 'parula');
        cb = colorbar(app.Axes);
        cb.Label.String = 'Interference (dBm)';
        caxis(app.Axes, [min(interferenceValues), max(interferenceValues)]);
    end


    % Adjust zoom level
    gx = app.Axes;
    zoomLevel = floor(gx.ZoomLevel);
    gx.ZoomLevel = zoomLevel;

    allLatitudes = [];
    allLongitudes = [];
    
    if ~isempty(victimRx)
        allLatitudes = [allLatitudes; victimRx(:,1)];
        allLongitudes = [allLongitudes; victimRx(:,2)];
    end
    
    if ~isempty(victimTx)
        allLatitudes = [allLatitudes; victimTx(:,1)];
        allLongitudes = [allLongitudes; victimTx(:,2)];
    end

    if ~isempty(offendingInterferers)
        allLatitudes = [allLatitudes; offendingInterferers(:,1)];
        allLongitudes = [allLongitudes; offendingInterferers(:,2)];
    end
    
    if ~isempty(interferers)
        allLatitudes = [allLatitudes; interferers(:,1)];
        allLongitudes = [allLongitudes; interferers(:,2)];
    end
    
    if ~isempty(allLatitudes) && ~isempty(allLongitudes)
        latMargin = 0.05; % Adjust as needed
        lonMargin = 0.05; % Adjust as needed
        geolimits(app.Axes, [min(allLatitudes)-latMargin, max(allLatitudes)+latMargin], [min(allLongitudes)-lonMargin, max(allLongitudes)+lonMargin]);
    end

    legend(app.Axes, legendArr, {'Victim Rx', 'Victim Tx'}, 'Location', 'best');
    hold(app.Axes, 'off');
    title(app.Axes, 'Location Overview with Heatmap');
end
