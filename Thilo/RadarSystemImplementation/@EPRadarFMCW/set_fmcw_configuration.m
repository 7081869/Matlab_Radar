function set_fmcw_configuration(obj)

cmd_message = uint8(zeros(1,11));
cmd_message = protocol_write_payload_uint8 (cmd_message,  0, obj.MSG_SET_CONFIGURATION);
cmd_message = protocol_write_payload_uint32(cmd_message,  1, obj.m_lower_frequency_kHz);
cmd_message = protocol_write_payload_uint32(cmd_message,  5, obj.m_upper_frequency_kHz);
cmd_message = protocol_write_payload_uint8 (cmd_message,  9, obj.m_direction);
cmd_message = protocol_write_payload_uint8 (cmd_message, 10, obj.m_tx_power);

obj.doTransmission(cmd_message);
