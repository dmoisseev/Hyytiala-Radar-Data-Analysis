function [ SWP  ATT ] = nc_radar_read(theNetCDFFile)

%  Recover and struture information from EOL Radar NetCDF files
%  Creates two matlab structures: SWP and ATT.  SWP contains numeric
%  values, including data values and calibration information.  ATT 
%  contains (almost exclusively) text-based information, such as the 
%  variable long_name, and global attributes (non-text values in the 
%  global attributes include the Year, Month, and Day, often as an 
%  integer)
%
%  Use of this routine simplifies information recovery, and
%  allows addressing of variables by internal name; you can list all
%  variable names, and address those variables using non-constants for 
%  their names.  Essentially, you can use the self-documenting feature
%  NetCDF in a more complete way.
%
%  Use of this function allows opening of multiple radars or multiple 
%  NetCDF files at the same time, just by changing the SWP and ATT
%  structure names.
%
%  Copyright NCAR, 2009-2011
%  Original routine by Scott Ellis and Chris Burghart
%  Extensive modification by R. Rilling
%  Aug 2011: modified to accept uncompressed netCDF4, with or
%   without beam clipping

% Open the NetCDF file.

ncid = netcdf.open(theNetCDFFile,'NC_NOWRITE');

[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

% Recover global attributes.  For lack of a better place, put these 
% attributes in ATT

if ngatts > 0
   for i=1:ngatts  
      gattname = netcdf.inqAttName(ncid,netcdf.getConstant('NC_GLOBAL'),i-1);
      ATT.(gattname)  = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),gattname);
   end;
end;

% Recover all variables and Attributes.
% If data type is 5, treat as numeric, and store in SWP structure;
% otherwise, assume text info, and store in ATT structure.
%

for i=1:nvars

    % Get the name of the variable.
    [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,i-1);
    
    % Get the variable ID of the variable, given its name.
    varid = netcdf.inqVarID(ncid,varname);
    
    % Get the value of the variable, given its ID.
    % First convert single precision (xtype=5) to double.

    if xtype==5
        data = netcdf.getVar(ncid,varid,'double');
    else 
        data = netcdf.getVar(ncid,varid);  
    end;

    % apply scale factor and offset if they are defined and convert to
    % double.
    scale_factor=0.0;
    add_offset=0.0;
    missing_value=-9e10;
    if( varAtts > 0)  % Sometimes there are no attributes! Code breaks if you don't test.
       for j=1:varAtts
          attname=netcdf.inqAttName(ncid,varid,j-1);
          myname = regexprep( deblank(attname) , '^_', ''); % no blanks in name, and no leading _
          ATT.(varname).(myname) = netcdf.getAtt(ncid,varid,attname);
       end;
    else;
       ATT.(varname) = 'unknown attributes';  
    end;

    if( isfield(ATT.(varname), 'FillValue'))
       missing_value = ATT.(varname).FillValue;
% replace missing values with NaN; this also avoids the scaling of missing values
       clear ii
       ii=find(data == missing_value);
       data(ii) = NaN;
    end;

   if( isfield(ATT.(varname), 'scale_factor'))
      scale_factor = ATT.(varname).scale_factor;
      add_offset   = ATT.(varname).add_offset;

      if (scale_factor ~= 0.0 | add_offset ~= 0.0)
         data=double(data);
         data = data*scale_factor + add_offset;
      end;
   end;

% fill-in any clipped beams to create regular-sized beam arrays
% do this only for radar parameters with time/range coordinates
% and only when n_gates_vary is true

   if( (isfield(ATT,'n_gates_vary') && ~isempty(strmatch('true',ATT.n_gates_vary))) && ...
       ( isfield(ATT.(varname), 'coordinates') && ~isempty(strmatch('time range', ATT.(varname).coordinates, 'exact' ))))
      G = get_unscaled_nc_data( theNetCDFFile, {'ray_n_gates','ray_start_index', 'time'});
      Gmax = max(G.ray_n_gates);
      Gmin = min(G.ray_n_gates,1);
      if( Gmax == Gmin )
         mydat.(varname) = data;
      else
         nbeams = size(G.time,1);
         a(1:Gmax,1:nbeams) = NaN;
         for jj=1:nbeams;
   % note that the start index for the beams begins at zero. (C-style array index starts at 0)
            a(1:G.ray_n_gates(jj),jj) = data((G.ray_start_index(jj)+1):(G.ray_start_index(jj)+G.ray_n_gates(jj)));
         end;
         SWP.(varname) = a;
      end;
   else
      SWP.(varname) = data;
   end;
end;

netcdf.close(ncid);

