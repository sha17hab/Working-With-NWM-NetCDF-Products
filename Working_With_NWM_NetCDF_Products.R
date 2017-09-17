#
# Author: Shahab Afshari
# Email: safshar00@citymail.cuny.edu
# Civil Engineering Department/Water Resources Program
# City College of New York/City University of New York
# Name: Working_With_NWM_NetCDF_Products.R 
#
# Description - PART 1: 
#  Given a single or set of NHDPlus COMIDs (stored by a colummn of a CSV file that contains a single or a set of 
#  NHDPlus COMIDs) plus NetCDF (*.nc) file(s) that stores National Water Model's (NWM) streamflow simulations
#  corresponding to the applied COMIDs, the following R-script will extract NWM simulated streamflow at a single 
#  or multiple NHDPlus lines (i.e. a single COMID or multiple COMIDs) and will export a CSV table named as NHDPlus 
#  COMID, e.g. "22473367_streamflow.csv".
#
# Description - PART 2:
#  After executing PART 1, PART 2 would be used to extract the maximum record of the streamflow time-series
#  associated with a single or multiple COMIDs. These extremum records associated with a single or multiple 
#  COMIDs will be saved as a CSV file named as "All_streamflow.csv" at the assigned working directory.
#
# Requirements: "ncdf4" package.

#######################    Importing Required Libraries or Packages   #########################
if("ncdf4" %in% rownames(installed.packages()) == FALSE) {install.packages("ncdf4")} 
library(ncdf4)

# TO USERES ATTENTION:
## USERS OF THE CURRENT SCRIPT MUST ONLY MODIFY AND ADJUST THE LINES AT SECTIONS 
## WHERE "(DEFINED BY USER)" SIGNs ARE EXISTED AND THEN RUN THE WHOLE SCRIPT AND 
## THE RESULTS AS *.CSV FILES THROUGH ASSIGN OUTPUT DIRECTORIES. ANY CHANGES OR
## MOFICATION BY THE USER WILL OR MAY FAIL EXECUTION OF THE SCRIPT.

#######################        Setting Working Directory         ###############################
## (DEFINED BY USER)
## NOTE1: A path as a working directorty must be set by the user. This is path of a directory where the
## NetCDF files of NWM's streamflow simulations are being stored. Check the following example. 
## EXAMPLE: Working_Directory = '/Volumes/RAID1-2TB/virtualbox_shahab/RStudioCodes/NetCDFSamples/'
Working_Directory = '/Volumes/RAID1-2TB/virtualbox_shahab/RStudioCodes/NetCDFSamples/'
setwd(Working_Directory)

##############################        PART 1         ###########################################
# NHDPlus COMID's to be checked

# 1.1. Multiple COMIDs (DEFINED BY USER)
## Importing multiple COMIDs values stored in a column of CSV file 
## NOTE2: Execute the following line if you are going to deal with multiple COMIDs 
## NOTE3: The path of a CSV file containing the COMIDs must be applied and set by the user 
## as an input in "read.csv()" function in order to extract the COMID values. 
## Check the following example. 
## EXAMPLE: COMIDs = as.matrix(read.csv("/Volumes/RAID1-2TB/virtualbox_shahab/RStudioCodes/DataToBeChecked/COMIDs.csv",header = F))
COMIDs = as.matrix(read.csv("SET THE PATH OF COMIDs.csv FILE HERE",header = F))

# 1.2. Single COMID (DEFINED BY USER)
## NOTE4: execute the following line if you are going to deal with a singke COMID
COMIDs = 22477695

# 2. Listing NetCDF files 
## The followling line will list and sort the existing NetCDF files (*.nc) at the
## current working directory and will store them as "NetCDFFiles" variable
NetCDFFiles = sort(list.files(Working_Directory,pattern = "\\.nc$")) # $ at the end means that this is end of string.

