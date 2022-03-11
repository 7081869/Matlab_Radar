classdef RadarSystem < handle & dynamicprops

    %% methods: constructor, destructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods % constructor & destructor
        % The constructor gets a COM port and synchronizes the data from
        % the board with the properties
        function obj = RadarSystem(sPortName)
            % create an object to access the com port
            obj.hSerialPort = serial(sPortName);

            % open the serial connection:
            try
                obj.hSerialPort.InputBufferSize = 65536*8;
                obj.hSerialPort.OutputBufferSize = 65536*8;
                obj.hSerialPort.Timeout = 5; % s
                fopen(obj.hSerialPort);
            catch
                disp('[RadarSystem.RadarSystem] Error: serial connection problem!');
                fclose(obj.hSerialPort);
                delete(obj.hSerialPort);
                return
            end

            % find potential EP dirs
            szClassPath = mfilename('fullpath');
            ind = strfind(szClassPath, filesep);
            szLibDir = szClassPath(1:ind(end-1));
            sPotentialEPDirs = dir([szLibDir '@*']);

            % query endpoints from board
            [~, cDeviceEPTags, ~] = obj.getEndpointList;
            
            % dynamically bind available endpoints
            for n=1:length(sPotentialEPDirs)
                szEPClass = sPotentialEPDirs(n).name(2:end); % dir name w/o the @ sign
                szObj = ['o' szEPClass];
                try
                    szEPTag = eval([szEPClass '.szEPTag']); % check if the class can return an EP tag
                catch
                    continue
                end

                uEPID = find(strcmp(cDeviceEPTags, szEPTag)); % check if the device provides the specific EP
                if ~isempty(uEPID) % if the device supports the specific endpoint
                    obj.addprop(szObj);
                    obj.(szObj) = eval(sprintf('%s(obj,%d);', szEPClass, uEPID));
                    
                    obj.cEndpoints{end+1} = obj.(szObj);
                    obj.uEndpointIDs(end+1) = uEPID;
                end
            end
            
            % init endpoints
            for n=1:length(obj.cEndpoints)
                obj.cEndpoints{n}.initValues;
            end

        end

        % The destructor closes the COM port and deletes the internal serial object.
        function delete(obj)
            if isvalid(obj.hSerialPort)
                fclose(obj.hSerialPort);
                delete(obj.hSerialPort);
            end
        end
    end

    methods (Static)%, Access = private)
        parseEPStatus(uErrorCode);
    end

    %% properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % general class
    properties (Access = private, Constant)
        % constants that are part of protocol messages
        cStartbyteMessage   = uint8(hex2dec('5A'));
        cStartbyteStatus    = uint8(hex2dec('5B'));
        cStartbyteError     = uint8(hex2dec('5B'));
        cEndOfMessage       = uint16(hex2dec('E0DB'));
    end
    
    properties (Hidden)
        hSerialPort; % a handle to the serial port object used for communication
        uEndpointIDs
        cEndpoints
    end
    
end
