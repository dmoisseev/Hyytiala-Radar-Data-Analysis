function [data] = reading_Wband_data(fname, header, offset)

%[data] = reading_Wband_data(fname, header, offset)
%
%

BaseTime = datenum(2001,1,1, 0,0,0);
fid = fopen(fname, 'r');
fseek(fid,offset,'bof');

data.TotSamp = fread(fid,1,'int32');
for indx = 1:data.TotSamp

    data.SampBytes(indx)   = fread(fid,1,'int32');
    offset1 = ftell(fid);
    Time                   = datenum(BaseTime + double(fread(fid,1,'uint32'))/(24*60*60));
    Time_usec              = double(fread(fid,1,'int32'));
    data.ObsTime(indx)     = Time + 1e-3*Time_usec/(24*60*60);
    data.QF(indx)          = fread(fid,1,'char');
    data.RR(indx)          = fread(fid,1,'float32');
    data.RH(indx)          = fread(fid,1,'float32');
    data.T(indx)           = fread(fid,1,'float32');
    data.P(indx)           = fread(fid,1,'float32'); 
    data.WS(indx)          = fread(fid,1,'float32');
    data.WD(indx)          = fread(fid,1,'float32');
    data.DD_V(indx)        = fread(fid,1,'float32');
    data.Tb(indx)          = fread(fid,1,'float32');
    data.LWP(indx)         = fread(fid,1,'float32');
    data.PowIF(indx)       = fread(fid,1,'float32');
    data.El(indx)          = fread(fid,1,'float32');
    data.Az(indx)          = fread(fid,1,'float32');
    data.BlwStatus(indx)   = fread(fid,1,'float32');
    data.TransPow(indx)    = fread(fid,1,'float32');
    data.TransT(indx)      = fread(fid,1,'float32');
    data.RecT(indx)        = fread(fid,1,'float32');
    data.PCT(indx)         = fread(fid,1,'float32');
    Res                    = fread(fid,3,'float32');
    
    if header.NumbLayersT>0
        data.T_Prof(indx,:)        = fread(fid,header.NumbLayersT,'float32');
        data.AbsHumid_Prof(indx,:) = fread(fid,header.NumbLayersH,'float32');
        data.RH_Prof(indx,:)       = fread(fid,header.NumbLayersH,'float32');
    end
    
  
    data.Sensit_v(indx,:)      = fread(fid,header.NumbGates,'float32');
    data.Sensit_h(indx,:)      = fread(fid,header.NumbGates,'float32');
    data.PrMsk(indx,:)         = fread(fid,header.NumbGates,'char');
    
    for indxR = 1:header.NumbGates
        if data.PrMsk(indx,indxR) == 1
            
            data.Zv(indx, indxR)   = fread(fid,1,'float32');
            
            data.Vel(indx, indxR)  = fread(fid,1,'float32');
            data.SW(indx, indxR)   = fread(fid,1,'float32');
            data.Skew(indx, indxR) = fread(fid,1,'float32');
            data.Kurt(indx, indxR) = fread(fid,1,'float32');
            
            if header.DualPol>0
                data.LDR(indx, indxR)    = fread(fid,1,'float32');
                data.CorrC(indx, indxR)  = fread(fid,1,'float32');
                data.PhiX(indx, indxR)   = fread(fid,1,'float32');
            end
            
        else
            
            data.Zv(indx, indxR)   = NaN;
            data.Vel(indx, indxR)  = NaN;
            data.SW(indx, indxR)   = NaN;
            data.Skew(indx, indxR) = NaN;
            data.Kurt(indx, indxR) = NaN;
            
            if header.DualPol>0
                data.LDR(indx, indxR)    = NaN;
                data.CorrC(indx, indxR)  = NaN;
                data.PhiX(indx, indxR)   = NaN;
            end
        end
        
    end
    
    offset2 = ftell(fid);
    diff_offset =(offset2-offset1); % checking the actual sample size
    
    if (data.SampBytes(indx)-diff_offset) ~= 0
        disp('Something is wrong. The sample size is not right.');
        fread(fid,data.SampBytes(indx)-diff_offset, 'char');
    end
    
end
fclose(fid);