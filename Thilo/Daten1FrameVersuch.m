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


%% Load Real Raw Data

disp('******************************************************************');
addpath('RadarSystemImplementation'); % add Matlab API
resetRS; % close and delete ports

% 1. Create radar system object
szPort = findRSPort; % find the right COM Port
oRS = RadarSystem(szPort); % creates the Radarsystem API object

% 2. Set endpoint properties
% The automatic trigger runs after startup by default
oRS.oEPRadarBase.stop_automatic_frame_trigger;      % stop it to change values
lower_frequency = 24050000;  
upper_frequency = 24220000;
num_samples_per_chirp = 128;
num_chirps_per_frame = 16;
oRS.oEPRadarFMCW.lower_frequency_kHz = lower_frequency;    % lower FMCW frequency
oRS.oEPRadarFMCW.upper_frequency_kHz = upper_frequency;    % upper FMCW frequency
oRS.oEPRadarFMCW.tx_power = oRS.oEPRadarBase.max_tx_power;
oRS.oEPRadarBase.num_chirps_per_frame = num_chirps_per_frame;
oRS.oEPRadarBase.num_samples_per_chirp = num_samples_per_chirp;       % up to 4095 for single RX channel
oRS.oEPRadarBase.rx_mask = bin2dec('0011');         % enable RX1 & RX2 antenna
oRS.oEPRadarFMCW.direction = 'Up Only';
%% Initialisierung Ausgabewerte
    strength = zeros(20, 3);
    range = zeros(20, 3);
    speed = zeros(20, 3);
    angle = zeros(20, 3);
    
    counter=0;
%% Andere Konstanten und Initialisierungen, Performance verbessern
    %% Extract FMCW chirp configuration from device data
    % Pulse repetition time
    up_chirp_duration = 300e-6; % Standard Wert, ?nderbar /ablesbar in der config.h unter Dave Project/P2G_FMCW

    PRT = up_chirp_duration + down_chirp_duration + chirp_to_chirp_delay; % Pulse repetition time : Delay between the start of two chirps

    % Bandwidth
    BW = (double(oRS.oEPRadarFMCW.upper_frequency_kHz) - double(oRS.oEPRadarFMCW.lower_frequency_kHz)) * 1e3;

    num_Tx_antennas = 1; % Number of Tx antennas, constant
    num_Rx_antennas = 2; % Number of Rx antennas, constant

    % Carrier frequency
    fC = (upper_frequency + lower_frequency) / 2 * 1e3;

    % Number of ADC samples per chirp
    NTS = num_samples_per_chirp;

    % Number of chirps per frame
    PN = num_chirps_per_frame;

    % Sampling frequency
    fS = num_samples_per_chirp/PRT;

    % Angle Offset
    angle_offset = -7;
 %% Algorithm Settings
    range_fft_size   = 256; % Zero padding by 2
    Doppler_fft_size =  32; % Zero padding by 2

    range_threshold   = 80; % Amplitude threshold to find peaks in Range FFT
    Doppler_threshold = 50; % Amplitude threshold to find peaks in Doppler FFT

    min_distance =  0.9; % Minimum distance of the target from the radar (recommended to be at least 0.9 m)
    max_distance = 7.0; % Maximum distance of the target from the radar (recommended to be maximum 25.0 m)

    max_num_targets = 3; % Maximum number of targets that can be detected   
 
