classdef EPRadarP2G < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPRadarP2G(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj)
            obj.get_pga_level;
        end

        parsePayload(obj, RX_content)
        doTransmission(obj, message)
    end

    methods (Hidden) % communication with endpoint
        set_pga_level(obj, pga_level)
        pga_level_val = get_pga_level(obj)
    end

    methods (Hidden) % parsing of incoming messages
        parseMSG_SET_PGA_LEVEL(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RP2G'; % ep_radar_p2g_definition    0x52503247
    end

    properties (Hidden) % general class
        uEndpointID;
        oRS;
    end

    properties (Hidden) % data properties
        % SET_PGA_LEVEL
        m_pga_level_val;
    end
    
    properties (Dependent)
        % SET_PGA_LEVEL
        pga_level_val;
	end

    properties (Access = private, Constant)	% message ids
        MSG_GET_PGA_LEVEL 		= uint8(hex2dec('00')); % A message to query current PGA gain level.
        MSG_SET_PGA_LEVEL       = uint8(hex2dec('01')); % A message containing PGA gain level.
    end
    
    %% set/get methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % set/get
        function val = get.pga_level_val(obj)
            val = obj.m_pga_level_val;
        end
        function set.pga_level_val(obj, val)
            obj.set_pga_level(val);
            obj.get_pga_level;
        end
        
    end
    
end
