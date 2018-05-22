function [Radar] = Reading_HYDRA_W_data(pname, stDate, enDate, fname)

%%% Reading W-band radar  LVL1 data version 3.5
%%% [Radar] = Reading_HYDRA_W_data(pname, stDate, enDate, fname)
%%% pname - path to the data files
%%% stDate and enDate are starting and end dates of the event in the
%%% Matlab datenum format
%%% fname - something like '180319*.LV1'

flist  = dir(fullfile(pname, fname));
count = 0;

for findx = 1:length(flist)
    
    filename        = flist(findx,1).name;
    
    FileTime = datenum(['20', filename(1:2), '-', filename(3:4),'-',...
                            filename(5:6), ' ', filename(8:9),':',...
                            filename(10:11), ':', filename(12:13)]);
                        
    if FileTime>=stDate && FileTime<=enDate
        
        [header, offset] = reading_Wband_header([pname,filename]);
        [data]           = reading_Wband_data([pname,filename], header, offset);

        
        if count == 0
            Radar.ObsTime     = data.ObsTime;
            
            Radar.R           = header.RAlts;
            Radar.Ze          = double(data.Zv);
            Radar.LDR         = double(data.LDR);
            Radar.CorrC       = double(data.CorrC);
            Radar.PhiX        = double(data.PhiX);
            Radar.SW          = double(data.SW);
            Radar.Skew        = double(data.Skew);
            Radar.Kurt        = double(data.Kurt);
            Radar.V           = double(data.Vel);
            
            
            Radar.LWP         = double(data.LWP);
            Radar.T           = double(data.T);
            Radar.RH          = double(data.RH);
            Radar.TransPow    = double(data.TransPow);
            
            Radar.name        = 'HYDRA-W';
            
            count = count + 1;
        else
            
            Radar.ObsTime     = cat(2, Radar.ObsTime,  data.ObsTime); 
            Radar.LWP         = cat(2, Radar.LWP,      data.LWP); 
            Radar.T           = cat(2, Radar.T,        data.T); 
            Radar.RH          = cat(2, Radar.RH,       data.RH); 
            Radar.TransPow    = cat(2, Radar.TransPow, data.TransPow); 
            
            
            Radar.Ze          = cat(1, Radar.Ze,      double(data.Zv));
            Radar.V           = cat(1, Radar.V,       double(data.Vel));
            Radar.LDR         = cat(1, Radar.LDR,     double(data.LDR));
            Radar.CorrC       = cat(1, Radar.CorrC,   double(data.CorrC));
            Radar.PhiX        = cat(1, Radar.PhiX,    double(data.PhiX));
            Radar.SW          = cat(1, Radar.SW,      double(data.SW));
            
            Radar.Skew        = cat(1, Radar.Skew,    double(data.Skew));
            Radar.Kurt        = cat(1, Radar.Kurt,    double(data.Kurt)); 
            count = count + 1;
            
        end
        
    end
    
end