%% Calculate Derived Parameters
    lambda = c0 / fC;

    Hz_to_mps_constant = lambda / 2;                % Conversion factor from frequency to speed in m/s

    IF_scale = 16 * 3.3 * range_fft_size / NTS; % IF scale 

    range_window_func = 2 * blackman(NTS);          % Window function for Range
    doppler_window_func = 2 * chebwin(PN);          % Window function for Doppler

    R_max = NTS * c0 / (2 * BW);                    % Maximum theoretical range for the system in m
    Chosen_distance = 8;
    dist_per_bin = R_max / range_fft_size;          % Resolution of every range bin in m

    array_bin_range = (0:range_fft_size-1) * double(dist_per_bin); % Vector of Range in m

    fD_max = 1 / (2 * PRT);                         % Maximum theoretical calue of the Doppler
    fD_per_bin = fD_max / (Doppler_fft_size/2);     % Value of doppler resolution per bin
    array_bin_fD = ((1:Doppler_fft_size) - Doppler_fft_size/2 - 1) * -fD_per_bin * Hz_to_mps_constant; % Vector of speed in m/s
 %% Initialize Structures & Data
    frame_count=1;
    
    target_measurements.strength = zeros(max_num_targets,frame_count);
    target_measurements.range    = zeros(max_num_targets,frame_count);
    target_measurements.speed    = zeros(max_num_targets,frame_count);
    target_measurements.angle    = zeros(max_num_targets,frame_count);

    range_tx1rx1_max = zeros(range_fft_size,1);

    range_tx1rx1_complete = zeros(range_fft_size,PN,frame_count);
    range_tx1rx2_complete = zeros(range_fft_size,PN,frame_count);
    

    %% ADC Calibration Data
    calib_data= oRS.oEPCalibration.get_calibration_data';
    N_cal = length(calib_data) / (2 * num_Rx_antennas);

    dec_idx = N_cal / NTS;

    calib_i1 = calib_data(1:dec_idx:N_cal);
    calib_q1 = calib_data(N_cal+1:dec_idx:2*N_cal);

    calib_i2 = calib_data(2*N_cal+1:dec_idx:3*N_cal);
    calib_q2 = calib_data(3*N_cal+1:dec_idx:4*N_cal);

    calib_rx1 = (calib_i1 + j * calib_q1).';
    calib_rx2 = (calib_i2 + j * calib_q2).';
