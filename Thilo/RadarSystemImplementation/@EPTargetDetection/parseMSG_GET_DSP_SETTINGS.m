function parseMSG_GET_DSP_SETTINGS(obj, payload)

if (length(payload) >= 18)
    % extract parameters from message
    obj.m_range_mvg_avg_length = protocol_read_payload_uint8(payload, 1);

    obj.m_min_range_cm = protocol_read_payload_uint16(payload, 2);
    obj.m_max_range_cm = protocol_read_payload_uint16(payload, 4);

    obj.m_min_speed_kmh = protocol_read_payload_uint16(payload, 6);
    obj.m_max_speed_kmh = protocol_read_payload_uint16(payload, 8);

    obj.m_min_angle_degree = protocol_read_payload_uint16(payload, 10);
    obj.m_max_angle_degree = protocol_read_payload_uint16(payload, 12);

    obj.m_range_threshold = protocol_read_payload_uint16(payload, 14);
    obj.m_speed_threshold = protocol_read_payload_uint16(payload, 16);

	% skip uint16 entry for index 18
    obj.m_enable_tracking = protocol_read_payload_uint8(payload, 20);
    obj.m_num_of_tracks = protocol_read_payload_uint8(payload, 21);

    obj.m_median_filter_length = protocol_read_payload_uint8(payload, 22);
    obj.m_enable_mti_filter = protocol_read_payload_uint8(payload, 23);

    obj.m_mti_filter_length = protocol_read_payload_uint16(payload, 24);
    % skip uint8 entry for index 26
	
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
