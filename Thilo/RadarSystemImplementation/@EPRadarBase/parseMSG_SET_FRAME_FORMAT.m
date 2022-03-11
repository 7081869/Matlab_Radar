function parseMSG_SET_FRAME_FORMAT(obj, payload)

if (length(payload) == 11)
    obj.m_num_samples_per_chirp = protocol_read_payload_uint32(payload,  1);
    obj.m_num_chirps_per_frame = protocol_read_payload_uint32(payload,  5);
    obj.m_rx_mask = protocol_read_payload_uint8 (payload,  9);
    obj.m_signal_part = protocol_read_payload_uint8 (payload, 10);
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
