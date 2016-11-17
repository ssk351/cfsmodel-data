load "/usr/share/ncarg/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/usr/share/ncarg/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/share/ncarg/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/share/ncarg/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
begin

  yrs=1982
  yre=1983
  yr=yre-yrs+1
  nyr=yre-yrs+1
  nens =  8
  nfcst = 8
  ;==================================================================================
              ;reading single file data
  ;=================================================================================
  a=addfile("flxf1982042100.01.198205.avrg.00Z.grb2","r")
  rf=a->PRATE_P8_L1_GGA0_avg1m                               ;precip rate(lat,lon)
  lat=a->lat_0
  lon=a->lon_0
  ; printVarSummary(rf)
  ;=====================================================================================
                   ;create new variable with coordinate variables
  ;=====================================================================================
  dims = dimsizes((rf))
  nlat=dims(0)
  nlon=dims(1)
  data1 = new((/nyr,nens,nfcst,nlat,nlon/),float)               ;create new variable with name data1
  data1!0="year"
  data1&year=ispan(yrs,yre,1)
  data1!1="ens"
  data1&ens=ispan(1,8,1)
  data1!2="fcstMonth"
  data1&fcstMonth=ispan(5,12,1)*1.
  data1&fcstMonth@units="months since 2000-12-01"
  data1!3="lat"
  data1&lat=rf&lat_0
  data1!4="lon"
  data1&lon=rf&lon_0
   ;==================================================================================
            ;Read the data
  ;====================================================================================
       ii= -1
      do mm=05,12 
       ; print(mm+"")
        ii=ii+1
        ic=-1
         do utc=00,18,06
            do dd = 21,26,5
            ic=ic+1
              i=0
              do yr=yrs,yre

                if (mm .lt.10.and.utc.lt.10) then
                 fn="flxf"+yr+"04"+dd+"0"+utc+".01."+yr+"0"+mm+".avrg."+"0"+utc+"Z.grb2"

                 else if(mm.lt.10.and.utc.gt.10)
                   fn="flxf"+yr+"04"+dd+utc+".01."+yr+"0"+mm+".avrg."+utc+"Z.grb2"

                   else if(mm.ge.10.and.utc.lt.10)
                    fn="flxf"+yr+"04"+dd+"0"+utc+".01."+yr+mm+".avrg."+"0"+utc+"Z.grb2"

                    else if(mm.ge.10.and.utc.gt.10)
                   fn="flxf"+yr+"04"+dd+utc+".01."+yr+mm+".avrg."+utc+"Z.grb2"

                   ; print(fn)
                  end if
                  end if
                  end if
                  end if

                  fh = addfile(fn,"r")
                   data1(i,ic,ii,:,:)=(/fh->PRATE_P8_L1_GGA0_avg1m/)
                   i=i+1
              
              end do ;yr
         end do  ;dd
    end do  ;utc
  end do  ;month
                     data1=data1*86400          ; to conver units into mm/day
 
 
;   ========================================================================================
                       ;MANIPULATION
  ;========================================================================================
   ;data1dim=fh(yr,ens,month,lat,lon)
;-=========================================================================================
                      ; for xy plot
;-==========================================================================================
  datxy=dim_avg_n_Wrap(data1,(/0/))                                                    ; out comes      (ens,mm,lat,lon)
  dataexy=dim_avg_n_Wrap(datxy,(/0/))                                                  ;     ,,         (mm,lat,lon)
  dataenxy=dim_avg_n_Wrap(datxy(:,:,:,:),(/1/))                                        ;    ,,         (ens,lat,lon)
  datavg_ind=dim_avg_n_Wrap(datxy(:,:,6:40,65:100),(/2,3/))                            ;     ,,         (ens,mm)
  datavg_ind_ens=dim_avg_n_Wrap(datavg_ind(:,:),(/1/))                                 ;   ,, (ens)                ;for plot()
