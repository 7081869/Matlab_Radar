classdef EPRadarBase < handle
    
    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarBase(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end
        
        function initValues(obj)
            obj.get_driver_version;
            obj.get_device_info;
            obj.get_frame_format;
            obj.get_chirp_duration;
            obj.get_min_frame_interval;
        end
        
        parsePayload(obj, RX_content)
        doTransmission(obj, message)
    end
    
    methods % communication with endpoint
        [mxData, sInfo] = get_frame_data(obj, wait)
        set_automatic_frame_trigger(obj, frame_interval_us)
        stop_automatic_frame_trigger(obj)
        enable_test_mode(obj, tx_mask, rx_mask, frequency_kHz, tx_power)
        disable_test_mode(obj)
    end
    
    methods (Hidden) % communication with endpoint
        get_driver_version(obj)
        get_device_info(obj)
        set_frame_format(obj)
        get_frame_format(obj)
        get_temperature(obj, temp_sensor)
        get_tx_power(obj, tx_antenna)
        get_chirp_duration(obj)
        get_min_frame_interval(obj)
    end
    
    methods (Hidden) % parsing of incoming messages
        parseMSG_FRAME_DATA(obj, payload)
        parseMSG_SET_TEMPRATURE(obj, payload)
        parseMSG_SET_TX_POWER(obj, payload)
        parseMSG_SET_CHRIP_DURATION(obj, payload)
        parseMSG_SET_MIN_INTERVAL(obj, payload)
        parseMSG_SET_FRAME_FORMAT(obj, payload)
        parseMSG_SET_DEVICE_INFO(obj, payload)
        parseMSG_SET_DRIVER_VERSION(obj, payload)
    end
    
    %% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RBAS'; % ep_radar_base_definition, 0x52424153
    end
    
    properties (Hidden) % general class
        uEndpointID
        oRS
    end
    
    properties (Hidden) % data properties
        % FRAME_DATA
        m_frame_info
        
        % TEMPRATURE
        m_temp_sensor
        m_temperature_001C
        
        % TX_POWER
        m_tx_antenna
        m_tx_power_001dBm
        
        % CHIRP_DURATION
        m_chirp_duration_ns
        
        % MIN_INTERVAL
        m_min_frame_interval_us
        
        % FRAME_FORMAT
        m_num_samples_per_chirp
        m_num_chirps_per_frame
        m_rx_mask
        m_signal_part
        
        % DEVICE_INFO
        m_min_rf_frequency_kHz
        m_max_rf_frequency_kHz
        m_num_tx_antennas
        m_num_rx_antennas
        m_max_tx_power
        m_num_temp_sensors
        m_major_version_hw
        m_minor_version_hw
        m_interleaved_rx
        m_data_format
        m_description
        
        % DRIVER_VERSION
        m_major
        m_minor
        m_revision
    end
    
    properties (Dependent, SetAccess = private)
        % TEMPRATURE
        temperature_001C
        
        % TX_POWER
        tx_power_001dBm
        
        % CHIRP_DURATION
        chirp_duration_ns
        
        % MIN_INTERVAL
        min_frame_interval_us        
    end
    
    properties (Dependent)
        % FRAME_FORMAT
        num_samples_per_chirp
        num_chirps_per_frame
        rx_mask
        % signal_part % ToDo: is this necessary on user level?
    end
    
    properties (Dependent, SetAccess = private)
        % DEVICE_INFO
        min_rf_frequency_kHz
        max_rf_frequency_kHz
        num_tx_antennas
        num_rx_antennas
        max_tx_power
        num_temp_sensors
        % interleaved_rx % ToDo: is this necessary on user level?
        data_format
        description
        hw_version
        
        % DRIVER_VERSION
        driver_version
    end
    
    properties (Access = private, Constant)	% message ids
        MSG_FRAME_DATA            = uint8(hex2dec('00')); % A message containing radar frame data.
        MSG_GET_FRAME_DATA        = uint8(hex2dec('01')); % A message to retrieve frame data.
        MSG_SET_AUTOMATIC_TRIGGER = uint8(hex2dec('02')); % A message to configure the automatic frame trigger.
        MSG_ENABLE_TEST_MODE      = uint8(hex2dec('03')); % A message to configure antenna test mode.
        MSG_GET_DRIVER_VERSION    = uint8(hex2dec('20')); % A message to query device information.
        MSG_SET_DRIVER_VERSION    = uint8(hex2dec('21')); % A message containing device information.
        MSG_GET_DEVICE_INFO       = uint8(hex2dec('22')); % A message to query device information.
        MSG_SET_DEVICE_INFO       = uint8(hex2dec('23')); % A message containing device information.
        MSG_GET_TEMPRATURE        = uint8(hex2dec('30')); % A message to query a measured temperature value.
        MSG_SET_TEMPRATURE        = uint8(hex2dec('31')); % A message containing a measured temperature value.
        MSG_GET_TX_POWER          = uint8(hex2dec('32')); % A message to query a measured TX power value.
        MSG_SET_TX_POWER          = uint8(hex2dec('33')); % A message containing a measured TX power value.
        MSG_GET_CHRIP_DURATION    = uint8(hex2dec('34')); % A message to query the current chirp duration.
        MSG_SET_CHRIP_DURATION    = uint8(hex2dec('35')); % A message containing the current chirp duration.
        MSG_GET_MIN_INTERVAL      = uint8(hex2dec('36')); % A message to query the minimum frame interval.
        MSG_SET_MIN_INTERVAL      = uint8(hex2dec('37')); % A message containing the minimum frame interval.
        MSG_GET_FRAME_FORMAT      = uint8(hex2dec('40')); % A message to query the frame format.
        MSG_SET_FRAME_FORMAT      = uint8(hex2dec('41')); % A message containing frame format parameters.
    end
    
    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        % TEMPRATURE
        function val = get.temperature_001C(obj)
            val = zeros(1,obj.m_num_temp_sensors);
            for n=1:length(val)
                obj.get_temperature(n-1);
                val(obj.m_temp_sensor+1) = obj.m_temperature_001C;
            end
        end
        
        % TX_POWER
        function val = get.tx_power_001dBm(obj)
            val = zeros(1,obj.m_num_tx_antennas);
            for n=1:length(val)
                obj.get_tx_power(n-1);
                val(obj.m_tx_antenna+1) = obj.m_tx_power_001dBm;
            end
        end
        
        % CHIRP_DURATION
        function val = get.chirp_duration_ns(obj)
            val = obj.m_chirp_duration_ns;
        end
        
        % MIN_INTERVAL
        function val = get.min_frame_interval_us(obj)
            val = obj.m_min_frame_interval_us;
        end
        
        % FRAME_FORMAT
        function val = get.num_samples_per_chirp(obj)
            val = obj.m_num_samples_per_chirp;
        end
        function set.num_samples_per_chirp(obj, val)
            obj.m_num_samples_per_chirp = val;
            obj.set_frame_format;
            obj.get_frame_format;
        end
        
        function val = get.num_chirps_per_frame(obj)
            val = obj.m_num_chirps_per_frame;
        end
        function set.num_chirps_per_frame(obj, val)
            obj.m_num_chirps_per_frame = val;
            obj.set_frame_format;
            obj.get_frame_format;
        end
        
        function val = get.rx_mask(obj)
            val = obj.m_rx_mask;
        end
        function set.rx_mask(obj, val)
            obj.m_rx_mask = val;
            obj.set_frame_format;
            obj.get_frame_format;
        end
        
        % DEVICE_INFO
        function val = get.min_rf_frequency_kHz(obj)
            val = obj.m_min_rf_frequency_kHz;
        end
        
        function val = get.max_rf_frequency_kHz(obj)
            val = obj.m_max_rf_frequency_kHz;
        end
        
        function val = get.num_tx_antennas(obj)
            val = obj.m_num_tx_antennas;
        end
        
        function val = get.num_rx_antennas(obj)
            val = obj.m_num_rx_antennas;
        end
        
        function val = get.max_tx_power(obj)
            val = obj.m_max_tx_power;
        end
        
        function val = get.num_temp_sensors(obj)
            val = obj.m_num_temp_sensors;
        end
        
        function val = get.data_format(obj)
            switch obj.m_data_format
                case 0 % EP_RADAR_BASE_RX_DATA_REAL The frame data contains only I or Q signal.
                    val = 'Real Data';
                case 1 % EP_RADAR_BASE_RX_DATA_COMPLEX The frame data contains I and Q signals in separate data blocks.
                    val = 'Complex Data';
                case 2 % EP_RADAR_BASE_RX_DATA_COMPLEX_INTERLEAVED The frame data contains I and Q signals in one interleaved data block.
                    val = 'Complex Interleaved Data';
            end
        end
        
        function val = get.description(obj)
            val = obj.m_description;
        end
        
        function val = get.hw_version(obj)
            val = [obj.m_major_version_hw obj.m_minor_version_hw];
        end
        
        % DRIVER_VERSION
        function val = get.driver_version(obj)
            val = [obj.m_major obj.m_minor obj.m_revision];
        end
        
    end
    
end
