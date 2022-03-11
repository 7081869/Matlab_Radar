function parseMSG_SET_TEMPRATURE(obj, payload)

if (length(payload) == 6)
    obj.m_temp_sensor      = protocol_read_payload_uint8(payload, 1);
    obj.m_temperature_001C = protocol_read_payload_int32(payload, 2);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
