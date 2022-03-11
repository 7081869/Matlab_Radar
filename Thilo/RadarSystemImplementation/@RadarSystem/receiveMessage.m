function [RX_startbyte, RX_endpointID, RX_content] = receiveMessage(obj)

% receive start byte and endpoint data
RX_startbyte = fread(obj.hSerialPort, 1, 'uint8');
RX_endpointID = fread(obj.hSerialPort, 1, 'uint8');

if (RX_startbyte == obj.cStartbyteMessage)
    % receive payload size, payload and message end sequence
    RX_payloadSize	= fread(obj.hSerialPort, 1, 'uint16');
    RX_content = cast(fread(obj.hSerialPort, RX_payloadSize, 'uint8'),'uint8')';
    RX_payloadEODB = fread(obj.hSerialPort, 1, 'uint16');

    % check if message was received correctly
    if (RX_payloadEODB ~= obj.cEndOfMessage)
        disp('[RadarSystem.receiveMessage] Error: Bad message end sequence received')
    end
        
elseif (RX_startbyte == obj.cStartbyteStatus)
	RX_content = fread(obj.hSerialPort, 1, 'uint16');

else
	disp('[RadarSystem.receiveMessage] Error: Bad message start byte received')
end
