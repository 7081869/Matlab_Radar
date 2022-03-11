function parseMSG_SET_PGA_LEVEL(obj, payload)

if (length(payload) == 3)
    % extract parameters from message
    obj.m_pga_level_val = protocol_read_payload_uint16(payload, 1);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
