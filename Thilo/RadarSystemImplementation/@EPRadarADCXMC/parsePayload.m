function parsePayload(obj, RX_content)

switch RX_content(1) % command code
    case obj.MSG_SET_CONFIGURATION
        obj.parseMSG_SET_CONFIGURATION(RX_content);
    otherwise
        fprintf('[%s.%s] Error! Unknown Command Code: 0x%s\n',mfilename('Class'),mfilename,dec2hex(RX_content(1)));
end
