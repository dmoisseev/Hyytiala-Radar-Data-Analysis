function [Radar] = reading_HYDRA_C_data(pname, stDate, enDate, fname)

%%% Reading C-band radar data
%%% [Radar] = reading_HYDRA_C_data(pname, stDate, enDate, fname)
%%% pname - path to the data files
%%% stDate and enDate are starting and end dates of the event in the
%%% Matlab datenum format
%%% fname - something like 'C_band*20180301.cdf'

flist  = dir(fullfile(pname, fname));
count = 0;

for findx = 1:length(flist)
    
    filename   = flist(findx,1).name;
    
    [data, ~]  = nc_radar_read([pname,filename]);
    TimeOffset = double(data.time_offset);
    BaseTime   = data.base_time;
    ObsDay     = datenum([1970 1 1 0 0 double(BaseTime)]);
    
    if ObsDay >=datenum(stDate) && ObsDay<=datenum(enDate)
        
        if count == 0
            Radar.ObsTime     = ObsDay + double(TimeOffset/(3600*24)).';
            Radar.R_asl       = double(data.range) + double(data.altitude);
            Radar.R           = double(data.range);
            Radar.Ze          = double(data.reflectivity);
            Radar.dBT         = double(data.total_power);
            Radar.LDR         = double(data.linear_depolarization_ratio_h);
            Radar.SW          = double(data.spectrum_width);
            Radar.V           = double(data.velocity);
            Radar.SQI         = double(data.normalized_coherent_power);
            Radar.name        = 'HYDRA-C';
            
            count = count + 1;
        else
            
            Radar.ObsTime     = cat(2, Radar.ObsTime, ObsDay + double(TimeOffset/(3600*24)).'); 
            Radar.Ze          = cat(2, Radar.Ze,        double(data.reflectivity));
            Radar.V           = cat(2, Radar.V,         double(data.velocity));
            Radar.dBT         = cat(2, Radar.dBT,       double(data.total_power));
            Radar.LDR         = cat(2, Radar.LDR,       double(data.linear_depolarization_ratio_h));
            Radar.SW          = cat(2, Radar.SW,        double(data.spectrum_width)); 
            Radar.SQI         = cat(2, Radar.SQI,       double(data.normalized_coherent_power)); 
            count = count + 1;
            
        end
        
    end
    
end