; printVarSummary(datavg_ind_ens)
; print(datavg_ind_ens)
  
  datavg_ind_jjas=dim_avg_n_Wrap(datavg_ind(:,1:4),(/1/))                              ;    ,,         (ens)   for plot3
  dataenxyb_l=dim_avg_n_Wrap(dataexy(:,6:40,65:100),(/1,2/))                           ;    ,,         (mm)    for plot 1&2
  
            wks1=gsn_open_wks("png","rainfall")

  ;============================================================================================
          ;RESOURCES
  ;===========================================================================================
        res1 =True
	res1@gsnMaximize=True
	res1@gsnDraw=False
        res1@gsnFrame=False
        res1@gsnXYBarChart=True
        res1@tiMainString="lead monthly mean rainfall over india"
        res1@tiXAxisString="lead month"
        res1@gsnXYBarChartColors="green"
        res1@tmXBLabelAngleF=90
        res1@tiYAxisString="rainfall(mm/day)"


        resTick                = True
        resTick@ttmFormat      = "%c"
        resTick@ttmAxis        = "XB"
        resTick@ttmMajorStride = 1
              
          res2=True
          res2@gsnXYBarChart=False
          res2@gsnDraw=False
          res2@gsnFrame=False
          res2@xyLineColor="blue"
          res2@tiMainString="lead monthly mean rainfall over india"
          res2@tiXAxisString="lead month"
          res2@tiYAxisString="rainfall(mm/day)"
          res2@xyLineThicknessF=5
          res2@tmXBLabelAngleF=90
          res2@trYMaxF=3
          res2@xyMarkLineMode="marklines"
          res2@xyMarker=16
          res2@xyMarkerColors=(/"yellow"/)

         
         res3=True
         res3@gsnXYBarChart=False
         res3@tiMainString=" ensembles  over india during jjas period"
         res3@tiXAxisString="months"
         res3@tiYAxisString="rainfall ensemble values"
         res3@xyLineColor="blue"
     time_axis_labels(data1&fcstMonth,res1, resTick )
     time_axis_labels(data1&fcstMonth,res2,resTick)
  ; ;=============================================================================================
  ;         ; plots
 ;===============================================================================================

         plot1=gsn_csm_xy(wks1,ispan(5,12,1),dataenxyb_l,res1)          ;lead monthly mean bar plot
        plot2=gsn_csm_xy(wks1,ispan(5,12,1),dataenxyb_l,res2)          ;lead monthly mean line plot
        plot3=gsn_csm_xy(wks1,ispan(1,8,1),datavg_ind_jjas,res3)
          overlay(plot1,plot2)    ;(bar&line)lead monthly mean rainfall over india
          draw(plot1)
            frame(wks1)
  ;====================================================================================================================     
     
     colors=(/"blueviolet","skyblue","orange","coral","pink","aquamarine","lightgray","lightseagreen","slategray"/)

      	 res3=True
         res3@gsnXYBarChart=False
         res3@xyLineColor="blue"
         res3@tiMainString="ensembels over india" 
         res3@tiXAxisString="months"
         res3@tiYAxisString="ensemble rainfall"
         res3@xyLineColor=colors(0)
         res3@xyLineThicknessF=2
	 res3@trYMaxF=3
         res3@gsnDraw=False
         res3@gsnFrame=False
         res3@gsnMaximize=True
         res3@xyMarkLineMode="marklines"
         res3@xyMarkerColors=(/"red"/)
         res3@xyMarker=16
        
;=========================================================================================================
      ; ensemble members
;=========================================================================================================
                plota=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(0,:7),res3)   ; ensemble-1
           res3@xyLineColor=colors(1)
         	plotb=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(1,:7),res3)   ;ensmble-2
           res3@xyLineColor=colors(2)
         	plotc=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(2,:7),res3)   ;ensmble-3
           res3@xyLineColor=colors(3)
          	 plotd=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(3,:7),res3)  ;ensmble-4
           res3@xyLineColor=colors(4)
           	 plote=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(4,:7),res3)  ;ensmble-5
           res3@xyLineColor=colors(5)
            	 plotf=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(5,:7),res3)  ;ensmble-6
           res3@xyLineColor=colors(6)
             	 plotg=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(6,:7),res3)  ;ensmble-7
           res3@xyLineColor=colors(7)
             	  ploth=gsn_csm_xy(wks1,ispan(5,12,1),datavg_ind(7,:7),res3) ;ensmble-8
           res3@xyLineColor=colors(8)
                   plot2=gsn_csm_xy(wks1,ispan(5,12,1),dataenxyb_l(:7),res2)  ;ensemble mean of rainfall
         
         
         overlay(plot2,plota)
         overlay(plot2,plotb)
         overlay(plot2,plotc)
         overlay(plot2,plotd)
         overlay(plot2,plote)
         overlay(plot2,plotf)
         overlay(plot2,plotg)
     	 overlay(plot2,ploth)
 
;===============================================================================  ;legend attachment
       lgres3=True
       lgres3@lgLineColors=colors
       lgres3@lgItemType="lines"
       lgres3@vpWidthF=0.13
       lgres3@vpHeightF=0.10
       lgres3@lgPerimThicknessF=4
       lgres3@lgMonoDashIndex=True

             labels=(/"ens1","ens2","ens3","ens4","ens5","ens6","ens7","ens8","ensm"/)
      
               legend=gsn_create_legend(wks1,9,labels(0:8),lgres3)
        amres3=True
   ;     amres3@amJust="topright"
        amres3@amParallelPosF=0.3
        amres3@amOrthogonalPosF=-0.4
       
                ann=gsn_add_annotation(plota,legend,amres3)
;===============================================================================         
                ; plots ovelay
 ;======================================================================
         draw(plot2)
        frame(wks1)
 ;==========================================================================
end

