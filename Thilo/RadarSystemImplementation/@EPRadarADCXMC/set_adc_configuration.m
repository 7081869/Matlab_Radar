function set_adc_configuration(obj)

cmd_message = uint8(zeros(1,7));

cmd_message = protocol_write_payload_uint8 (cmd_message, 0, obj.MSG_SET_CONFIGURATION);
cmd_message = protocol_write_payload_uint32(cmd_message, 1, obj.m_samplerate_Hz);
cmd_message = protocol_write_payload_uint8 (cmd_message, 5, obj.m_resolution);
cmd_message = protocol_write_payload_uint8 (cmd_message, 6, obj.m_use_post_calibration);

obj.doTransmission(cmd_message);