%%
while(1)
    counter=counter+1; %Counter for graphs at the end

    % 3. Trigger radar chirp, get the raw data and plot it
    [frame, sInfo] = oRS.oEPRadarBase.get_frame_data; % get raw data
    

    %%% Manual calibration regarding the measurement scenario
    matrix_raw_data = frame;
    calib_rx1 = mean(matrix_raw_data(:,:,1),2);
    calib_rx2 = mean(matrix_raw_data(:,:,2),2);

    %% Process Frames
    %for fr_idx = 1:frame_count % Loop over all data frames, while the output window is still open
        fr_idx = 1;
        matrix_raw_data = frame; % (:,:,fr_idx); % Raw data for the frame being processed

        %% Antenna 1 & 2 Fast Time Processing
        %--------------------------- RX1 ----------------------------
        matrix_tx1rx1 = matrix_raw_data(:,1,:);   % data of first Rx antenna, first Rx antenna

        matrix_tx1rx1 = squeeze(matrix_tx1rx1); % Umwandlung der Matrix von 128x1x16 zu 128x16

        matrix_tx1rx1 = (matrix_tx1rx1 - repmat(calib_rx1,1,PN)).*IF_scale; % Anwendung der Calibrierungsdaten und Skalierung mit ZF Skala

        matrix_tx1rx1 = bsxfun(@minus, matrix_tx1rx1, mean(matrix_tx1rx1)); % Mean removal across range for RX1
        %Gemeint ist die Entfernung des Durchschnitts der Matrix (Mutma�ung: Nur die Ausrei�er sind wichtig zum Interpretieren (hohe Amplituden) 

        range_tx1rx1 = fft(matrix_tx1rx1.*repmat(range_window_func,1,PN),range_fft_size,1); % Windowing across range and range FFT for RX1
        % Please note: Since human target detection at far distances is barely
        % feasible, the computation of the FFT in the firmware is limited  to
        % the first half of the spectrum to save memory (also for RX2).

        range_tx1rx1_complete(:,:,fr_idx) = range_tx1rx1; % Save Range FFT for RX1 for every Frame

        %--------------------------- RX2 ----------------------------
        matrix_tx1rx2 = matrix_raw_data(:,2,:);         %data of second Rx antenna, first Tx antenna

        matrix_tx1rx2 = squeeze(matrix_tx1rx2);

        matrix_tx1rx2 = (matrix_tx1rx2 - repmat(calib_rx2,1,PN)).*IF_scale;

        matrix_tx1rx2 = bsxfun(@minus, matrix_tx1rx2, mean(matrix_tx1rx2)); % Mean removal across Range for Rx2

        range_tx1rx2 = fft(matrix_tx1rx2.*repmat(range_window_func,1,PN),range_fft_size,1); % Windowing across range and range FFT

        range_tx1rx2_complete(:,:,fr_idx) = range_tx1rx2; % Save range FFT for RX1 for every Frame

        %% Range Target Detection
        % Detect the targets in range by applying contant amplitude threshold over range

        range_tx1rx1_max = abs(max(range_tx1rx1,[],2)); % Data integration of range FFT over the chirps for target range detection
        % Sucht aus jeder Reihe der Matrix den Maximalwert der komplexen Zahl
        % und speichert diesen im Betrag in einem Spaltenvektor

        [tgt_range_idx, tgt_range_mag] = f_search_peak(range_tx1rx1_max, length(range_tx1rx1_max), range_threshold, max_num_targets, min_distance, max_distance, dist_per_bin);

        num_of_targets = length(tgt_range_idx);


        %% Antenna 1 & 2 Slow Time Processing
        %--------------------------- RX1 ----------------------------
        range_Doppler_tx1rx1 = zeros(range_fft_size, Doppler_fft_size);

        rx1_doppler_mean = mean(range_tx1rx1(tgt_range_idx,:),2); % Compute mean across doppler

        range_tx1rx1(tgt_range_idx,:) = range_tx1rx1(tgt_range_idx,:) - rx1_doppler_mean(1:num_of_targets); % Mean removal across Doppler

        range_Doppler_tx1rx1(tgt_range_idx,:) = fftshift(fft(range_tx1rx1(tgt_range_idx,:).*repmat(doppler_window_func.',num_of_targets,1),Doppler_fft_size,2),2); % Windowing across Doppler and Doppler FFT

        Rx_spectrum(:,:,1) = range_Doppler_tx1rx1; % Range Doppler spectrum

        %--------------------------- RX2 ----------------------------
        range_Doppler_tx1rx2 = zeros(range_fft_size, Doppler_fft_size);

        rx2_doppler_mean = mean(range_tx1rx2(tgt_range_idx,:),2); % Compute mean across Doppler

        range_tx1rx2(tgt_range_idx,:) = range_tx1rx2(tgt_range_idx,:) - rx2_doppler_mean(1:num_of_targets);% Mean removal across Doppler

        range_Doppler_tx1rx2(tgt_range_idx,:) = fftshift(fft(range_tx1rx2(tgt_range_idx,:).*repmat(doppler_window_func.',num_of_targets,1),Doppler_fft_size,2),2);% Windowing across Doppler and Doppler FFT

        Rx_spectrum(:,:,2) = range_Doppler_tx1rx2;  % Range Doppler spectrum

        %% Extraction of Indices from Range-Doppler Map
        tgt_doppler_idx = zeros(1,num_of_targets);

        z1 =  zeros(1,num_of_targets);
        z2 =  zeros(1,num_of_targets);

        for j = 1:num_of_targets
            [val, doppler_idx] = max(abs(range_Doppler_tx1rx1(tgt_range_idx(j), :)));
            % Consider the value of the range Doppler map for the two receivers for targets with non
            % zero speed to compute angle of arrival.
            % For zero Doppler (targets with zero speed) calculate mean
            % over Doppler to compute angle of arrival. Index 17 corresponds to zero Doppler
            if (val >= Doppler_threshold && doppler_idx ~= (Doppler_fft_size / 2 + 1))
                tgt_doppler_idx(j) = doppler_idx;

                z1(j) = Rx_spectrum(tgt_range_idx(j),tgt_doppler_idx(j),1);
                z2(j) = Rx_spectrum(tgt_range_idx(j),tgt_doppler_idx(j),2);
            else
                tgt_doppler_idx(j) = Doppler_fft_size / 2 + 1;

                z1(j) = rx1_doppler_mean(j);
                z2(j) = rx2_doppler_mean(j);
            end
        end

        %%  Measurement Update
        if (num_of_targets > 0)
            for j = 1:num_of_targets
                target_measurements.strength(fr_idx,j) = tgt_range_mag(j);
                target_measurements.range(   fr_idx,j) = (tgt_range_idx(j) - 1) * dist_per_bin;
                target_measurements.speed(   fr_idx,j) = (tgt_doppler_idx(j)- Doppler_fft_size/2 - 1) * -fD_per_bin * Hz_to_mps_constant;
                target_measurements.angle(   fr_idx,j) = f_estimate_angle(z1(j), z2(j)) + angle_offset;
            end
        end
    %end

    %% Visualization
    range_tx1rx1_max_abs = squeeze(abs(max(range_tx1rx1_complete,[],2)));
    range_tx1rx2_max_abs = squeeze(abs(max(range_tx1rx2_complete,[],2)));

    %%% Plot range FFT amplitude heatmap
    % This figure illustrates the distance information of the target(s) over
    % all frames within the pre-defined minimum and maximum ranges. The
    % brigther the color of a range FFT bin, the higher the range FFT amplitude
    % in this bin. The upper and lower subplot shows the information of Rx1 and
    % Rx2, respectively. Information on the exemplary data set is given at the
    % bottom of this file.
    
    %figure;
    
%     ax1 = subplot(2,1,1);
%     imagesc(1:frame_count,array_bin_range,range_tx1rx1_max_abs);
    title('Range FFT Amplitude Heatmap for RX1');
    xlabel('Frames');
    ylabel('Range (m)');
    set(gca,'YDir','normal');
    ylim([min_distance, max_distance]);

%     ax2 = subplot(2,1,2);
%     imagesc(1:frame_count,array_bin_range,range_tx1rx2_max_abs);
    title('Range FFT Amplitude Heatmap for RX2');
    xlabel('Frames');
    ylabel('Range (m)');
    set(gca,'YDir','normal');
    ylim([min_distance, max_distance]);
    
%       linkaxes([ax1,ax2],'xy')

    %%% Plot the target detection results (amplitude, range, speed, angle)
    % This figure illustrates the target information in four subplots:
    %    1) Range FFT amplitude depicts the signal strength of the reflected
    %       wave from the target and is dependent on the RCS and the distance
    %       of the target. The larger the RCS and the smaller the distance to
    %       the antenna, the higher the FFT amplitude.
    %       NOTE: A target is only detected if its amplitude is larger than
    %       the range_threshold. Otherwise, the FFT amplitude is set to zero.
    %    2) Range information of the target. Targets are detected only within
    %       min_distance and max_distance.
    %    3) Speed/velocity of the target. Positive value for an approaching
    %       target, negative value for a departing target.
    %       NOTE: If the maximum Doppler FFT amplitude is below the
    %       Doppler_threshold, the speed is set to zero. This does not
    %       influence the target detection, but can be used in tracking
    %       algorithms to extinguish static targets.
    %    4) Angle of the target. Positive value if the target is on the left
    %       side, negative value if the target is on the right side with respect 
    %       to the radar.
  
    
%     leg = [];
% 
%     for i = 1:num_of_targets
%         leg = [leg; 'Target ', num2str(i)];
% 
%         subplot(4,1,1);
%         hold on;
%         plot(target_measurements.strength(:,i));
% 
%         subplot(4,1,2);
%         hold on;
%         plot(target_measurements.range(:,i));
% 
%         subplot(4,1,3);
%         hold on;
%         plot(target_measurements.speed(:,i));
% 
%         subplot(4,1,4);
%         hold on;
%         plot(target_measurements.angle(:,i));
%     end
% 
%     ax1 = subplot(4,1,1);
%     plot([0,frame_count],[range_threshold,range_threshold],'k');
%     title ('FFT Amplitude');
%     xlabel('Frames');
%     ylabel('Amplitude');
%     leg_range = [leg; 'Range TH'];
%     legend(leg_range,'Location','EastOutside');
% 
%     ax2 = subplot(4,1,2);
%     title ('Range');
%     xlabel('Frames');
%     ylabel('Range (m)');
%     legend(leg,'Location','EastOutside');
% 
%     ax3 = subplot(4,1,3);
%     title ('Speed');
%     xlabel('Frames')
%     ylabel('Speed (m/s)');
%     legend(leg,'Location','EastOutside');
% 
%     ax4 = subplot(4,1,4);
%     title ('Angle');
%     xlabel('Frames')
%     ylabel('Angle (�)');
%     legend(leg,'Location','EastOutside');
% 
%     linkaxes([ax1,ax2,ax3,ax4],'x')

    %%% Information on the exemplary data sets
    % Description of the data set "data_P2G_1person_legacy" for all frames:
    %    0 -  100: tangentially movement from right to left at 3m
    %  100 -  190: tangentially movement from left to right at 5m
    %  190 -  300: tangentially movement from right to left at 8m
    %  300 -  400: azimuth movement from left to right at 3m for zero degree
    %  400 -  500: azimuth movement from right to left at 5m for zero degree
    %  500 -  600: azimuth movement from left to right at 8m for zero degree
    %  700 - 1175: repeated approaching from the right side to the left side
    %              and departing the same way back for different ranges.
    % 1175 - 1550: departing and approaching at approximately zero degree
    %
    % Description of the data set "data_P2G_1person" for all frames:
    %    0 -  100: tangentially movement from right to left at 3.0m
    %  100 -  200: tangentially movement from left to right at 5.5m
    %  200 -  300: tangentially movement from right to left at 8.5m
    %  300 -  400: azimuth movement from left to right at 3.0m for zero degree
    %  400 -  500: azimuth movement from right to left at 5.5m for zero degree
    %  500 -  560: azimuth movement from left to right at 8.5m for zero degree
    %  560 -  980: repeated approaching from the right side to the left side
    %              and departing the same way back for different ranges.
    %  980 - 1480: repeated approaching and departing at approximately zero
    %              degree for different ranges
    %
    % NOTE on the range FFT amplitude:
    % Due to positive and negative interferences of multi-path reflections and
    % specle, the amplitude is fluctuating for human targets. In worst case,
    % the amplitude is below the range_threshold in some frames and the target
    % sporadically disappears. This can be prevented by further signal
    % processing like tracking.
    %
    % NOTE on the speed data:
    % Since the obervation time is only 8ms per frame,only an instant is shown.
    % For tangentially movements, when the target is step-by-step approaching
    % and departing, the sign of the velocity is fluctuating. Even for radial
    % movements, specle can induce a wrong direction of movement. 
    
        

    leg = [];
    for i = 1:num_of_targets
        
       leg = [leg; 'Target ', num2str(i)];
        % fprintf("Target %d\n", i);
       if counter<21
           strength(counter, i) = (target_measurements.strength(1,i));

           range(counter, i) = (target_measurements.range(1,i));

           speed(counter, i) = (target_measurements.speed(1,i));

           angle(counter, i) = (target_measurements.angle(1,i));
       else
           strength(1:19, i)=strength(2:20, i);
           range(1:19, i)=range(2:20, i);
           speed(1:19, i)=speed(2:20, i);
           angle(1:19, i)=angle(2:20, i);
           
           strength(20, i) = (target_measurements.strength(1,i));

           range(20, i) = (target_measurements.range(1,i));

           speed(20, i) = (target_measurements.speed(1,i));

           angle(20, i) = (target_measurements.angle(1,i));
       end
    end

    
    
    
    set(gcf,'color','w'); % Set Background color white
%    
    z='.';
    subplot(4,1,1);
    hold on;
    plot((1:20),strength(:,1),z,(1:20),strength(:,2),z,(1:20),strength(:,3),z)
      title ('FFT Amplitude');
     xlabel('Frames')
     ylabel('Amplitude');
     leg_range = [leg; 'Range TH'];
     legend(leg_range,'Location','EastOutside');
    subplot(4,1,2);
    hold on;
    plot((1:20),range(:,1),z,(1:20),range(:,2),z,(1:20),range(:,3),z)
    title ('Range');
    xlabel('Frames')
    ylabel('Range / m');
    legend(leg,'Location','EastOutside');
    subplot(4,1,3);
    hold on;    
    plot((1:20),speed(:,1),z,(1:20),speed(:,2),z,(1:20),speed(:,3),z)
    title ('Geschwindigkeit');
    xlabel('Frames')
    ylabel('Geschwindigkeit in m/s');
    legend(leg,'Location','EastOutside');
    subplot(4,1,4);
    hold on;
    plot((1:20),angle(:,1),z,(1:20),angle(:,2),z,(1:20),angle(:,3),z)
    title ('Winkel');
    xlabel('Frames')
    ylabel('Winkel in �');
    legend(leg,'Location','EastOutside');
    pause(0.1)
end