# 3. 
## Number of unique COMIDs
Unique_COMIDs_Counts = length(unique(COMIDs))
## Unique COMID values, to be assigned to the "Unique_COMIDs" variable
Unique_COMIDs = unique(COMIDs)

# 4. Importing the NetCDF files associated with the "Unique_COMIDs"
counter = 1
for (i_Unique_COMIDs in 1:Unique_COMIDs_Counts) {
  ## 4.1. Importing the NetCDF file associated with a particular date, e.g. for "201609010100_streamflow.nc" 
  ##    the date of the record would be 2016/09/01 at 01:00
  for (i_NetCDFFiles in 1:length(NetCDFFiles)){
    ### 4.1.1. open a NetCDF file and read its data
    nc = nc_open( NetCDFFiles[i_NetCDFFiles]) 
    ### 4.1.2. extracting prefix associated with the date, e.g. "201609010100" in "201609010100_streamflow.nc" 
    nc_date = strsplit(NetCDFFiles[i_NetCDFFiles],'_')[[1]][1]  
    ### 4.1.3. extracting year value, e.g. "2016" from "201609010100"
    nc_date_year = substr(nc_date,1,4)
    ### 4.1.4. extracting month value, e.g. "09" from "201609010100"
    nc_date_month = substr(nc_date,5,6)
    ### 4.1.5. extracting month value, e.g. "01" from "201609010100"
    nc_date_day = substr(nc_date,7,8)
    ### 4.1.5. extracting time (hhhh) value, e.g. "0100" from "201609010100"
    nc_date_hour = substr(nc_date,9,12)
    
    ### 4.1.6. extracting the 'streamflow' and 'feature_id' values of the NetCDF file 
    streamflow_data = ncvar_get(nc,varid = 'streamflow')
    feature_id_data = ncvar_get(nc,varid = 'feature_id') #or the original COMIDs
    
    ### 4.1.7. finding and selecting the index of a particular COMID value among list of COMIDs
    feature_id_data_selected = feature_id_data[which(feature_id_data %in% Unique_COMIDs)]
    streamflow_data_selected = streamflow_data[which(feature_id_data %in% Unique_COMIDs)]
    
    ### 4.1.8 combineing and exporting [feature_id_data_selected, streamflow_data_selected]
    ### as data.frame
    feature_id_PLUS_streamflow_data_selected_df = data.frame(feature_id_data_selected,streamflow_data_selected)
    
    rm(feature_id_data_selected)
    rm(streamflow_data_selected)
    
    ### 4.1.9 exporting "Draft_FinalDataFrame" as draft data.frame containing 
    ### 'COMID', date of record as "YYYY-MM-DD", time of record as "Time (HH:HH)", 
    ### and "Streamflow (m3/s)" as discharge simulated bt NWM
    if (exists("Draft_FinalDataFrame")) {
      Draft_FinalDataFrame_scratch = data.frame(Unique_COMIDs[i_Unique_COMIDs], # COMID
                 paste0(nc_date_year,'-',nc_date_month,'-',nc_date_day), # YYYY-MM-DD
                 nc_date_hour, # HHHH
                 feature_id_PLUS_streamflow_data_selected_df$streamflow_data_selected[
                   which(feature_id_PLUS_streamflow_data_selected_df$feature_id_data_selected ==
                           Unique_COMIDs[i_Unique_COMIDs])] # Streamflow
      )
      colnames(Draft_FinalDataFrame_scratch) = c("COMID","Date (YYYY-MM-DD)","Time (HH:HH)","Streamflow (m3/s)")
      Draft_FinalDataFrame = rbind(Draft_FinalDataFrame ,Draft_FinalDataFrame_scratch)
      rm(Draft_FinalDataFrame_scratch)
    } else {
      Draft_FinalDataFrame = data.frame(Unique_COMIDs[i_Unique_COMIDs], # COMID
                                        paste0(nc_date_year,'-',nc_date_month,'-',nc_date_day), # YYYY-MM-DD
                                        nc_date_hour, # HHHH
                                        feature_id_PLUS_streamflow_data_selected_df$streamflow_data_selected[
                                          which(feature_id_PLUS_streamflow_data_selected_df$feature_id_data_selected ==
                                                  Unique_COMIDs[i_Unique_COMIDs])])
    }
    
    colnames(Draft_FinalDataFrame) = c("COMID","Date (YYYY-MM-DD)","Time (HH:HH)","Streamflow (m3/s)")
    
  }
  # 4.2. Writing final deliverable table as CSV file
  write.csv(Draft_FinalDataFrame, file = paste0(Draft_FinalDataFrame$COMID[[1]],"_streamflow",".csv"))
  sprintf("%d. %s - %s streamflow timeseries of COMID = %s has been saved", 
          counter,
          Draft_FinalDataFrame$`Date (YYYY-MM-DD)`[[1]],
          Draft_FinalDataFrame$`Date (YYYY-MM-DD)`[[nrow(Draft_FinalDataFrame)]],
          Draft_FinalDataFrame$COMID[[1]])
  rm(Draft_FinalDataFrame)
  counter = counter+1
}

