function DeakinCogSatSimulatorV11
    clc
    fig = uifigure('Name','Deakin CogSat Demo','Position',[100 100 1200 900]); % [left bottom width height]

    drawingActive = false;  % <==== GLOBAL SHARED VARIABLE

    % Title
    uilabel(fig, 'Text','WP 2 CogSat Software Demo', ...
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
    LEONumbers=uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10','588'},'FontSize', 16, 'Position', [170 770 100 25], 'Value', '588');
    uilabel(fig, 'Text','GEO users:', 'FontSize', 18, 'Position', [40 730 180 25]);
    GEOUsers=uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'},'FontSize', 16, 'Position', [170 730 100 25], 'Value', '10');
    uilabel(fig, 'Text','LEO users:', 'FontSize', 18, 'Position', [40 690 180 25]);
    LEOUsers=uidropdown(fig, 'Items', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'},'FontSize', 16, 'Position', [170 690 100 25], 'Value', '10');
    % uilabel(fig, 'Text','LEO plans:', 'FontSize', 18, 'Position', [40 650 180 25]);
    % uidropdown(fig, 'Items', {'12','15','18'},'FontSize', 16, 'Position', [170 650 100 25], 'Value', '12');

    uilabel(fig, 'Text','Number of channels:', 'FontSize', 18, 'Position', [300 810 180 25]);
    Channelnum=uidropdown(fig, 'Items', {'10','15','20','25','30'}, 'FontSize', 16,'Position', [470 810 100 25], 'Value', '15');
    uilabel(fig, 'Text','Gain pattern:', 'FontSize', 18, 'Position', [300 770 180 25]);
    uidropdown(fig, 'Items', {'Fixed','1D','2D'},'FontSize', 16, 'Position', [470 770 100 25], 'Value', '1D');
    uilabel(fig, 'Text','Antenna beamwidth:', 'FontSize', 18, 'Position', [300 730 180 25]);
    uidropdown(fig, 'Items', {'0°','2°','5°','8°','10°','15°'},'FontSize', 16, 'Position', [470 730 100 25], 'Value', '8°');
    uilabel(fig, 'Text','Fading:', 'FontSize', 18, 'Position', [300 690 180 25]);
    uidropdown(fig, 'Items', {'None','Rician','Rayleigh'},'FontSize', 16, 'Position', [470 690 100 25], 'Value', 'Rician');
    % uilabel(fig, 'Text','LEO plans:', 'FontSize', 18, 'Position', [300 650 180 25]);
    % uidropdown(fig, 'Items', {'1','2','3'},'FontSize', 16, 'Position', [470 650 80 25], 'Value', '1');

    % Create Video
    vidAx = uiaxes(fig, 'Position', [650 580 450 300]);
    axis(vidAx, 'off');
    v = VideoReader('Satellite2.mp4');
    vidTimer = timer( ...
    'ExecutionMode', 'fixedRate', ...
    'Period', 1/v.FrameRate, ...
    'TimerFcn', @updateFrame);
    start(vidTimer);
    
    % Satellite Visualisation
    uibutton(fig, 'Text','Satellite Visualisation','FontSize', 18, 'Position',[235 605 200 30], ...
        'ButtonPushedFcn', @(src, event) satView());

    % Control buttons
    uilabel(fig, 'Text','Plots:', 'FontSize', 18, 'FontWeight', 'bold', 'Position',[40 640 75 30]);
    baselineBtn = uibutton(fig, 'Text','Baseline', 'FontSize', 16, 'FontWeight','bold', ...
        'FontColor','black', 'Position',[140 640 90 30], ...
        'ButtonPushedFcn', @(btn, event) runBaseline());
    cogsatBtn = uibutton(fig, 'Text','CogSat', 'FontSize', 16, 'FontWeight','bold', ...
        'FontColor','#65aa3a', 'Position',[240 640 90 30], ...
        'ButtonPushedFcn', @(btn, event) runCogSat());
    combinedBtn = uibutton(fig, 'Text','Combined', 'FontSize', 16, 'FontWeight','bold', ...
        'FontColor','blue', 'Position',[340 640 90 30], ...
        'ButtonPushedFcn', @(btn, event) runCombined());
    stopBtn = uibutton(fig, 'Text','Stop','FontSize', 16, 'FontWeight','bold', ...
        'FontColor','red', 'Position',[440 640 90 30], ...
        'ButtonPushedFcn', @(btn, event) stopDrawing());
    
    % KPI Panels
    panelWidth = 520; panelHeight = 250; panelBottom = 350; gap = 40;
    kpi1 = uipanel(fig, 'Title','GEO Users Mean Throughput', 'FontSize', 18,'Position',[gap*1.2 panelBottom panelWidth panelHeight]);
    kpi1ax = uiaxes(kpi1, 'Position', [5 1 510 225]);
    setupKPIAxes(kpi1ax, [3 8], 'Throughput [bps/Hz]', 'Time [s]',[]);

    kpi2 = uipanel(fig, 'Title','LEO Users Mean Throughput', 'FontSize', 18, 'Position',[gap*2.4 + panelWidth panelBottom panelWidth panelHeight]);
    kpi2ax = uiaxes(kpi2, 'Position', [5 1 510 225]);
    setupKPIAxes(kpi2ax, [0 6], 'Throughput [bps/Hz]','Time [s]',[]);


    % KPI Panels
    panelWidth = 350; panelHeight = 250; panelBottom = 80; gap = 30;
    kpi3 = uipanel(fig, 'Title','Spectral Efficiency', 'FontSize', 18,'Position',[gap*1.2 panelBottom panelWidth panelHeight]);
    kpi3ax = uiaxes(kpi3, 'Position', [5 1 340 225]);
    setupKPIAxes(kpi3ax, [0 100], 'Spectral efficiency [%]','Time [s]',[]);

    kpi4 = uipanel(fig, 'Title','Mean SINR for GEO Users', 'FontSize', 18, 'Position',[gap*2.2 + panelWidth panelBottom panelWidth panelHeight]);
    kpi4ax = uiaxes(kpi4, 'Position', [5 1 340 225]);
    setupKPIAxes(kpi4ax, [6 23], 'SINR [dB]','Time [s]',[]);

    kpi5 = uipanel(fig, 'Title','Mean SINR for LEO Users','FontSize', 18, 'Position',[gap*3.2 + panelWidth*2 panelBottom panelWidth panelHeight]);
    kpi5ax = uiaxes(kpi5, 'Position', [5 1 340 225]);
    setupKPIAxes(kpi5ax, [-20 15], 'SINR [dB]','User index',[]);
    % uiimage(kpi5, ...
    % 'ImageSource', 'Figure11.png', ...
    % 'Position', [10 10 panelWidth-20 panelHeight-20]);  % Adjust for padding


    %% === Nested Functions ===
    co = colororder;
    function runCogSat()
        drawingActive = true;
        cla(kpi1ax); cla(kpi2ax); cla(kpi3ax); cla(kpi4ax); cla(kpi5ax);
    
        on_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2);
        on_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2);
        on_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2);
        on_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2);
        on_kpi5 = animatedline(kpi5ax, 'Color', co(5,:), 'LineWidth', 2);
    
        legend(kpi1ax, {'CogSat'}, 'Location', 'southeast');
        legend(kpi2ax, {'CogSat'}, 'Location', 'northeast');
        legend(kpi3ax, {'CogSat'}, 'Location', 'northeast');
        legend(kpi4ax, {'CogSat'}, 'Location', 'southeast');
        legend(kpi5ax, {'CogSat'}, 'Location', 'northeast');
    
        T = loadDataForChannels();
        for i = 1:height(T)
            if ~drawingActive, break; end
            t = T.Time(i);
            addpoints(on_kpi1, t, str2double(T.geo_thrpt_a2c(i)));
            addpoints(on_kpi2, t, str2double(T.leo_thrpt_a2c(i)));
            addpoints(on_kpi3, t, str2double(T.all_se_a2c(i))*100);
            addpoints(on_kpi4, t, str2double(T.geo_sinr_a2c(i)));
            addpoints(on_kpi5, t, str2double(T.leo_sinr_a2c(i)));
            drawnow limitrate; pause(0.3);
        end
    end
    function runBaseline()
        drawingActive = true;
        cla(kpi1ax); cla(kpi2ax); cla(kpi3ax); cla(kpi4ax); cla(kpi5ax);
    
        off_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi5 = animatedline(kpi5ax, 'Color', co(5,:), 'LineWidth', 2, 'LineStyle','--');
    
        legend(kpi1ax, {'Baseline'}, 'Location', 'southeast');
        legend(kpi2ax, {'Baseline'}, 'Location', 'northeast');
        legend(kpi3ax, {'Baseline'}, 'Location', 'northeast');
        legend(kpi4ax, {'Baseline'}, 'Location', 'southeast');
        legend(kpi5ax, {'Baseline'}, 'Location', 'northeast');
    
        T = loadDataForChannels();
        for i = 1:height(T)
            if ~drawingActive, break; end
            t = T.Time(i);
            addpoints(off_kpi1, t, str2double(T.geo_thrpt_baseline(i)));
            addpoints(off_kpi2, t, str2double(T.leo_thrpt_baseline(i)));
            addpoints(off_kpi3, t, str2double(T.all_se_baseline(i))*100);
            addpoints(off_kpi4, t, str2double(T.geo_sinr_baseline(i)));
            addpoints(off_kpi5, t, str2double(T.leo_sinr_baseline(i)));
            drawnow limitrate; pause(0.3);
        end
    end
    function runCombined()
        drawingActive = true;
        cla(kpi1ax); cla(kpi2ax); cla(kpi3ax); cla(kpi4ax); cla(kpi5ax);
    
        on_kpi1 = animatedline(kpi1ax, 'Color', co(1,:), 'LineWidth', 2);
        on_kpi2 = animatedline(kpi2ax, 'Color', co(2,:), 'LineWidth', 2);
        on_kpi3 = animatedline(kpi3ax, 'Color', co(3,:), 'LineWidth', 2);
        on_kpi4 = animatedline(kpi4ax, 'Color', co(4,:), 'LineWidth', 2);
        on_kpi5 = animatedline(kpi5ax, 'Color', co(5,:), 'LineWidth', 2);
    
        off_kpi1 = animatedline(kpi1ax, 'Color', co(7,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi2 = animatedline(kpi2ax, 'Color', co(6,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi3 = animatedline(kpi3ax, 'Color', co(5,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi4 = animatedline(kpi4ax, 'Color', co(3,:), 'LineWidth', 2, 'LineStyle','--');
        off_kpi5 = animatedline(kpi5ax, 'Color', co(2,:), 'LineWidth', 2, 'LineStyle','--');
    
        legend(kpi1ax, {'CogSat','Baseline'}, 'Location', 'southeast');
        legend(kpi2ax, {'CogSat','Baseline'}, 'Location', 'northeast');
        legend(kpi3ax, {'CogSat','Baseline'}, 'Location', 'northeast');
        legend(kpi4ax, {'CogSat','Baseline'}, 'Location', 'southeast');
        legend(kpi5ax, {'CogSat','Baseline'}, 'Location', 'northeast');
    
        T = loadDataForChannels();
        for i = 1:height(T)
            if ~drawingActive, break; end
            t = T.Time(i);
    
            % CogSat
            addpoints(on_kpi1, t, str2double(T.geo_thrpt_a2c(i)));
            addpoints(on_kpi2, t, str2double(T.leo_thrpt_a2c(i)));
            addpoints(on_kpi3, t, str2double(T.all_se_a2c(i))*100);
            addpoints(on_kpi4, t, str2double(T.geo_sinr_a2c(i)));
            addpoints(on_kpi5, t, str2double(T.leo_sinr_a2c(i)));
    
            % Baseline
            addpoints(off_kpi1, t, str2double(T.geo_thrpt_baseline(i)));
            addpoints(off_kpi2, t, str2double(T.leo_thrpt_baseline(i)));
            addpoints(off_kpi3, t, str2double(T.all_se_baseline(i))*100);
            addpoints(off_kpi4, t, str2double(T.geo_sinr_baseline(i)));
            addpoints(off_kpi5, t, str2double(T.leo_sinr_baseline(i)));
    
            drawnow limitrate; pause(0.3);
        end
    end
    
    function T = loadDataForChannels()
        selectedChannels = Channelnum.Value;
        switch selectedChannels
            case '10'
                filename = 'Data10.xlsx';
            case '15'
                filename = 'Data15.xlsx';
            case '20'
                filename = 'Data20.xlsx';
            case '25'
                filename = 'Data25.xlsx';
            case '30'
                filename = 'Data30.xlsx';
            otherwise
                error('Unknown selection!');
        end
        T = readtable(filename);
    end

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
            satelliteScenarioViewer(sc);
            viewer.Camera.Target = [134 -25 0];
            play(sc,PlaybackSpeedMultiplier=100);

        catch ME
            disp("Error loading Satellite Scenario: " + ME.message);
        end
    end
    function updateFrame(~,~)
        if isvalid(fig)
            if hasFrame(v)
                frame = readFrame(v);
                imshow(frame, 'Parent', vidAx);
            else
                v.CurrentTime = 0;
            end
        else
            stop(vidTimer);
            delete(vidTimer);
        end
    end
    function stopDrawing()
        drawingActive = false;
        disp('Drawing stopped by user.');
    end


end 
