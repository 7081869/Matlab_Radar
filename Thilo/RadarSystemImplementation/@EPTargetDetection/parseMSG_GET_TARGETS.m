function parseMSG_GET_TARGETS(obj, payload)

if ( (protocol_read_payload_uint8(payload, 0) == 2) && length(payload) >= 2)  
    % extract parameters from message

    num_targets = protocol_read_payload_uint8(payload, 1);
    
     if (num_targets > 0)
    target_data_size = 32; % sizeof(float) * 7 + sizeof(uint32_t);

    if (length(payload)  == num_targets * target_data_size + 2)
          obj.m_targets = struct('target_id', [], 'level', [], 'radius', [], 'azimuth', [], 'elevation', [], 'radial_speed', [], 'azimuth_speed', [], 'elevation_speed', []);
          
        for i = 0:num_targets-1
            obj.m_targets(i+1).target_id =          protocol_read_payload_uint8(payload, i*target_data_size+2);       % An unique ID of that target.
            obj.m_targets(i+1).level =              protocol_read_payload_float(payload, i*target_data_size+2+4);    % The Level at the peak in dB relative to threshold.
            obj.m_targets(i+1).radius =             protocol_read_payload_float(payload, i*target_data_size+2+8);     % The Distance of the target from the sensor.
            obj.m_targets(i+1).azimuth =            protocol_read_payload_float(payload, i*target_data_size+2+12);    % The azimuth angle of the target. Positive values in right direction from the sensing board perspective.
            obj.m_targets(i+1).elevation =          protocol_read_payload_float(payload, i*target_data_size+2+16);    % The elevation angle of the target. Positive values in up direction from the sensing board perspective.
            obj.m_targets(i+1).radial_speed =       protocol_read_payload_float(payload, i*target_data_size+2+20);    % The change of radius per second.
            obj.m_targets(i+1).azimuth_speed =      protocol_read_payload_float(payload, i*target_data_size+2+24);    % The change of azimuth angle per second.
            obj.m_targets(i+1).elevation_speed =    protocol_read_payload_float(payload, i*target_data_size+2+28);    % The change of elevation angle per second.                    
        end
    end
    else
        obj.m_targets = struct('target_id', 'N/A', 'level', 'N/A', 'radius', 'N/A', 'azimuth', 'N/A', 'elevation', 'N/A', 'radial_speed', 'N/A', 'azimuth_speed', 'N/A', 'elevation_speed', 'N/A');
    end 

else
    fprintf('[%s.%s] Error! Wrong payload size.\n',mfilename('Class'),mfilename);
end
