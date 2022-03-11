classdef EPRadarDoppler < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarDoppler(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj)
            obj.get_doppler_configuration
        end

        parsePayload(obj, RX_content)
        doTransmission(obj, message)
    end

    methods (Hidden) % communication with endpoint
        set_doppler_configuration(obj)
        get_doppler_configuration(obj)
    end

    methods (Hidden) % parsing of incoming messages
        parseMSG_SET_CONFIGURATION(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RDPL'; % ep_radar_doppler_definition    0x5244504C
    end

    properties (Hidden) % general class
        uEndpointID
        oRS
    end

    properties (Hidden) % data properties
        % SET_CONFIGURATION
        m_frequency_kHz
        m_tx_power
    end

    properties (Dependent)
        % SET_CONFIGURATION
        frequency_kHz % The lower frequency of an FMCW chirp. The value is specified in kHz.
        tx_power % The transmission power the emitted FMCW chirps. The value is expected to be in the range of 0...max_tx_power (see alse Device_Info_t).
    end

    properties (Access = private, Constant)	% message ids
        MSG_GET_CONFIGURATION     = uint8(hex2dec('00')) % A message to query the Doppler radar configuration. */
        MSG_SET_CONFIGURATION     = uint8(hex2dec('01')) % A message containing the Doppler
    end

    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        % SET_CONFIGURATION
        function val = get.frequency_kHz(obj)
            val = obj.m_frequency_kHz;
        end
        function set.frequency_kHz(obj, val)
            obj.m_frequency_kHz = val;
            set_doppler_configuration(obj)
            get_doppler_configuration(obj)
        end

        function val = get.tx_power(obj)
            val = obj.m_tx_power;
        end
        function set.tx_power(obj, val)
            obj.m_tx_power = val;
            set_doppler_configuration(obj)
            get_doppler_configuration(obj)
        end
    end

end
