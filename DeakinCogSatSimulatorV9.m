function DeakinCogSatSimulatorV9
    clc
    fig = uifigure('Name','Deakin CogSat Demo','Position',[100 100 1200 900]); % [left bottom width height]

    % Title
    uilabel(fig, 'Text','CogSat Software Demo', ...
        'FontSize', 24, 'FontWeight', 'bold', ...
        'HorizontalAlignment','center', ...
        'Position',[300 550 600 650]);

    % SmartSat Logo
    uiimage(fig, 'Position', [900 550 100 650], 'ImageSource', 'smartSat.png');
    % Deakin Logo
    uiimage(fig, 'Position', [1020 550 100 650], 'ImageSource', 'Deakin.png');

    % Scenario Input Controls
    uilabel(fig, 'Text','GEO satellites:', 'FontSize', 18, 'Position', [40 810 180 25]);%[left bottom width height]
    uidropdown(fig, 'Items', {'1','2','3'}, 'FontSize', 16,'Position', [170 810 100 25], 'Value', '1');
    uilabel(fig, 'Text','LEO satellites:', 'FontSize', 18, 'Position', [40 770 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','588'},'FontSize', 16, 'Position', [170 770 100 25], 'Value', '588');
    uilabel(fig, 'Text','GEO users:', 'FontSize', 18, 'Position', [40 730 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [170 730 100 25], 'Value', '10');
    uilabel(fig, 'Text','LEO users:', 'FontSize', 18, 'Position', [40 690 180 25]);
    uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10'},'FontSize', 16, 'Position', [170 690 100 25], 'Value', '10');
    % uilabel(fig, 'Text','LEO plans:', 'FontSize', 18, 'Position', [40 650 180 25]);
    % uidropdown(fig, 'Items', {'12','15','18'},'FontSize', 16, 'Position', [170 650 100 25], 'Value', '12');

    uilabel(fig, 'Text','Number of channels:', 'FontSize', 18, 'Position', [300 810 180 25]);
    uidropdown(fig, 'Items', {'10','15','20','25','30'}, 'FontSize', 16,'Position', [470 810 100 25], 'Value', '15');
    uilabel(fig, 'Text','Gain pattern:', 'FontSize', 18, 'Position', [300 770 180 25]);
    uidropdown(fig, 'Items', {'Fixed','1D','2D'},'FontSize', 16, 'Position', [470 770 100 25], 'Value', 'Fixed');
    uilabel(fig, 'Text','Antenna beamwidth:', 'FontSize', 18, 'Position', [300 730 180 25]);
    uidropdown(fig, 'Items', {'0°','2°','5°','8°','10°','15°'},'FontSize', 16, 'Position', [470 730 100 25], 'Value', '0°');
    uilabel(fig, 'Text','Fading:', 'FontSize', 18, 'Position', [300 690 180 25]);
    uidropdown(fig, 'Items', {'None','Rician','Rayleigh'},'FontSize', 16, 'Position', [470 690 100 25], 'Value', 'Rician');
    % uilabel(fig, 'Text','LEO plans:', 'FontSize', 18, 'Position', [300 650 180 25]);
    % uidropdown(fig, 'Items', {'1','2','3'},'FontSize', 16, 'Position', [470 650 80 25], 'Value', '1');

    % Scenario Image
    scenarioImage = uiimage(fig, 'Position', [700 580 450 300], 'ImageSource', 'images/scenarioImage.png');
    
    % Satellite Visualisation
    uibutton(fig, 'Text','Satellite Visualisation','FontSize', 18, 'Position',[370 640 200 30], ...
        'ButtonPushedFcn', @(src, event) satView());

    % CogSat Toggles
    % uilabel(fig, 'Text','CogSat', 'FontSize', 18, 'FontWeight', 'bold', 'Position',[40 640 75 30]);
    % toggleBtn2 = uibutton(fig, 'state', 'Text','On', 'FontSize', 16, 'FontWeight','bold', ...
    %     'FontColor','#65aa3a', 'Position',[140 640 50 30], ...
    %     'ValueChangedFcn', @(btn, event) toggleCogSatOn());
    % toggleBtn3 = uibutton(fig, 'state', 'Text','Off', 'FontSize', 16, 'FontWeight','bold', ...
    %     'FontColor','red', 'Position',[200 640 50 30], 'Value', true, ...
    %     'ValueChangedFcn', @(btn, event) toggleCogSatOff());
    uilabel(fig, 'Text','CogSat', 'FontSize', 18, 'FontWeight', 'bold', 'Position',[40 640 75 30]);
    toggleBtn = uibutton(fig, 'state', 'Text','Off','FontSize', 16,  'FontWeight','bold', ...
        'FontColor','red', 'Position',[140 640 80 30], 'Value', true, ...
        'ValueChangedFcn', @(btn, event) toggleCogSat());

    % --- Combined Boxplot Panel ---
    % boxplotPanel = uipanel(fig, 'Title', 'SINR per user', 'FontSize', 16,'Position', [80 350 450 250]);
    % axCombined = uiaxes(boxplotPanel, 'Position', [5 1 440 230]);
    % axCombined.YLabel.String = '';
    % axCombined.XTickLabelRotation = 0;
    % axCombined.FontSize = 12;
    % grid(axCombined, 'on');

    % KPI Panels
    panelWidth = 520; panelHeight = 250; panelBottom = 350; gap = 40;
    kpi1 = uipanel(fig, 'Title','Primary User Throughput', 'FontSize', 18,'Position',[gap*1.2 panelBottom panelWidth panelHeight]);
    kpi1ax = uiaxes(kpi1, 'Position', [5 1 510 240]);
    setupKPIAxes(kpi1ax, [0 2000], 'Throughput [b/s]', 'Time [s]',[]);

    kpi2 = uipanel(fig, 'Title','Secondary User Throughput', 'FontSize', 18, 'Position',[gap*2.4 + panelWidth panelBottom panelWidth panelHeight]);
    kpi2ax = uiaxes(kpi2, 'Position', [5 1 510 240]);
    setupKPIAxes(kpi2ax, [0 2000], 'Throughput [b/s]','Time [s]',[]);


    % KPI Panels
    panelWidth = 350; panelHeight = 250; panelBottom = 80; gap = 40;
    kpi3 = uipanel(fig, 'Title','Spectral Efficiency', 'FontSize', 18,'Position',[gap panelBottom panelWidth panelHeight]);
    kpi3ax = uiaxes(kpi3, 'Position', [5 1 340 240]);
    setupKPIAxes(kpi3ax, [0 2000], 'Spectral efficiency [b/s/Hz]','Time [s]',[]);

    kpi4 = uipanel(fig, 'Title','Mean SINR for LEO users', 'FontSize', 18, 'Position',[gap*2 + panelWidth panelBottom panelWidth panelHeight]);
    kpi4ax = uiaxes(kpi4, 'Position', [5 1 340 240]);
    setupKPIAxes(kpi4ax, [0 40], 'SINR [dB]','Time [s]',[]);

    kpi5 = uipanel(fig, 'Title','Beamwidth constraints on user SINR','FontSize', 18, 'Position',[gap*3 + panelWidth*2 panelBottom panelWidth panelHeight]);
    % kpi5ax = uiaxes(kpi5, 'Position', [5 1 340 240]);
    % setupKPIAxes(kpi5ax, [-20 30], 'SINR [dB]','User index]',[1 20]);
    uiimage(kpi5, ...
    'ImageSource', 'Figure11.png', ...
    'Position', [10 10 panelWidth-20 panelHeight-20]);  % Adjust for padding

    %% === Nested Functions ===
    co = colororder;
    function toggleCogSat()
        if toggleBtn.Value  % ON mode
            toggleBtn.Text = 'On';
            toggleBtn.FontColor = '#65aa3a';  % Green
            cla(kpi1ax); cla(kpi2ax); cla(kpi3ax); cla(kpi4ax);

            % Solid lines → CogSat ON
            on_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2);
            on_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2);
            on_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2);
            on_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2);
            % Dashed lines → Baseline OFF
            off_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2, 'LineStyle','--');

            T = readtable('data_final.xlsx');
            for i = 1:height(T)
                if ~toggleBtn.Value, break; end
                t = T.Time(i);
                % CogSat ON values (solid lines)
                y1_on = str2double(T.GEO_Thrpt_a2c(i));
                y2_on = str2double(T.LEO_Thrpt_a2c(i));
                y3_on = (y1_on + y2_on) / 2;
                y4_on = str2double(T.LEO_SINR_a2c(i));
        
                % Baseline OFF values (dashed lines)
                y1_off = str2double(T.GEO_Thrpt_baseline(i));
                y2_off = str2double(T.LEO_Thrpt_baseline(i));
                y3_off = (y1_off + y2_off) / 2;
                y4_off = str2double(T.LEO_SINR_baseline(i));
        
                % Add CogSat ON points
                if ~isnan(y1_on), addpoints(on_kpi1, t, y1_on); end
                if ~isnan(y2_on), addpoints(on_kpi2, t, y2_on); end
                if ~isnan(y3_on), addpoints(on_kpi3, t, y3_on); end
                if ~isnan(y4_on), addpoints(on_kpi4, t, y4_on); end
        
                % Add Baseline OFF points
                if ~isnan(y1_off), addpoints(off_kpi1, t, y1_off); end
                if ~isnan(y2_off), addpoints(off_kpi2, t, y2_off); end
                if ~isnan(y3_off), addpoints(off_kpi3, t, y3_off); end
                if ~isnan(y4_off), addpoints(off_kpi4, t, y4_off); end
                drawnow limitrate; pause(0.15);
            end
    
        else  % OFF mode
            toggleBtn.Text = 'Off';
            toggleBtn.FontColor = 'red';
            cla(kpi1ax); cla(kpi2ax); cla(kpi3ax); cla(kpi4ax);
    
            off_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2, 'LineStyle','--');
            off_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2, 'LineStyle','--');
    
            T = readtable('data_final.xlsx');
            for i = 1:height(T)
                if toggleBtn.Value, break; end
                t = T.Time(i);
                y1 = str2double(T.GEO_Thrpt_baseline(i));
                y2 = str2double(T.LEO_Thrpt_baseline(i));
                y3 = (y1 + y2) / 2;
                y4 = str2double(T.LEO_SINR_baseline(i));
                if ~isnan(y1), addpoints(off_kpi1, t, y1); end
                if ~isnan(y2), addpoints(off_kpi2, t, y2); end
                if ~isnan(y3), addpoints(off_kpi3, t, y3); end
                if ~isnan(y4), addpoints(off_kpi4, t, y4); end
                drawnow limitrate; pause(0.15);
            end
        end
    end

    % function updateBoxplot(axCombined, mode)
    %     cla(axCombined);
    %     T = readtable('data_final.xlsx');
    % 
    %     switch mode
    %         case "on"
    %             geoData = T.GEO_Thrpt_a2c;
    %             leoData = T.LEO_Thrpt_a2c;
    %         case "off"
    %             geoData = T.GEO_Thrpt_baseline;
    %             leoData = T.LEO_Thrpt_baseline;
    %     end
    % 
    %     % Convert to numeric if needed
    %     if iscell(geoData), geoData = str2double(geoData); end
    %     if iscell(leoData), leoData = str2double(leoData); end
    % 
    %     boxData = [log(geoData + 1); log(leoData + 1)];
    %     boxGroups = [repmat("GEO", length(geoData), 1); repmat("LEO", length(leoData), 1)];
    % 
    %     boxchart(axCombined, categorical(boxGroups), boxData, 'BoxWidth', 0.4);
    %     title(axCombined, upper(mode));
    %     axCombined.YLim = [0 20];
    % end

    function setupKPIAxes(ax, ylimValues, ylabelText, xlabelText, xlimValues)
        % X-axis: use auto if empty, else set
        if isempty(xlimValues)
            ax.XLimMode = 'auto';
        else
            ax.XLim = xlimValues;
        end
        % Y-axis: use auto if empty, else set
        if isempty(ylimValues)
            ax.YLimMode = 'auto';
        else
            ax.YLim = ylimValues;
        end
        ax.YLabel.String = ylabelText;
        ax.XLabel.String = xlabelText;
        ax.XTickLabelRotation = 0;
        ax.FontSize = 12;
        grid(ax, 'on');
    end


    function satView()
        try
            data = load('SatelliteScenario.mat');
            sc = data.sc;
            play(sc,PlaybackSpeedMultiplier=100);
        catch ME
            disp("Error loading Satellite Scenario: " + ME.message);
        end
    end
end 
