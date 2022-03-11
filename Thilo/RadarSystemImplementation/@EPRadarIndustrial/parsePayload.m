function parsePayload(obj, RX_content)

switch RX_content(1) % command code
    case obj.MSG_IS_ENABLE_DUTY_CYCLE
        obj.parseMSG_IS_ENABLE_DUTY_CYCLE(RX_content)
    case obj.MSG_IS_ENABLE_BGT_LNA
        obj.parseMSG_IS_ENABLE_BGT_LNA(RX_content)
    otherwise
        fprintf('[%s.%s] Error! Unknown Command Code: 0x%s\n',mfilename('Class'),mfilename,dec2hex(RX_content(1)));
end
