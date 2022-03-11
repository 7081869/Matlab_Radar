classdef EPRadarADCXMC < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarADCXMC(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj)
            obj.get_adc_configuration
        end
        
        parsePayload(obj, RX_content)
        doTransmission(obj, message)        
    end

    methods (Hidden) % communication with endpoint
        set_adc_configuration(obj)
        get_adc_configuration(obj)
    end

    methods (Hidden) % parsing of incoming messages
        parseMSG_SET_CONFIGURATION(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RADX'; % ep_radar_adcxmc_definition    0x52414458
    end

    properties (Hidden) % general class
        uEndpointID
        oRS
    end

    properties (Hidden) % data properties
        % SET_CONFIGURATION
        m_samplerate_Hz
        m_resolution
        m_use_post_calibration
    end

    properties (Dependent)
        % SET_CONFIGURATION
        samplerate_Hz % The sampling rate at with the IF signals are captured. The value is specified in Hz.  This value affects the chirp duration.
        resolution % The number of bits for each signal sample. The value may affect the highest possible sampling rate.
        use_post_calibration % If this is non-zero the post calibration of the ADC is used.
    end

    properties (Access = private, Constant)	% message ids
        MSG_GET_CONFIGURATION     = uint8(hex2dec('00')) % A message to query the ADC configuration.
        MSG_SET_CONFIGURATION     = uint8(hex2dec('01')) % A message containing the ADC configuration.
    end

    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        % SET_CONFIGURATION
        function val = get.samplerate_Hz(obj)
            val = obj.m_samplerate_Hz;
        end
        function set.samplerate_Hz(obj, val)
            obj.m_samplerate_Hz = val;
            obj.set_adc_configuration;
            obj.get_adc_configuration;
        end

        function val = get.resolution(obj)
            val = obj.m_resolution;
        end
        function set.resolution(obj, val)
            obj.m_resolution = val;
            obj.set_adc_configuration;
            obj.get_adc_configuration;
        end
        
        function val = get.use_post_calibration(obj)
            val = obj.m_use_post_calibration;
        end
        function set.use_post_calibration(obj, val)
            obj.m_use_post_calibration = val;
            obj.set_adc_configuration;
            obj.get_adc_configuration;
        end
    end

end