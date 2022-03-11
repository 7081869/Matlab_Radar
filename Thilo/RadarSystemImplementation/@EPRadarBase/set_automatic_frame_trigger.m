function set_automatic_frame_trigger(obj, frame_interval_us)

cmd_message = uint8(zeros(1,5));
cmd_message = protocol_write_payload_uint8(cmd_message, 0, obj.MSG_SET_AUTOMATIC_TRIGGER);
cmd_message = protocol_write_payload_uint32(cmd_message, 1, frame_interval_us);

obj.doTransmission(cmd_message);
