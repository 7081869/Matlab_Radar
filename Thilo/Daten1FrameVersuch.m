%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (c) 2018-2020, Infineon Technologies AG
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,are permitted provided that the
% following conditions are met:
%
% Redistributions of source code must retain the above copyright notice, this list of conditions and the following
% disclaimer.
%
% Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
% disclaimer in the documentation and/or other materials provided with the distribution.
%
% Neither the name of the copyright holders nor the names of its contributors may be used to endorse or promote
% products derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE  FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY,OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%
% This examples shows the Range-Doppler processing for the collected raw
% data and computation of range, speed, and angle of the target(s).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% NOTES:
%
% For FMCW modulation and one chirp per frame only the range FFT can be
% computed and the Doppler FFT has to be omitted.
% For Doppler modulation there is no FMCWEndpoint in the XML file, the
% range FFT has to be omitted and the Doppler FFT has to be directly computed.
% 
% Tracking has not been used in this code. Range, Doppler and angle
% estimates are obatined for every frame and plotted. To obtain better
% results, tracking has to be used.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
addpath('RadarSystemImplementation'); % add Matlab API
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
frame = mxRawData;
frame_count=sInfo.frame_number;
calib_data= oRs.oEPCalibration.get_calibration_data(oRs);


