function get_temperature(obj,temp_sensor)

cmd_message = uint8(zeros(1,2));
cmd_message = protocol_write_payload_uint8(cmd_message, 0, obj.MSG_GET_TEMPRATURE);
cmd_message = protocol_write_payload_uint8(cmd_message, 1, temp_sensor);

obj.doTransmission(cmd_message);
