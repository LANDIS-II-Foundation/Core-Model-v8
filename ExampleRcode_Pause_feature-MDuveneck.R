#LANDIS EXTERNAL SCRIPT ("PAUSE") EXAMPLE.
#Matthew Duveneck 9/30/2015
#mduveneck@gmail.com

library(terra) #use the terra package to manipulate raster files.
print ("hello world.  This is a test of core pause") #This line should show up on the LANDIS log.
dir<-"C:/Users/landis_testing/" #set a working directory where your files are.
setwd(dir) #set working directory
time_step<-as.numeric(read.table("lockfile"))#read the current timestep from the landis simulation
date_1<-paste(date(),time_step)#combine the simulation time with the simulation timestep
write.csv(date_1, file=paste0("external_input_maps/test_pause_output.csv"))#write a csv with time and timestep.
r0<-rast(paste0("single_cell_10_IC.img"))#read a LANDIS input raster.  THis is just to have a raster template (e.g., extent)
r0[]<-99#change the value(s) of cells in the template to something else.
#This  is where a new input layer would be created with this external script by timestep.
writeRaster(r0, filename = paste0(dir,"external_input_maps/single_cell_",time_step,".tif"), datatype='INT2S', overwrite=T,NAflag=0)#write new raster to file.

#Below is an example how a landis text file could be modified but currently, this WILL NOT CHANGE SIMULATION AS LANDIS DOES NOT RELOAD THESE PARAMETERS.
LSF<-read.table("species_LANDIS_ANP.txt", skip=1, header=T)#Read table skipping the first line ("LandisData",  "Species" ).
LSF$Longevity[2]<-99 #change the longevity of the second species to 99
LSF_new<-rbind(c("LandisData",  "Species <<"), LSF)#put the first line back.
write.table(LSF_new,"species_LANDIS_ANP2.txt", row.names = F, quote=F, col.names=F)#write the new file back.

