function sample_data = get_sram_calibration_data(obj)

obj.doTransmission(obj.MSG_SEND_SRAM_CALIBRATION);

sample_data = obj.m_sample_data;
