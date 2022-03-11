function set_frame_format(obj)

cmd_message = uint8(zeros(1,11));
cmd_message = protocol_write_payload_uint8 (cmd_message,  0, obj.MSG_SET_FRAME_FORMAT);
cmd_message = protocol_write_payload_uint32(cmd_message,  1, obj.m_num_samples_per_chirp);
cmd_message = protocol_write_payload_uint32(cmd_message,  5, obj.m_num_chirps_per_frame);
cmd_message = protocol_write_payload_uint8 (cmd_message,  9, obj.m_rx_mask);
cmd_message = protocol_write_payload_uint8 (cmd_message, 10, obj.m_signal_part);

obj.doTransmission(cmd_message);
