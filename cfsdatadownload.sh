#!/bin/bash
echo " prog to download cfs data"
    web="http://nomads.ncdc.noaa.gov"
    path="modeldata/cmd_mm_9mon"
for a in {yrs..yre..increment}  #years
   do
        for mm in {mms..mme..increment}  #month
       do
	 for mm in {mms..mme..increment}  #forecast months
	  do
        	 for dd in {dds..dde..increment}  #days
	    do
	     for utc in {00..18..6}             #utc
	     do
		 wget "$web/$path/$a/$a$i/$a$i$k/flxf$a$i$k$l.01.$a$j.avrg.${l}Z.grb2"
                      # http://nomads.ncdc.noaa.gov/modeldata/cmd_mm_9mon/flxf1996042118.01.199609.avrg.18Z.grb2 
            done
          done
       done
    done
done
