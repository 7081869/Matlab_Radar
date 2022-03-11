function parseMSG_IS_ENABLE_DUTY_CYCLE(obj, payload)

if (length(payload) == 2)
    % extract parameters from message
    obj.m_duty_cycle_is_enabled = protocol_read_payload_uint8(payload, 1);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
