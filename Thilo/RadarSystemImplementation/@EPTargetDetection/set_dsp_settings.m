function set_dsp_settings(obj)

cmd_message = uint8(zeros(1,27));

cmd_message = protocol_write_payload_uint8 (cmd_message,  0, obj.MSG_SET_DSP_SETTINGS); 
cmd_message = protocol_write_payload_uint8 (cmd_message,  1, obj.m_range_mvg_avg_length);
		
cmd_message = protocol_write_payload_uint16(cmd_message,  2, obj.m_min_range_cm);
cmd_message = protocol_write_payload_uint16(cmd_message,  4, obj.m_max_range_cm);
cmd_message = protocol_write_payload_uint16(cmd_message,  6, obj.m_min_speed_kmh);
cmd_message = protocol_write_payload_uint16(cmd_message,  8, obj.m_max_speed_kmh);
cmd_message = protocol_write_payload_uint16(cmd_message, 10, obj.m_min_angle_degree);
cmd_message = protocol_write_payload_uint16(cmd_message, 12, obj.m_max_angle_degree);
cmd_message = protocol_write_payload_uint16(cmd_message, 14, obj.m_range_threshold);
cmd_message = protocol_write_payload_uint16(cmd_message, 16, obj.m_speed_threshold);

cmd_message = protocol_write_payload_uint16(cmd_message, 18, 0);
cmd_message = protocol_write_payload_uint8 (cmd_message, 20, obj.m_enable_tracking);
cmd_message = protocol_write_payload_uint8 (cmd_message, 21, obj.m_num_of_tracks);

cmd_message = protocol_write_payload_uint8 (cmd_message, 22, obj.m_median_filter_length);
cmd_message = protocol_write_payload_uint8 (cmd_message, 23, obj.m_enable_mti_filter);

cmd_message = protocol_write_payload_uint16(cmd_message, 24, obj.m_mti_filter_length);
cmd_message = protocol_write_payload_uint16(cmd_message, 26, 0);

obj.doTransmission(cmd_message);
