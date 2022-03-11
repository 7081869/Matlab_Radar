function parseMSG_SET_BW_PER_SECOND(obj, payload)

if (length(payload) == 5)
    obj.m_bandwidth_per_second = protocol_read_payload_uint32(payload, 1);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
