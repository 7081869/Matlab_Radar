function set_doppler_configuration(obj)

cmd_message = uint8(zeros(1,6));

    cmd_message = protocol_write_payload_uint8 (cmd_message, 0, obj.MSG_SET_CONFIGURATION);
    cmd_message = protocol_write_payload_uint32(cmd_message, 1, obj.m_frequency_kHz);
    cmd_message = protocol_write_payload_uint8 (cmd_message, 5, obj.m_tx_power);

obj.doTransmission(cmd_message);
