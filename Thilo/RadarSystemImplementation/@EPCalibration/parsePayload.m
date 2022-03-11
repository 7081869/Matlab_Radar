function parsePayload(obj, RX_content)

switch RX_content(1) % command code
    case {obj.MSG_SEND_FLASH_CALIBRATION, obj.MSG_SEND_SRAM_CALIBRATION}
        obj.parseMSG_SEND_x_CALIBRATION(RX_content)
    otherwise
        fprintf('[%s.%s] Error! Unknown Command Code: 0x%s\n',mfilename('Class'),mfilename,dec2hex(RX_content(1)));
end
