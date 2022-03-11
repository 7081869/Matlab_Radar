function parseMSG_SET_DEVICE_INFO(obj, payload)

if (length(payload) >= 17)
            obj.m_min_rf_frequency_kHz = protocol_read_payload_uint32(payload, 1);
            obj.m_max_rf_frequency_kHz = protocol_read_payload_uint32(payload, 5);
            obj.m_num_tx_antennas = protocol_read_payload_uint8 (payload, 9);
            obj.m_num_rx_antennas = protocol_read_payload_uint8 (payload, 10);
            obj.m_max_tx_power = protocol_read_payload_uint8 (payload, 11);
            obj.m_num_temp_sensors = protocol_read_payload_uint8 (payload, 12);
            obj.m_major_version_hw = protocol_read_payload_uint8 (payload, 13);
            obj.m_minor_version_hw = protocol_read_payload_uint8 (payload, 14);
            obj.m_interleaved_rx = protocol_read_payload_uint8 (payload, 15);
            obj.m_data_format = protocol_read_payload_uint8 (payload, 16);
            obj.m_description = char(payload(18:end-1)); % zero terminated string --> omit last character (=zero)
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
