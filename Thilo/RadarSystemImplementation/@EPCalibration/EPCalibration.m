classdef EPCalibration < handle

    %% methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Hidden) % constructor, general class
        function obj = EPCalibration(oRS, uEndpointID)
            obj.uEndpointID = uEndpointID;
            obj.oRS = oRS;
        end

        function initValues(obj) %#ok<MANU>
            % empty by design
        end

        parsePayload(obj, RX_content)
        doTransmission(obj, message)
    end

    methods % communication with endpoint
        set_calibration_data(obj)
        set_sram_calibration_data(obj)
        clear_calibration_data(obj)
        clear_sram_calibration_data(obj)
        sample_data = get_calibration_data(obj)
        sample_data = get_sram_calibration_data(obj)
    end

    methods (Hidden) % parsing of incoming messages
        parseMSG_SEND_x_CALIBRATION(obj, payload)
    end

	%% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Hidden, Constant) % endpoint tag
        szEPTag = 'RCAL'; % definition    0x5243414c
    end

    properties (Hidden) % general class
        uEndpointID;
        oRS;
    end

    properties (Hidden) % data properties
        % CALIBRATION
        m_sample_data
    end

    properties (Access = private, Constant)	% message ids
        MSG_SAVE_FLASH_CALIBRATION     = uint8(hex2dec('01')); % A message to save calibration data from EEPROM */
        MSG_SEND_FLASH_CALIBRATION     = uint8(hex2dec('02')); % A message to read calibration data from EEPROM */
        MSG_CLEAR_FLASH_CALIBRATION    = uint8(hex2dec('03')); % A message to delete calibration data from EEPROM */
        MSG_SAVE_SRAM_CALIBRATION      = uint8(hex2dec('04')); % A message to save calibration data in SRAM */
        MSG_SEND_SRAM_CALIBRATION      = uint8(hex2dec('05')); % A message to read calibration data in SRAM */
        MSG_CLEAR_SRAM_CALIBRATION     = uint8(hex2dec('06')); % A message to delete calibration data from SRAM */
    end
    
end
