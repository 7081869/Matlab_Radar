function sample_data = get_calibration_data(obj)

obj.doTransmission(obj.MSG_SEND_FLASH_CALIBRATION);

sample_data = obj.m_sample_data;
