classdef EPRadarFMCW < handle
    
    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarFMCW(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end
        
        function initValues(obj)
            obj.get_fmcw_configuration
            obj.get_bandwidth_per_second
        end
        
        parsePayload(obj, RX_content)
        doTransmission(obj, message)        
    end

    methods (Hidden) % communication with endpoint
        set_fmcw_configuration(obj)
        get_fmcw_configuration(obj)
        get_bandwidth_per_second(obj)
    end
    
    methods (Hidden) % parsing of incoming messages
        parseMSG_SET_CONFIGURATION(obj, payload)
        parseMSG_SET_BW_PER_SECOND(obj, payload)
    end
    
    %% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RFMC'; % ep_radar_fmcw_definition     0x52464D43
    end
    
    properties (Hidden) % general class
        uEndpointID
        oRS
    end

    properties (Hidden) % data properties
        % CONFIGURATION
        m_lower_frequency_kHz
        m_upper_frequency_kHz
        m_direction
        m_tx_power

        % BW_PER_SECOND
        m_bandwidth_per_second
    end

    properties (Dependent)
        % CONFIGURATION
        lower_frequency_kHz
        upper_frequency_kHz
        direction
        tx_power
        
    end

    properties (Dependent, SetAccess = private)
        % BW_PER_SECOND
        bandwidth_per_second
    end

    properties (Access = private, Constant)	% message ids
        MSG_GET_CONFIGURATION     = uint8(hex2dec('00')); % A message to query the FMCW configuration.
        MSG_SET_CONFIGURATION     = uint8(hex2dec('01')); % A message containing the FMCW configuration.
        MSG_GET_BW_PER_SECOND     = uint8(hex2dec('02')); % A message to query the bandwidth per second.
        MSG_SET_BW_PER_SECOND     = uint8(hex2dec('02')); % A message containing the bandwidth per second.
    end
    
    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        % CONFIGURATION
        function val = get.lower_frequency_kHz(obj)
            val = obj.m_lower_frequency_kHz;
        end
        function set.lower_frequency_kHz(obj, val)
            obj.m_lower_frequency_kHz = val;
            obj.set_fmcw_configuration;
            obj.get_fmcw_configuration;
        end
        
        function val = get.upper_frequency_kHz(obj)
            val = obj.m_upper_frequency_kHz;
        end
        function set.upper_frequency_kHz(obj, val)
            obj.m_upper_frequency_kHz = val;
            obj.set_fmcw_configuration;
            obj.get_fmcw_configuration;
        end
        
        function val = get.direction(obj)
            switch obj.m_direction
                case 0 % EP_RADAR_FMCW_DIR_UPCHIRP_ONLY All chirps of a frame start at the lower FMCW frequency and ramp up to the upper FMCW frequency.
                    val = 'Up Only';
                case 1 % EP_RADAR_FMCW_DIR_DOWNCHIRP_ONLY All chirps of a frame start at the upper FMCW frequency and ramp down to the lower FMCW frequency.
                    val = 'Down Only';
                case 2 % EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_UP Only the odd chirps of a frame start at the lower RF frequency and ramp up to the upper FMCW frequency. The even chirps of a frame go from the upper to the lower FMCW frequency.
                    val = 'Up Down';
                case 3 % EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_DOWN Only the even chirps of a frame start at the lower RF frequency and ramp up to the upper FMCW frequency. The odd chirps of a frame go from the upper to the lower RF frequency.
                    val = 'Down Up';
            end
        end
        function set.direction(obj, val)
            switch val
                case {0, 'Up Only', 'EP_RADAR_FMCW_DIR_UPCHIRP_ONLY'}; % EP_RADAR_FMCW_DIR_UPCHIRP_ONLY All chirps of a frame start at the lower FMCW frequency and ramp up to the upper FMCW frequency.
                    obj.m_direction = 0;
                case {1, 'Down Only', 'EP_RADAR_FMCW_DIR_DOWNCHIRP_ONLY'}; % EP_RADAR_FMCW_DIR_DOWNCHIRP_ONLY All chirps of a frame start at the upper FMCW frequency and ramp down to the lower FMCW frequency.
                    obj.m_direction = 1;
                case {2, 'Up Down', 'EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_UP'}; % EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_UP Only the odd chirps of a frame start at the lower RF frequency and ramp up to the upper FMCW frequency. The even chirps of a frame go from the upper to the lower FMCW frequency.
                    obj.m_direction = 2;
                case {3, 'Down Up', 'EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_DOWN'}; % EP_RADAR_FMCW_DIR_ALTERNATING_FIRST_DOWN Only the even chirps of a frame start at the lower RF frequency and ramp up to the upper FMCW frequency. The odd chirps of a frame go from the upper to the lower RF frequency.
                    obj.m_direction = 3;
            end
            obj.set_fmcw_configuration;
            obj.get_fmcw_configuration;
        end
        
        function val = get.tx_power(obj)
            val = obj.m_tx_power;
        end
        function set.tx_power(obj, val)
            obj.m_tx_power = val;
            obj.set_fmcw_configuration;
            obj.get_fmcw_configuration;
        end
        
        % BW_PER_SECOND
        function val = get.bandwidth_per_second(obj)
            val = obj.m_bandwidth_per_second;
        end
    end
end