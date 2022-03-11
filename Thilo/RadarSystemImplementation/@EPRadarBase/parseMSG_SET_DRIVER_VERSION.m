function parseMSG_SET_DRIVER_VERSION(obj, payload)

if (length(payload) == 4)
    obj.m_major    = protocol_read_payload_uint8(payload, 1);
    obj.m_minor    = protocol_read_payload_uint8(payload, 2);
    obj.m_revision = protocol_read_payload_uint8(payload, 3);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
