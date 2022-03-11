function parseMSG_SEND_x_CALIBRATION(obj, payload)

if (length(payload) >= 2)
    % extract parameters from message
    num_of_bytes = protocol_read_payload_uint16(payload, 1); % remaining bytes
    total_samples = num_of_bytes/2; % uint16 words packed in byte-stream

    sample_bit_mask = bitshift(uint16(1), 12) - 1; % 12 bits, all set to one packed in uint16
    norm_factor = 1/double(sample_bit_mask); % normalize to max ^= 1

    sample_data = [];
    read_idx = 3;
    if (length(payload) == read_idx + total_samples * 2)
        sample_data = zeros(total_samples,1);
        for n=1:total_samples
            current_sample = protocol_read_payload_uint16(payload, read_idx);
            sample_data(n) = double(bitand(current_sample, sample_bit_mask)) * norm_factor;
            read_idx = read_idx + 2;
        end
    end
    
    obj.m_sample_data = sample_data; % total_samples not needed here, as it is implicitly contained in length(m_sample_data)
else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
