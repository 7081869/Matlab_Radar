function sendMessage(obj, uEndpoint, payload)

try
    message = [ ...
        typecast(cast(obj.cStartbyteMessage,    'uint8'),'uint8'),  ... % Every message starts with this data
        typecast(cast(uEndpoint,                'uint8'),'uint8'),  ... % Send endpoint ID as 8 bit integer
        typecast(cast(length(payload),          'uint16'),'uint8'), ... % Send size of payload as 16 bit integer (so maximum payload size is 64kb)
        typecast(cast(payload,                  'uint8'),'uint8'),  ... % Send payload
        typecast(cast(obj.cEndOfMessage,        'uint16'),'uint8'), ... % Every message ends with this data
        ];
    
    while obj.hSerialPort.BytesAvailable % flush buffer
        fread(obj.hSerialPort, 1, 'uint8');
    end
    
    fwrite(obj.hSerialPort, message, 'uint8'); % write message to serial port
catch
    disp('[RadarSystem.sendMessage] Error: Unable to write to USB!')
end