##############################         PART 2        ##########################################
# 1. Listing and sorting CSV files (i.e. NetCDF files converted to CSv files in PART 1) 
COMIDs = sort(list.files(Working_Directory,pattern = "\\.csv$")) # $ at the end means that this is end of string.

# 2. Extracting maximum streamflow record from the streamflow time-series (saved as, for instance, "2164997_streamflow.csv" file
# back to PART 1) associated with a single or multiple COMIDs 
for (i_site in 1:length(COMIDs)){
  
  # 2.1. Splitting CSV file name by '_' and extracting the COMID value(s)
  COMIDs_value = strsplit(COMIDs[i_site],'_')[[1]][1]
  # 2.2. Importing and storing CSV file(s) containing data collected in PART 1 as "data.frame" 
  COMIDs_data =as.data.frame(read.csv(paste0(Working_Directory,COMIDs[i_site]),header = T))
  # 2.3. Finding the maximum value and it corresponding date and time at the given time-series of streamflow associated with a particular COMID
  MaxFlow = max(COMIDs_data$Streamflow..m3.s.)
  TimeOfMaxFlow = paste(COMIDs_data$Date..YYYY.MM.DD.[which.max(COMIDs_data$Streamflow..m3.s.)],
                        COMIDs_data$Time..HH.HH.[which.max(COMIDs_data$Streamflow..m3.s.)])
  # 2.4. Exporting "Draft_FinalDataFrame_scratch" as draft data.frame containing 
  ### 'COMID', date of record as "DateTime (YYYY-MM-DD HH:HH)", 
  ### and "Streamflow (m3/s)" as discharge simulated bt NWM
  if (exists("Draft_FinalDataFrame")) {
    Draft_FinalDataFrame_scratch = data.frame(COMIDs_value, # COMID
                                              TimeOfMaxFlow, # HHHH
                                              MaxFlow)
    colnames(Draft_FinalDataFrame_scratch) = c("COMID","DateTime (YYYY-MM-DD HH:HH)","Streamflow (m3/s)")
    Draft_FinalDataFrame = rbind(Draft_FinalDataFrame ,Draft_FinalDataFrame_scratch)
    rm(Draft_FinalDataFrame_scratch)
  } else {
    Draft_FinalDataFrame = data.frame(COMIDs_value, # COMID
                                      TimeOfMaxFlow, # HHHH
                                      MaxFlow)
  }
  colnames(Draft_FinalDataFrame) = c("COMID","DateTime (YYYY-MM-DD HH:HH)","Streamflow (m3/s)")
}

# 3. Writing final deliverable table as CSV file
write.csv(Draft_FinalDataFrame, file = paste0("All","_streamflow",".csv"))
