function parsePayload(obj, RX_content)

switch RX_content(1) % command code
    case obj.MSG_GET_TARGETS
        obj.parseMSG_GET_TARGETS(RX_content);
    case obj.MSG_GET_DSP_SETTINGS
        obj.parseMSG_GET_DSP_SETTINGS(RX_content);
    case obj.MSG_GET_RANGE_THRESHOLD
        obj.parseMSG_GET_RANGE_THRESHOLD(RX_content);
    otherwise
        fprintf('[%s.%s] Error! Unknown Command Code: 0x%s\n',mfilename('Class'),mfilename,dec2hex(RX_content(1)));
end
