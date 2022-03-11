classdef EPTargetDetection < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPTargetDetection(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj)
            obj.get_dsp_settings
        end

        parsePayload(obj, RX_content)
        doTransmission(obj, message)        
    end

    methods % communication with endpoint
        targets = get_targets(obj)
    end
    
    methods (Hidden) % communication with endpoint
        set_dsp_settings(obj)
        get_dsp_settings(obj)
        end
        

    methods (Hidden) % parsing of incoming messages
        parseMSG_GET_TARGETS(obj, payload)
        parseMSG_GET_DSP_SETTINGS(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RTDC'; % ep_targetdetect_definition    0x52544443
    end

    properties (Hidden) % general class
        uEndpointID
        oRS
    end

    properties (Hidden) % data properties
        % TARGETS
        m_targets
        
        % DSP_SETTINGS
        m_range_mvg_avg_length
        
        m_min_range_cm %
        m_max_range_cm
        m_min_speed_kmh
        m_max_speed_kmh
        m_min_angle_degree
        m_max_angle_degree
        m_range_threshold
        m_speed_threshold
        
        m_enable_tracking
        m_num_of_tracks
        
        m_median_filter_length
        m_enable_mti_filter
        
        m_mti_filter_length
        
    end

    properties (Dependent)
        % DSP_SETTINGS
        range_mvg_avg_length
        
        min_range_cm
        max_range_cm
        min_speed_kmh
        max_speed_kmh
        min_angle_degree
        max_angle_degree
        range_threshold
        speed_threshold
        
        enable_tracking
        num_of_tracks
        
        median_filter_length
        enable_mti_filter
        
        mti_filter_length
    end

    properties (Access = private, Constant)	% message ids
        MSG_GET_DSP_SETTINGS    = uint8(hex2dec('00')) % A message to retrieve dsp settings
        MSG_SET_DSP_SETTINGS    = uint8(hex2dec('01')) % A message to set dsp settings
        MSG_GET_TARGETS         = uint8(hex2dec('02')) % A message to get targets
    end

    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        % DSP_SETTINGS
        function val = get.range_mvg_avg_length(obj)
            val = obj.m_range_mvg_avg_length;
        end
        function set.range_mvg_avg_length(obj, val)
            obj.m_range_mvg_avg_length = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end

        function val = get.min_range_cm(obj)
            val = obj.m_min_range_cm;
        end
        function set.min_range_cm(obj, val)
            obj.m_min_range_cm = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end

        function val = get.max_range_cm(obj)
            val = obj.m_max_range_cm;
        end
        function set.max_range_cm(obj, val)
            obj.m_max_range_cm = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.min_speed_kmh(obj)
            val = obj.m_min_speed_kmh;
        end
        function set.min_speed_kmh(obj, val)
            obj.m_min_speed_kmh = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.max_speed_kmh(obj)
            val = obj.m_max_speed_kmh;
        end
        function set.max_speed_kmh(obj, val)
            obj.m_max_speed_kmh = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.min_angle_degree(obj)
            val = obj.m_min_angle_degree;
        end
        function set.min_angle_degree(obj, val)
            obj.m_min_angle_degree = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.max_angle_degree(obj)
            val = obj.m_max_angle_degree;
        end
        function set.max_angle_degree(obj, val)
            obj.m_max_angle_degree = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.range_threshold(obj)
            val = obj.m_range_threshold;
        end
        function set.range_threshold(obj, val)
            obj.m_range_threshold = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.speed_threshold(obj)
            val = obj.m_speed_threshold;
        end
        function set.speed_threshold(obj, val)
            obj.m_speed_threshold = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
                       
        function val = get.enable_tracking(obj)
            val = obj.m_enable_tracking;
        end
        function set.enable_tracking(obj, val)
            obj.m_enable_tracking = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.num_of_tracks(obj)
            val = obj.m_num_of_tracks;
        end
        function set.num_of_tracks(obj, val)
            obj.m_num_of_tracks = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.median_filter_length(obj)
            val = obj.m_median_filter_length;
        end
        function set.median_filter_length(obj, val)
            obj.m_median_filter_length = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.enable_mti_filter(obj)
            val = obj.m_enable_mti_filter;
        end
        function set.enable_mti_filter(obj, val)
            obj.m_enable_mti_filter = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end
        
        function val = get.mti_filter_length(obj)
            val = obj.m_mti_filter_length;
        end
        function set.mti_filter_length(obj, val)
            obj.m_mti_filter_length = val;
            obj.set_dsp_settings;
            obj.get_dsp_settings;
        end

    end

end