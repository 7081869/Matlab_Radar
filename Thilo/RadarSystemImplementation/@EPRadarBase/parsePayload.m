function parsePayload(obj, RX_content)

switch RX_content(1) % command code
    case obj.MSG_FRAME_DATA
        obj.parseMSG_FRAME_DATA(RX_content);
    case obj.MSG_SET_TEMPRATURE
        obj.parseMSG_SET_TEMPRATURE(RX_content);
    case obj.MSG_SET_TX_POWER
        obj.parseMSG_SET_TX_POWER(RX_content);
    case obj.MSG_SET_CHRIP_DURATION
        obj.parseMSG_SET_CHRIP_DURATION(RX_content);
    case obj.MSG_SET_MIN_INTERVAL
        obj.parseMSG_SET_MIN_INTERVAL(RX_content);
    case obj.MSG_SET_FRAME_FORMAT
        obj.parseMSG_SET_FRAME_FORMAT(RX_content);
    case obj.MSG_SET_DEVICE_INFO
        obj.parseMSG_SET_DEVICE_INFO(RX_content);
    case obj.MSG_SET_DRIVER_VERSION
        obj.parseMSG_SET_DRIVER_VERSION(RX_content);
    otherwise
        fprintf('[%s.%s] Error! Unknown Command Code: 0x%s\n',mfilename('Class'),mfilename,dec2hex(RX_content(1)));
end
