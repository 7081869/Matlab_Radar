function parseMSG_SET_CHRIP_DURATION(obj, payload)

if (length(payload) == 5)
    obj.m_chirp_duration_ns = protocol_read_payload_uint32(payload, 1);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
