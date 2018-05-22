function [header, offset] = reading_Wband_header(fname)

%[header, offset] = reading_Wband_header(fname)
%
%

BaseTime = datenum(2001,1,1, 0,0,0);
fid = fopen(fname, 'r');

temp = fread(fid,2,'int32');
header.FileCode    = temp(1);
header.HeaderLen   = temp(2);
header.StartTime   = datenum(BaseTime + double(fread(fid,1,'uint32'))/(24*60*60));
header.StopTime    = datenum(BaseTime + double(fread(fid,1,'uint32'))/(24*60*60));
header.CGProg      = fread(fid,1,'int32');
header.ModelNo     = fread(fid,1,'int32');

count = 0;
temp = 1;
while temp ~=0
      temp = fread(fid,1,'int8');
      count=count+1;
      PrgName(count) = char(temp);
end
header.ProgName    = PrgName;

% count = 0;
% countIndx = 0;
% while countIndx <1
%       temp = fread(fid,1,'int8');
%       count=count+1;
%       CustName(count) = char(temp);
%       
%       if temp == 0
%           countIndx = countIndx+1;
%       end
% end

count = 0;
temp = 1;
while temp ~=0
      temp = fread(fid,1,'int8');
      count=count+1;
      CustName(count) = char(temp);
end

header.CustName     = CustName;

header.Freq         = fread(fid,1,'float32');
header.AntSep       = fread(fid,1,'float32');
header.AntDia       = fread(fid,1,'float32');
header.AntGain      = 10*log10(fread(fid,1,'float32'));
header.AntBW        = fread(fid,1,'float32');

if strcmp(fname(end-2:end), 'LV0')
    header.RadarConst   = fread(fid,1,'float32');
end
header.DualPol      = fread(fid,1,'char');

if strcmp(fname(end-2:end), 'LV0')
    header.CompEna      = fread(fid,1,'char');
    header.AntiAlias    = fread(fid,1,'char');
end

header.SampDur      = fread(fid,1,'float32');
header.GPSLat       = fread(fid,1,'float32');
header.GPSLong      = fread(fid,1,'float32');

temp = fread(fid,5,'int32');
header.CalInt       = temp(1);
header.NumbGates    = temp(2);
header.NumbLayersT  = temp(3);
header.NumbLayersH  = temp(4);
header.SequN        = temp(5);
header.RAlts        = fread(fid,header.NumbGates,'float32');

if header.NumbLayersT~=0
    header.TAlts        = fread(fid,header.NumbLayersT,'float32');
else
    header.TAlts    = NaN;
end
if header.NumbLayersH~=0
    header.HAlts        = fread(fid,header.NumbLayersH,'float32');
else
    header.HAlts    = NaN;
end

if strcmp(fname(end-2:end), 'LV0')
    header.RangeFact     = fread(fid,header.NumbGates,'int32');
end

header.SpecN         = fread(fid,header.SequN,'int32');
header.RngOffs       = fread(fid,header.SequN,'int32');
header.ChirpReps     = fread(fid,header.SequN,'int32');
header.SeqIntTime    = fread(fid,header.SequN,'float32');
header.dR            = fread(fid,header.SequN,'float32');
header.maxVel        = fread(fid,header.SequN,'float32');

if strcmp(fname(end-2:end), 'LV0')
    header.ChanBW        = fread(fid,header.SequN,'float32');
    header.ChirpLowIF    = fread(fid,header.SequN,'int32');
    header.ChirpHighIF   = fread(fid,header.SequN,'int32');
    header.RangeMin      = fread(fid,header.SequN,'int32');
    header.RangeMax      = fread(fid,header.SequN,'int32');
    header.ChirpFFTSize  = fread(fid,header.SequN,'int32');
    header.ChirpInvSmpl  = fread(fid,header.SequN,'int32');
    header.ChirpCntrFreq = fread(fid,header.SequN,'float32');
    header.ChirpBWFreq   = fread(fid,header.SequN,'float32');
    header.FFTStrtInd    = fread(fid,header.SequN,'int32');
    header.FFTStopInd    = fread(fid,header.SequN,'int32');
    header.ChirpFFTNo    = fread(fid,header.SequN,'int32');
    header.SampRate      = fread(fid,1,'int32');
    header.MaxRange      = fread(fid,1,'int32');
end

header.SupPowLev     = fread(fid,1,'char');
header.SpkFilEna     = fread(fid,1,'char');
header.PhaseCorr     = fread(fid,1,'char');
header.RelPowCorr    = fread(fid,1,'char');
header.FFTWin        = fread(fid,1,'char');
header.FFTInptRng    = fread(fid,1,'int32');
header.NoiseFilt     = fread(fid,1,'float32');

if strcmp(fname(end-2:end), 'LV0')
    header.RSRV1         = fread(fid,25,'int32');
    header.RSRV2         = fread(fid,5000,'uint32');
    header.RSRV3         = fread(fid,5000,'uint32');
end

offset = ftell(fid);
fclose(fid);