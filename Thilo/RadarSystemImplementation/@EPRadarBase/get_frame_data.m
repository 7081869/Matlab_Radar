function [mxData, sInfo] = get_frame_data(obj, wait)

if nargin<2
    wait = uint8(1); % this is a boolean parameter 'waitForData'
end

cmd_message = uint8(zeros(1,2));
cmd_message = protocol_write_payload_uint8(cmd_message, 0, obj.MSG_GET_FRAME_DATA);
cmd_message = protocol_write_payload_uint8(cmd_message, 1, wait);

obj.doTransmission(cmd_message);

% output data and info
if ~isempty(obj.m_frame_info)
    mxData = obj.m_frame_info.sample_data; % ToDo: compatibility, col: RX-No, row: sample
    sInfo = rmfield(obj.m_frame_info,'sample_data');
    obj.m_frame_info = [];
else
    mxData = [];
    sInfo = [];
end