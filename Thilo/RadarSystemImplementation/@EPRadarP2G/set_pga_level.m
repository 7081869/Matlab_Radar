function set_pga_level(obj, pga_level)
cmd_message = uint8(zeros(1,2));

cmd_message = protocol_write_payload_uint8(cmd_message, 0, obj.MSG_SET_PGA_LEVEL);
cmd_message = protocol_write_payload_uint16(cmd_message, 1, pga_level);

obj.doTransmission(cmd_message);
