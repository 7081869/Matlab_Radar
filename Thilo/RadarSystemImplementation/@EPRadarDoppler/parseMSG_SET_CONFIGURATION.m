function parseMSG_SET_CONFIGURATION(obj, payload)

if (length(payload) == 6)
    % extract parameters from message
    obj.m_frequency_kHz = protocol_read_payload_uint32(payload, 1);
    obj.m_tx_power = protocol_read_payload_uint8 (payload, 5);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
