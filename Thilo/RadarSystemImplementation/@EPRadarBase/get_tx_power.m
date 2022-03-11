function get_tx_power(obj,tx_antenna)

cmd_message = uint8(zeros(1,2));

cmd_message = protocol_write_payload_uint8(cmd_message, 0, obj.MSG_GET_TX_POWER);
cmd_message = protocol_write_payload_uint8(cmd_message, 1, tx_antenna);

obj.doTransmission(cmd_message);
