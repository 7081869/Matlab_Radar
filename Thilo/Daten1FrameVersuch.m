% Testskript geschrieben von Thilo und Joshie
% Ziel: Auswerten 1 Frame echter Daten
%% Startup
clc;
clear;
close all;
%% Constants
global lambda;
global antenna_spacing;

antenna_spacing = 6.22e-3;      % in meters
c0 = 3e8;                       % Speed of light in vacuum

down_chirp_duration = 100e-6;   % Time required for down chirp
chirp_to_chirp_delay = 100e-6;  % Standby time interval between consecutive chirps

%% Raw Data Name
%fdata = 'data_P2G_1person_legacy';
fdata = 'data_P2G_1person';

%% !!!!!!!! 
%  to parse the XML file, the package XML2STRUCT is required.
%  Please download the package from
%  https://de.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
%  unzip it and copy the files into this folder
%  the function f_parse_data is not compatible with the build-in matlab
%  function!
%
if not(isfile("xml2struct.m"))
   error("Please install xml2struct.m, please see comments in the source file above!") 
end

%% Load the Raw Data file
[frame, frame_count, calib_data, sXML, Header] = f_parse_data(fdata); % Data Parser

%% Load Real Raw Data
clc
disp('******************************************************************');
addpath('..\..\RadarSystemImplementation'); % add Matlab API
clear all %#ok<CLSCR>
close all
resetRS; % close and delete ports

% 1. Create radar system object
szPort = findRSPort; % find the right COM Port
oRS = RadarSystem(szPort); % creates the Radarsystem API object

% 2. Set endpoint properties
% The automatic trigger runs after startup by default
oRS.oEPRadarBase.stop_automatic_frame_trigger;      % stop it to change values
oRS.oEPRadarFMCW.lower_frequency_kHz = 24050000;    % lower FMCW frequency
oRS.oEPRadarFMCW.upper_frequency_kHz = 24220000;    % upper FMCW frequency
oRS.oEPRadarFMCW.tx_power = oRS.oEPRadarBase.max_tx_power;
oRS.oEPRadarBase.num_chirps_per_frame = 1;
oRS.oEPRadarBase.num_samples_per_chirp = 256;       % up to 4095 for single RX channel
oRS.oEPRadarBase.rx_mask = bin2dec('0011');         % enable RX1 & RX2 antenna
oRS.oEPRadarFMCW.direction = 'Up Only';

% 3. Trigger radar chirp, get the raw data and plot it
[mxRawData, sInfo] = oRS.oEPRadarBase.get_frame_data; % get raw data