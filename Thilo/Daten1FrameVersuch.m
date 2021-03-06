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

%% Variablen Durchschnittsberechnung
Range_tolerance = 1; %In Metern
angle_tolerance = 17;
appearance_border=6;
max_objects = 20; %Beinhaltet Fehlerhaft erkannte
wertespeicher= NaN(30,2);
zaehler=1;
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
    max_distance = 8.0; % Maximum distance of the target from the radar (recommended to be maximum 25.0 m)

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
%% Konstanten Target_counter und Initialisierungen
Room_Counter = 0;
Max_RealTargets = max_num_targets;

%?bergangsgrenzen
Entrance_LowRangeLimit = 6;  
Entrance_HighRangeLimit = 7;
Room_LowRangeLimit = 2;
Room_HighRangeLimit = 3;

DetectionDistance = 1; 
%max. Abstand in m zwischen altem und neuem Target, dass er noch als gleiches target erkannt wird 
AngleDetectionDistance = 10;

min_Difference_Location = NaN(Max_RealTargets,Max_RealTargets); %speichert g?ltige kleine Abtandsdifferenz werte
Difference = NaN(Max_RealTargets,Max_RealTargets); %speichert die Differenz der Distance
min_Difference_Angle = NaN(Max_RealTargets,Max_RealTargets); %speichert g?ltige kleine Winkeldifferenzen
Angle_Difference = NaN(Max_RealTargets,Max_RealTargets); %speichert die Differenz der Angle
    
for i = 1:Max_RealTargets
Targets_aktuell(i) = FTarget;
Targets(i) = FTarget;
end

