function parseMSG_SET_CONFIGURATION(obj, payload)

if (length(payload) == 11)
    obj.m_lower_frequency_kHz = protocol_read_payload_uint32(payload,  1);
    obj.m_upper_frequency_kHz = protocol_read_payload_uint32(payload,  5);
    obj.m_direction = protocol_read_payload_uint8(payload,  9);
    obj.m_tx_power = protocol_read_payload_uint8(payload, 10);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
