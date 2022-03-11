function parseMSG_SET_CONFIGURATION(obj, payload)

if (length(payload) == 7)
    % extract parameters from message
    obj.m_samplerate_Hz = protocol_read_payload_uint32(payload, 1);
    obj.m_resolution  = protocol_read_payload_uint8 (payload, 5);
    obj.m_use_post_calibration = protocol_read_payload_uint8 (payload, 6);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
