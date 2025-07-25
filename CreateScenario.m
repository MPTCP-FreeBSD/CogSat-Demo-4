clear;clc;close all hidden
%% P02_GStations
fprintf('Setting up ground stations in Australia...\n');
geoCities = {
    'Sydney',       -33.8688, 151.2093;
    'Melbourne',    -37.8136, 144.9631;
    'Brisbane',     -27.4698, 153.0251;
    'Perth',        -31.9505, 115.8605;
    'Adelaide',     -34.9285, 138.6007;
    'Hobart',       -42.8821, 147.3272;
    'Darwin',       -12.4634, 130.8456;
    'Canberra',     -35.2809, 149.1300;
    'Cairns',       -16.9203, 145.7710;
    'Gold_Coast',   -28.0167, 153.4000;
};
leoCities = {
    'Newcastle',    -32.9283, 151.7817;
    'Geelong',      -38.1499, 144.3617;
    'Sunshine_Coast', -26.6500, 153.0667;
    'Mandurah',     -32.5366, 115.7447;
    'Victor_Harbor', -35.5500, 138.6167;
    'Launceston',   -41.4333, 147.1667;
    'Katherine',    -14.4667, 132.2667;
    'Wollongong',   -34.4244, 150.8939;
    'Townsville',   -19.2500, 146.8167;
    'Toowoomba',    -27.5667, 151.9500;
};
geoGsList = cell(1, size(geoCities, 1));
leoGsList = cell(1, size(leoCities, 1));
%% Creating the satellite
E = wgs84Ellipsoid('meters');     % Reference ellipsoid (WGS-84)
startTime = datetime(2025, 4, 10, 2, 0, 0);  % Simulation start
duration_sec = 25 * 3600;                   % 30 min simulation in seconds
sampleTime = 30;                             % Time step in seconds
stopTime = startTime + seconds(duration_sec);
ts = startTime:seconds(sampleTime):stopTime;
%% LEO Walker-Star Constellation Parameters
walker.a = 1200e3 + earthRadius;   % Semi-major axis
walker.alfa = earthRadius / walker.a;
walker.Inc = 87;                   % Inclination in degrees (typical for OneWeb)
walker.NPlanes = 12;               % Number of orbital planes 
walker.SatsPerPlane = 49;          % Number of satellites per plane 
walker.PhaseOffset = 1;            % Phase offset for phasing between planes
leoNum = walker.NPlanes * walker.SatsPerPlane;
%% GEO Satellite Parameters
geoNum = 1;                        % Number of GEO satellites (adjust as needed)
geoLong = [10, 160, 170];         % GEO longitudes [deg E]
geo.a = 35786e3 + earthRadius;     % Semi-major axis
geo.e = 0;                         % Eccentrivcity for circular orbit
geo.Inc = 0;                       % Inclination in degrees for Equatorial plane
geo.omega = 0;                     % Argument of periapsis
geo.mu = 0;                        % True anamoly
%% Creating satellite
fprintf('Creating satellite scenario...\n');
sc = satelliteScenario(startTime, stopTime, sampleTime);
%% Create the LEO satellite
fprintf('Creating LEO Walker-Star constellation...\n');
leoSats = walkerStar(sc, ...
    walker.a, ...
    walker.Inc, ...
    walker.SatsPerPlane * walker.NPlanes, ...
    walker.NPlanes, ...
    walker.PhaseOffset, ...
    'Name', " ", ...
    'OrbitPropagator', 'two-body-keplerian');
%% Create the GEO satellite
for i = 1:geoNum
    fprintf('  Creating GEO satellite %d at %d°E longitude\n', i, geoLong(i));
    geoSats{i} = satellite(sc, geo.a, geo.e, geo.Inc, geo.omega, geo.mu, geoLong(i), ...
        'Name', sprintf('GEO-%d', i), 'OrbitPropagator', 'two-body-keplerian');
    geoSats{i}.MarkerColor = [0.9290 0.6940 0.1250];  % Orange
end
%% Create ground stations
fprintf('Setting up ground stations in Australia...\n');
for i = 1:size(geoCities,1)
    geoGsList{i} = groundStation(sc, geoCities{i,2}, geoCities{i,3}, 'Name', geoCities{i,1});
    geoGsList{i}.MarkerColor = [1 0 0];  % Red
end
for i = 1:size(leoCities,1)
    leoGsList{i} = groundStation(sc, leoCities{i,2}, leoCities{i,3}, 'Name', leoCities{i,1});
    leoGsList{i}.MarkerColor = [0 0 1];  % Blue
end
%% Create links between GEO satellites and GEO ground stations
 for i=1 : length(geoGsList)
    accessObj = access(geoSats{1}, geoGsList{i});
    accessObj.LineColor = [1 1 0];   % Yellow
    accessObj.LineWidth = 1.5;
 end
%% Create links between LEO satellites and LEO ground stations
fprintf('Creating illustrative links from LEO satellites to GSs...\n');
% Select a few LEO satellites (e.g., 1st from every 60 satellites)
selectedLEOs = leoSats(1:5:leoNum);  % Adjust spacing as desired
for i = 1:length(selectedLEOs)
    for j = 1:length(leoGsList)
        accessObj = access(selectedLEOs(i), leoGsList{j});
        accessObj.LineColor = [0 1 0];   % Green
        accessObj.LineWidth = 1.5;
    end
end
%% Run
v = satelliteScenarioViewer(sc);
viewer.Camera.Target = [134 -25 0];
play(sc,PlaybackSpeedMultiplier=100);
%% SAve
 % save("SatelliteScenario.mat",'sc')