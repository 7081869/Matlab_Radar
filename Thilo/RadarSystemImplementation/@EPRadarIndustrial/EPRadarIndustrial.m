classdef EPRadarIndustrial < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarIndustrial(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj)
            obj.bgt_lna_is_enable;
            obj.duty_cycle_is_enable;
        end

        parsePayload(obj, RX_content)
        doTransmission(obj, message)
    end

    methods (Hidden) % communication with endpoint
        duty_cycle_is_enable(obj)
        duty_cycle_enable(obj)
        duty_cycle_disable(obj)
        bgt_lna_is_enable(obj)
        bgt_lna_enable(obj)
        bgt_lna_disable(obj)
    end

    methods (Hidden) % parsing of incoming messages
        parseMSG_IS_ENABLE_DUTY_CYCLE(obj, payload)
        parseMSG_IS_ENABLE_BGT_LNA(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RIND'; % ep_radar_industrial_definition    0x52494E54
    end

    properties (Hidden) % general class
        uEndpointID;
        oRS;
    end

    properties (Hidden) % data properties
        % IS_ENABLE_DUTY_CYCLE
        m_duty_cycle_is_enabled;

        % IS_ENABLE_BGT_LNA
        m_bgt_lna_is_enabled;
    end

    properties (Dependent)
        % IS_ENABLE_DUTY_CYCLE
        duty_cycle_is_enabled;

        % IS_ENABLE_BGT_LNA
        bgt_lna_is_enabled;
    end

    properties (Access = private, Constant)	% message ids
        MSG_DISABLE_DUTY_CYCLE 		= uint8(hex2dec('00')); % A message to disable duty cycle.
        MSG_ENABLE_DUTY_CYCLE		= uint8(hex2dec('01')); % A message to enable duty cycle.
        MSG_IS_ENABLE_DUTY_CYCLE	= uint8(hex2dec('02')); % A message to check the status of duty cycle.
        MSG_DISABLE_BGT_LNA 		= uint8(hex2dec('03')); % A message to disable BGT Rx LNA gain.
        MSG_ENABLE_BGT_LNA			= uint8(hex2dec('04')); % A message to enable BGT Rx LNA gain.
        MSG_IS_ENABLE_BGT_LNA		= uint8(hex2dec('05')); % A message to check the status of BGT Rx LNA gain.
    end
    
    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        function val = get.bgt_lna_is_enabled(obj)
            val = obj.m_bgt_lna_is_enabled;
        end
        function set.bgt_lna_is_enabled(obj, val)
            if val
                obj.bgt_lna_enable;
            else
                obj.bgt_lna_disable;
            end
            obj.bgt_lna_is_enable;
        end
        
        function val = get.duty_cycle_is_enabled(obj)
            val = obj.m_duty_cycle_is_enabled;
        end
        function set.duty_cycle_is_enabled(obj, val)
            if val
                obj.duty_cycle_enable;
            else
                obj.duty_cycle_disable;
            end
            obj.duty_cycle_is_enable;
        end
        
    end
    
end
