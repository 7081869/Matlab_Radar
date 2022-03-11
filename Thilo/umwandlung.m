%% Umwandlung Binärdatei in .txt File
fdata = 'data_P2G_1person';
fIDRaw = fopen([fdata '.raw.bin'], 'r', 'b'); % open file handle, big-endian style
inhalt = fread(fIDRaw);
NeuWrite = fopen('Rawdata.txt', 'w');
fwrite(NeuWrite, inhalt);

