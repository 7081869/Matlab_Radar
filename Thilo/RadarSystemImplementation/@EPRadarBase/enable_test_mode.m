function enable_test_mode(obj, tx_mask, rx_mask, frequency_kHz, tx_power)

cmd_message = uint8(zeros(1,8));
cmd_message = protocol_write_payload_uint8 (cmd_message, 0, obj.MSG_ENABLE_TEST_MODE);
cmd_message = protocol_write_payload_uint8 (cmd_message, 1, tx_mask);
cmd_message = protocol_write_payload_uint8 (cmd_message, 2, rx_mask);
cmd_message = protocol_write_payload_uint32(cmd_message, 3, frequency_kHz);
cmd_message = protocol_write_payload_uint8 (cmd_message, 7, tx_power);

obj.doTransmission(cmd_message);
