function parseMSG_SET_TX_POWER(obj, payload)

if (length(payload) == 6)
    obj.m_tx_antenna      = protocol_read_payload_uint8(payload, 1);
    obj.m_tx_power_001dBm = protocol_read_payload_int32(payload, 2);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