assignable = 0;
isMinColumnAvailable = 0;
%%
wiederholungen = 0;
fprintf('This message is sent at start %s\n', datestr(now,'HH:MM:SS.FFF'))
while(1)
    wiederholungen=wiederholungen+1;
    if mod(wiederholungen, 1000)==0
        fprintf('This message is sent 10000 repetitions %s\n', datestr(now,'HH:MM:SS.FFF'))
    end
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
        %Gemeint ist die Entfernung des Durchschnitts der Matrix (Mutma?ung: Nur die Ausrei?er sind wichtig zum Interpretieren (hohe Amplituden) 

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
%     title('Range FFT Amplitude Heatmap for RX1');
%     xlabel('Frames');
%     ylabel('Range (m)');
%     set(gca,'YDir','normal');
%     ylim([min_distance, max_distance]);
% 
% %     ax2 = subplot(2,1,2);
% %     imagesc(1:frame_count,array_bin_range,range_tx1rx2_max_abs);
%     title('Range FFT Amplitude Heatmap for RX2');
%     xlabel('Frames');
%     ylabel('Range (m)');
%     set(gca,'YDir','normal');
%     ylim([min_distance, max_distance]);
    
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
%     ylabel('Angle (?)');
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
    
        


   
     
     
 
        
           
       if counter<21
           for i = 1:max_num_targets
               if i > num_of_targets
                   strength(counter, i) = NaN;

                   range(counter, i) = NaN;

                   speed(counter, i) = NaN;

                   angle(counter, i) = NaN;
               else    
                   strength(counter, i) = (target_measurements.strength(1,i));

                   range(counter, i) = (target_measurements.range(1,i));

                   speed(counter, i) = (target_measurements.speed(1,i));

                   angle(counter, i) = (target_measurements.angle(1,i));
               end
           end
       else
           for i = 1:max_num_targets
               strength(1:19, i)=strength(2:20, i);
               range(1:19, i)=range(2:20, i);
               speed(1:19, i)=speed(2:20, i);
               angle(1:19, i)=angle(2:20, i);
               if i > num_of_targets
                   strength(20, i) = NaN;
                   range(20, i) = NaN;
                   speed(20, i) = NaN;
                   angle(20, i) = NaN;
               else
                   s = (target_measurements.strength(1,i));
                   strength(20, i) = s;

    %                disp('target: ')
    %                disp(i)
                   r = (target_measurements.range(1,i));
                   range(20, i) = r;


                   s = (target_measurements.speed(1,i));
                   speed(20, i) = s;


                   a = (target_measurements.angle(1,i));
                   angle(20, i) = a;
               end
           end
       
%% Durchschnittswertsbildung von Distanz und Winkel ?ber die letzten 20 Werte
            Object_count = 0;
            zugeordnet = false;
            position=1;

            clear object_array
            clear output_array
            for k = 1:max_objects
                object_array(k) = Target;
            end

            for x=1:20
                for y = 1:3
                    %Mit bisher Vorhandenen Objekten vergleichen, wenn kein Treffer
                    %gefunden neues Objekt erstellen
                    if ~isnan(range(x,y))
                        zugeordnet = false;
                        for k = 1:Object_count
                            if Nearto(range(x,y), object_array(k).averagerange, Range_tolerance, angle(x,y), object_array(k).averageangle, angle_tolerance)
                                object_array(k).Count = object_array(k).Count+1;
                                object_array(k).Werterange(object_array(k).Count)=range(x,y);
                                object_array(k).Werteangle(object_array(k).Count)=angle(x,y);
                                object_array(k).Wertespeed(object_array(k).Count)=speed(x,y);
                               % fprintf('Wert %f zu Durchschnitt %f hinzugef?gt, Winkel %f zu Durchschnitt %f hinzugef?gt, Speed: %f zu Durchschnitt %f hinzugef?gt; Objekt %d\n', range(x,y), object_array(k).averagerange,angle(x,y), object_array(k).averageangle,speed(x,y), object_array(k).averageangle, Object_count)

                                object_array(k).averagerange=object_array(k).Buildaveragerange();
                                object_array(k).averageangle=object_array(k).Buildaverageangle();
                                object_array(k).averagespeed=object_array(k).Buildaveragespeed();
                                zugeordnet = true;

                                break;

                            end
                        end
                        if not(zugeordnet)
                            if Object_count>=max_objects
                                disp('Zu viele Fehlerhafte Targets Erkannt')
                                break;
                            else
                               Object_count = Object_count +1;
                               object_array(Object_count).Count = 1;
                               object_array(Object_count).Werterange(1) = range(x,y);
                               object_array(Object_count).Werteangle(1) = angle(x,y);
                               object_array(Object_count).Wertespeed(1) = speed(x,y);
                               object_array(Object_count).InUse = true;
                               object_array(Object_count).averagerange=object_array(Object_count).Buildaveragerange();
                               object_array(Object_count).averageangle=object_array(Object_count).Buildaverageangle();
                               object_array(Object_count).averagespeed=object_array(Object_count).Buildaveragespeed();
                              % fprintf('Neues Objekt erstellt an Position %d mit Wert %f und Winkel %f und Speed %f \n', Object_count, range(x,y), angle(x,y), speed(x,y))
                            end   
                        end
                    end
                end
            end
            
            for k = 1:max_objects
                output_array(k) = FTarget;
            end
            used = [0, 0];
            for i = 1 : 3
                highest = [0 0]; %position und wert
                for k = 1:max_objects
                    if ((object_array(k).Count >= appearance_border)&(k~=used(1))&(k~=used(2)))
                            if object_array(k).Count > highest(2)
                               highest(1) = k;
                               highest(2) = object_array(k).Count;
                               used(i) = k;
                            end                            
                    end
                end
                if highest(1) ~= 0
                    output_array(position).range = object_array(highest(1)).averagerange;
                    output_array(position).angle = object_array(highest(1)).averageangle;
                    output_array(position).speed = object_array(highest(1)).averagespeed;
                    position = position +1;
                end
            end
            
              
  %% Target Counter 
             fprintf("Room Counter = %d\n", Room_Counter);
                %hier ?bergabe neue Targets
                position = position - 1;
                clear Targets;
                for i = 1:position
                    Targets(i) = output_array(i);
                    NewTargetRange = Targets(i).range
                    NewTargetAngle = Targets(i).angle
                end

                %Erster Durchlauf
                if counter == 21
                    for i = 1:position
                    Targets_aktuell(i) = Targets(i);
                    end
                end
                
                if counter > 21
                    min_Difference_Location = NaN(position,position);
                    min_Difference_Angle = NaN(position,position);
                    Difference = NaN(position,position);
                    Angle_Difference = NaN(position,position);

                    %hier abgleich mit alten targets
                    for i = 1:position                             
                            %sucht das n?chste Target, minimaler Abstand suchen
                            for j = 1:position
                                Difference(i,j) = abs(Targets_aktuell(i).range - Targets(j).range);
                                Angle_Difference(i,j) = abs(Targets_aktuell(i).angle - Targets(j).angle);

                                if (Difference(i,j) <= DetectionDistance) && (~isnan(Difference(i,j))) ...
                                  && (Angle_Difference(i,j) <= AngleDetectionDistance) && (~isnan(Angle_Difference(i,j)))

                                  min_Difference_Location(i,j) = Difference(i,j);
                                  min_Difference_Angle(i,j) = Angle_Difference(i,j);
                                  %hier werden schon nur die gefilterten Werte gespeichert
                                end    
                            end
                    end

                 %Wo ist der minimalste Abstand?
                    minValue = -1;
                    minRow = 0;
                    minColumn = 0;
                    minValue = min(min_Difference_Location,[],2,'omitnan');
                   [minRow, minColumn] = find(min_Difference_Location == minValue);
                    assignment_Counter = 0;
                    
                    for i = 1:position

                       if i<size(minColumn, 1)
                        %?berpr?fung ob neue Targets 2 mal zugeordnet werden 
                        j = i + 1;    
                            for k = j:size(minColumn, 1)
                                if minColumn(i) == minColumn(k)
                                    % falls gleiche Spalten, nach anderem
                                    % nahen objekt suchen, sonst l?schen
                                    fprintf("Target mit Range %.4f gel?scht, doppelt nahe distanz\n", Targets_aktuell(k).range)
                                    Targets_aktuell(k) = clearTarget(Targets_aktuell(k)); %%2. Target in der N?he l?schen
                                end
                            end
                            clear j;
                        end
                        %Zuweisung neue an aktuell Targets, wenn altes Target gel?scht ist
                        if ~(isnan(Targets_aktuell(i).range) &&  isnan(Targets_aktuell(i).speed) && isnan(Targets_aktuell(i).angle) && (Targets_aktuell(i).origin == ""))
                            %Zuweisung minimaler Abstand
                            assignment_Counter = assignment_Counter +1;
                            assignable = (size(minColumn, 1) >= assignment_Counter);

                            if assignable        
                                fprintf("Neues Target Range %.4f = Altes Target Range %.4f\n", Targets(minColumn(assignment_Counter)).range, Targets_aktuell(i).range)
                                Targets_aktuell(i).range = Targets(minColumn(assignment_Counter)).range;
                                Targets_aktuell(i).speed = Targets(minColumn(assignment_Counter)).speed;
                                Targets_aktuell(i).angle = Targets(minColumn(assignment_Counter)).angle;                            
                            end
                        else
                            %  Zuweisung frische Targets
                            Targets_aktuell(i) = Targets(i);
                            fprintf("Neues Target mit Range %.4f\n", Targets_aktuell(i).range)
                        end
                      
                    end
                 end

                    %Hier werden alte Targets gel?scht, die nicht mehr zuweisbar sind 
                    if position < Max_RealTargets
                        for j = position+1:Max_RealTargets
                           % fprintf("Target mit Range %.4f nicht mehr findbar, gel?scht\n", Targets_aktuell(j).range)
                            Targets_aktuell(j) = clearTarget(Targets_aktuell(j)); 
                            %Target gel?scht, wenn nicht mehr sichtbar
                            clear figure(j)
                        end
                     end

                %Hier Logik und Output und Visualierung 
                for i = 1:position
                    
                set(gcf,'color','w'); % Set Background color white
                figure(i)
                polarplot(deg2rad(Targets_aktuell(i).angle), Targets_aktuell(i).range, 'o')
                legendstr = sprintf('Origin is %s\nCurrent Speed is %f', Targets_aktuell(i).origin, Targets_aktuell(i).speed);
                legend(legendstr)
                titlestr = sprintf("Room Counter = %d", Room_Counter);
                title(titlestr)
                ax = gca;
                ax.ThetaZeroLocation = 'Top';
                
                 if Targets_aktuell(i).range > Entrance_HighRangeLimit
                       fprintf("Target outside, Upper Range\n")
                       if Targets_aktuell(i).origin == "Lower"
                        Room_Counter = Room_Counter - 1;
                        fprintf("Target left\nCounter: %d", Room_Counter);
                       Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end

                    if (Targets_aktuell(i).range <= Entrance_HighRangeLimit) && (Targets_aktuell(i).range >= Entrance_LowRangeLimit)
                       fprintf("Target in Entrance Area\n")
                       if Targets_aktuell(i).origin == ""
                            Targets_aktuell(i).origin = "Upper";
                       end
                    end

                    if (Targets_aktuell(i).range > Room_HighRangeLimit) && (Targets_aktuell(i).range < Entrance_LowRangeLimit)
                       fprintf("Target in Supervision Area\n")
                       if Targets_aktuell(i).origin == ""
                            fprintf("Error: Target appeared in the middle, Target deleted\n");
                            Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end

                    if (Targets_aktuell(i).range >= Room_LowRangeLimit) && (Targets_aktuell(i).range <= Room_HighRangeLimit)
                       fprintf("Target in Room Area\n")
                       if Targets_aktuell(i).origin == ""
                        Targets_aktuell(i).origin = "Lower";
                       end
                    end

                    if (Targets_aktuell(i).range < Room_LowRangeLimit)
                       fprintf("Target outside, Lower Range\n")
                       if Targets_aktuell(i).origin == "Upper"
                        Room_Counter = Room_Counter + 1;
                        fprintf("Target entered\nCounter: %d", Room_Counter);
                       Targets_aktuell(i) = clearTarget(Targets_aktuell(i));
                       end
                    end
                
                

%                z='.';
%                figure(1)
%                 plot((1:5),Targets_aktuell(i).angle,z)
%                 title ('Winkel Target');
%                 xlabel('Frames')
%                 ylabel('Winkel in ?');
%                 legend(leg,'Location','EastOutside');
%                 grid
%                figure(2)
%                 plot((1:5),Targets_aktuell(i).range,z)
%                 title ('Range Target');
%                 xlabel('Frames')
%                 ylabel('Range / m');
%                 legend(leg,'Location','EastOutside');
%                 grid
%                figure(3)    
%                 plot((1:5),Targets_aktuell(i).speed ,z)
%                 title ('Geschwindigkeit Target');
%                 xlabel('Frames')
%                 ylabel('Geschwindigkeit in m/s');
%                 legend(leg,'Location','EastOutside');
%                 grid
                
                end        
       end

            
   
    
   
   
end