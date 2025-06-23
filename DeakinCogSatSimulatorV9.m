function DeakinCogSatSimulatorV9
    clc
    fig = uifigure('Name','Deakin CogSat Demo','Position',[100 100 1200 900]); % [left bottom width height]

    % Title
    uilabel(fig, 'Text','CogSat Software Demo', ...
        'FontSize', 20, 'FontWeight', 'bold', ...
        'HorizontalAlignment','center', ...
        'Position',[300 540 600 650]);

    % SmartSat Logo
    uiimage(fig, 'Position', [800 560 100 650], 'ImageSource', 'smartSat.png');

    % --- Combined Boxplot Panel ---
    boxplotPanel = uipanel(fig, 'Title', 'SINR per user', 'FontSize', 16,'Position', [800 600 350 250]);
    axCombined = uiaxes(boxplotPanel, 'Position', [5 1 340 230]);
    axCombined.YLabel.String = '';
    axCombined.XTickLabelRotation = 0;
    axCombined.FontSize = 12;
    grid(axCombined, 'on');

    % Scenario Input Controls
    uilabel(fig, 'Text','GEO satellites:', 'FontSize', 16, 'Position', [40 820 180 25]);%[left bottom width height]
    uidropdown(fig, 'Items', {'1','2','3'}, 'FontSize', 16,'Position', [160 820 80 25], 'Value', '1');
    uilabel(fig, 'Text','LEO satellites:', 'FontSize', 16, 'Position', [40 790 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','588'},'FontSize', 16, 'Position', [160 790 80 25], 'Value', '588');
    uilabel(fig, 'Text','GEO users:', 'FontSize', 16, 'Position', [40 760 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [160 760 80 25], 'Value', '10');
    uilabel(fig, 'Text','LEO users:', 'FontSize', 16, 'Position', [40 730 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [160 730 80 25], 'Value', '10');
    uilabel(fig, 'Text','LEO plans:', 'FontSize', 16, 'Position', [40 700 180 25]);
    uidropdown(fig, 'Items', {'12','15','18'},'FontSize', 16, 'Position', [160 700 80 25], 'Value', '12');

    uilabel(fig, 'Text','Antenna beamwidth:', 'FontSize', 16, 'Position', [300 820 180 25]);
    uidropdown(fig, 'Items', {'2°','5°','8°','10°','15°'}, 'FontSize', 16,'Position', [470 820 80 25], 'Value', '5°');
    uilabel(fig, 'Text','Number of channels:', 'FontSize', 16, 'Position', [300 790 180 25]);
    uidropdown(fig, 'Items', {'10','15','20','25','30'},'FontSize', 16, 'Position', [470 790 80 25], 'Value', '15');
    uilabel(fig, 'Text','GEO users:', 'FontSize', 16, 'Position', [300 760 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [470 760 80 25], 'Value', '10');
    uilabel(fig, 'Text','LEO users:', 'FontSize', 16, 'Position', [300 730 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [470 730 80 25], 'Value', '10');
    uilabel(fig, 'Text','LEO plans:', 'FontSize', 16, 'Position', [300 700 180 25]);
    uidropdown(fig, 'Items', {'1','2','3'},'FontSize', 16, 'Position', [470 700 80 25], 'Value', '1');

    % Scenario Image
    scenarioImage = uiimage(fig, 'Position', [250 365 300 230], 'ImageSource', 'images/s1_on.png');

    % CogSat Toggles
    uilabel(fig, 'Text','CogSat', 'FontSize', 18, 'FontWeight', 'bold', 'Position',[320 370 75 30]);
    toggleBtn2 = uibutton(fig, 'state', 'Text','On', 'FontSize', 16, 'FontWeight','bold', ...
        'FontColor','#65aa3a', 'Position',[400 370 50 30], ...
        'ValueChangedFcn', @(btn, event) toggleCogSatOn());
    toggleBtn3 = uibutton(fig, 'state', 'Text','Off', 'FontSize', 16, 'FontWeight','bold', ...
        'FontColor','red', 'Position',[470 370 50 30], 'Value', true, ...
        'ValueChangedFcn', @(btn, event) toggleCogSatOff());

    % KPI Panels
    panelWidth = 250; panelHeight = 200; panelBottom = 80; gap = 30;
    kpi1 = uipanel(fig, 'Title','Primary User Throughput', 'Position',[gap panelBottom panelWidth panelHeight]);
    kpi1ax = uiaxes(kpi1, 'Position', [5 1 240 170]);
    setupKPIAxes(kpi1ax, [0 2000], 'bits/s');

    kpi2 = uipanel(fig, 'Title','Secondary User Throughput', 'Position',[gap*2 + panelWidth panelBottom panelWidth panelHeight]);
    kpi2ax = uiaxes(kpi2, 'Position', [5 1 240 170]);
    setupKPIAxes(kpi2ax, [0 2000], 'bits/s');

    kpi3 = uipanel(fig, 'Title','Spectral Efficiency', 'Position',[gap*3 + panelWidth*2 panelBottom panelWidth panelHeight]);
    kpi3ax = uiaxes(kpi3, 'Position', [5 1 240 170]);
    setupKPIAxes(kpi3ax, [0 2000], 'Value');

    uibutton(fig, 'Text','Satellite Visualisation', 'Position',[330 310 200 30], ...
        'ButtonPushedFcn', @(src, event) satView());

    %% === Nested Functions ===
    function toggleCogSatOn()
        toggleBtn3.Value = false;
        scenarioImage.ImageSource = 'images/s1_on.png';
        cla(kpi1ax); cla(kpi2ax); cla(kpi3ax);
        updateBoxplot("on");

        on_kpi1 = animatedline(kpi1ax, 'Color', 'r', 'LineWidth', 2);
        on_kpi2 = animatedline(kpi2ax, 'Color', 'b', 'LineWidth', 2);
        on_kpi3 = animatedline(kpi3ax, 'Color', 'g', 'LineWidth', 2);

        T = readtable('data_final.xlsx');
        for i = 1:height(T)
            if ~toggleBtn2.Value, break; end
            t = T.Time(i);
            y1 = str2double(T.GEO_Thrpt_a2c(i));
            y2 = str2double(T.LEO_Thrpt_a2c(i));
            y3 = (y1+y2)/2; % feeding some data into y3
            if ~isnan(y1), addpoints(on_kpi1, t, y1); end
            if ~isnan(y2), addpoints(on_kpi2, t, y2); end
            if ~isnan(y3), addpoints(on_kpi3, t, y3); end
            drawnow limitrate; pause(0.03);
        end
    end

    function toggleCogSatOff()
        toggleBtn2.Value = false;
        scenarioImage.ImageSource = 'images/s1_off.png';
        cla(kpi1ax); cla(kpi2ax); cla(kpi3ax);
        updateBoxplot("off");

        off_kpi1 = animatedline(kpi1ax, 'Color', [1 0.6 0.6], 'LineWidth', 2, 'LineStyle','--');
        off_kpi2 = animatedline(kpi2ax, 'Color', [0.6 0.6 1], 'LineWidth', 2, 'LineStyle','--');
        off_kpi3 = animatedline(kpi3ax, 'Color', [0.6 0.6 1], 'LineWidth', 2, 'LineStyle','--');

        T = readtable('data_final.xlsx');
        for i = 1:height(T)
            if ~toggleBtn3.Value, break; end
            t = T.Time(i);
            y1 = str2double(T.GEO_Thrpt_baseline(i));
            y2 = str2double(T.LEO_Thrpt_baseline(i));
            y3 = (y1+y2)/2; % feeding some data into y3
            if ~isnan(y1), addpoints(off_kpi1, t, y1); end
            if ~isnan(y2), addpoints(off_kpi2, t, y2); end
            if ~isnan(y3), addpoints(off_kpi3, t, y3); end
            drawnow limitrate; pause(0.03);
        end

    end

    function updateBoxplot(mode)
        cla(axCombined);
        T = readtable('data_final.xlsx');

        switch mode
            case "on"
                geoData = T.GEO_Thrpt_a2c;
                leoData = T.LEO_Thrpt_a2c;
            case "off"
                geoData = T.GEO_Thrpt_baseline;
                leoData = T.LEO_Thrpt_baseline;
        end

        % Convert to numeric if needed
        if iscell(geoData), geoData = str2double(geoData); end
        if iscell(leoData), leoData = str2double(leoData); end

        boxData = [log(geoData + 1); log(leoData + 1)];
        boxGroups = [repmat("GEO", length(geoData), 1); repmat("LEO", length(leoData), 1)];

        boxchart(axCombined, categorical(boxGroups), boxData, 'BoxWidth', 0.4);
        title(axCombined, upper(mode));
        axCombined.YLim = [0 20];
    end

    function setupKPIAxes(ax, ylimVals, ylabelText)
        ax.XLimMode = 'auto';
        ax.YLim = ylimVals;
        ax.XLabel.String = 'Time (s)';
        ax.YLabel.String = ylabelText;
        grid(ax, 'on');
        hold(ax, 'on');
    end

    function satView()
        try
            load('originalSatelliteScenario.mat');
            viewer = satelliteScenarioViewer(sc);
            play(sc);
        catch ME
            disp("Error loading Satellite Scenario: " + ME.message);
        end
    end
end 
