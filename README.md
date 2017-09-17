# Working-With-NWM-NetCDF-Products

Description - PART 1: 
Given a single or set of NHDPlus COMIDs (stored by a column of a CSV file that contains a single or 
a set of NHDPlus COMIDs) plus NetCDF (*.nc) file(s) that stores National Water Model's (NWM) streamflow 
simulations corresponding to the applied COMIDs, the following R-script will extract NWM simulated 
streamflow at a single or multiple NHDPlus line (i.e. a single COMID or multiple COMIDs) and will 
export a CSV table named as NHDPlus COMID, e.g. "22473367_streamflow.csv".  

Description - PART 2: After executing PART 1, PART 2 would be used to extract the maximum record of 
the streamflow time-series associated with a single or multiple COMIDs. These extremum records associated
with a single or multiple COMIDs will be save as CSV file named as "All_streamflow.csv" at the assigned 
working directory. Requirements: "ncdf4" package.
