function [header, data] = reading_hatpro_TP_data(fname)

%[header, data] = reading_hatpro_tpc_data(fname)


BaseTime = datenum(2001,1,1, 0,0,0);
fid = fopen(fname, 'r');

%%% header
temp = fread(fid,2,'int32');
header.FileCode      = temp(1);
header.N             = temp(2);
header.TPCMin        = fread(fid,1,'float32');
header.TPCMax        = fread(fid,1,'float32');
header.TPCTimeRef    = fread(fid,1,'int32'); % 1:UTC, 0: Local Time
header.TPCRetrieval  = fread(fid,1,'int32'); % 0:lin. Reg., 1: quad. Reg., 2: Neutral Network
header.AltAnz        = fread(fid,1,'int32'); % number of altitude layers

%%% data
data.Alts          = fread(fid,header.AltAnz,'int32'); % altitudes [m]
for indx = 1:header.N
    data.ObsTime(indx)  = datenum(BaseTime + double(fread(fid,1,'uint32'))/(24*60*60)); % time of sample N
    data.RF(indx)         = fread(fid,1,'bit1'); % rainflag (0: no rain, 1: rain)
    data.TP(indx,:)         = fread(fid,header.AltAnz,'float32'); % altitudes [m]
end

fclose(fid);