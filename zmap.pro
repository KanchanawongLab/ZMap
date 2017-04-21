pro WID_BASE_zmap_event, Event
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask, maskCode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common ThresholdUtility, filelist, filenumber,currentfileindex, currentfile


common analysis, minimumROIsize,labelimage,ROIgroup,anastructarr 

wTarget = (widget_info(Event.id,/NAME) eq 'TREE' ?  $
    widget_info(Event.id, /tree_root) : event.id)
    
    
  wWidget =  Event.top
  
  case wTarget of
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_LOADTIFF'):         loadtiff, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_FRAME'):         displaytiff, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_TOP'):         adjustcontrast, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_BOTTOM'):         adjustcontrast, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_AUTOSCALETIFF'): begin
      
          if autoscale eq 0 then begin
            autoscale = 1
            widget_control,Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_AUTOSCALETIFF'),set_button=1
          endif else begin
            widget_control,Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_AUTOSCALETIFF'),set_button=0
            autoscale = 0
          endelse
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_RESET'): begin
        widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
        zoomcoord= [ 0, 0,dimension[0]-1,dimension[1]-1]
        displaytiff, event  
    end 
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_UNZOOM'): begin
        zoomcoord= [ 0, 0,dimension[0]-1,dimension[1]-1]
        if screenmode eq 0 then displaytiff, event else displaymap, event
    end 
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_PLOTFRAME'):         plotselection, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_DRAW_MAIN'):         zmapdrawevents, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_FIELD'):         plotfield, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_EXTRACTAVG'):         extractzavg, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_EXTRACTPIXZOOM'):         extractzpixzoom, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_EXTRACTPIXALL'):         extractzpixall, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_FIXEDZ'):         fieldfixedz, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_THRESHOLD'):         viewthreshold, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_SAVESCREENTIFF'):         savescreentiff, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_ZSCALE'):         zcolormax = DIALOG(/FLOAT,VALUE=zcolormax,TITLE='Set maximum Z of color scale','Enter Z maximum (nm) ')
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_PIXELSIZE'):         pixelsizenm = DIALOG(/FLOAT,VALUE=pixelsizenm,TITLE='Set Image Pixel Size (nm)','Enter Image Pixel Size (nm) ')
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_GUESSITERATION'):         guessiteration = DIALOG(/FLOAT,VALUE=guessiteration,TITLE='Set Maximum Trial Solutions','Enter Maximum Trials # ')
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_GUESSMAX'):         guessMaximum = DIALOG(/FLOAT,VALUE=guessMaximum,TITLE='Set Maximum Trial Z Height','Enter Maximum trial Z (nm) ')  
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_MAP'):         displaymap, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_SAVEZMAP'):         savesav, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_LOADZMAP'):         loadsav, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_SCREENMODE'):         if screenmode eq 1 then begin
          screenmode = 0 & displaytiff, event
       endif else begin
          screenmode = 1 & displaymap, event
       endelse
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_SAVEZMAP'):         quicksavesav, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_PRECONVERT'):         preconverttiff, event
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_DOBATCH'):         batchextraction, event
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_GETSTAT'):         getstat, event
 
     
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_MINVAL'): begin
;      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        viewthreshold, event
    end 
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_MASKCODE'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then begin
          maskcode = (maskcode eq 0)? 1:0
          widget_control,Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_MASKCODE'),set_button=maskcode
        end
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_MASK'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        viewmask, event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_DEFINEMASK'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        widget_control,Widget_Info(wWidget, FIND_BY_UNAME='WID_TEXT_FILENAME'),get_value=filename
        filenumber = 1
        filelist = [filename]
        currentfileindex =0
        currentfile= filename
        WID_BASE_ZmapTU, GROUP_LEADER=event.top, _EXTRA=_VWBExtra_ 
    end
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_EXPORTZTIFF8'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        saveztiff, event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_EXPORTZTIFFDBL'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        saveztiffdbl, event
    end
        else:
  endcase
  
end

pro WID_BASE_Zmap, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common mouse, mousedown, infoinitial

mousedown = 0
datafile=''
numberofframes=0 
dimension=0
wxsz = 1024
wysz = 1024
autoscale = 1
zoomcoord = [0,0,511,511]
rawimage=uintarr(2,2)

  Resolve_Routine, 'zmap_eventcb',/COMPILE_FULL_FILE 
  
WID_BASE_zmap = Widget_Base( GROUP_LEADER=wGroup,  $
  UNAME='WID_BASE_ZMAP' ,/SCROLL, XOFFSET=5 ,YOFFSET=5  $
  ,SCR_XSIZE=1600 ,SCR_YSIZE=1100,XSIZE=1600,YSIZE=1100  $
  , TITLE='ZMap: VIAFLIC Processing and Utility (c) 2015 Kanchanawong Lab, MBI/NUS' ,SPACE=3 ,XPAD=3 ,YPAD=3  $
  ,MBAR=WID_BASE_mbar_zmap, notify_realize='initializezmap')
  
WID_DRAW_main = Widget_Draw(WID_BASE_zmap,  $
  UNAME='WID_DRAW_MAIN' ,XOFFSET=300 ,YOFFSET=3  $
  ,SCR_XSIZE=1024 ,SCR_YSIZE=1024  $
  ,/BUTTON_EVENTS)
  
WID_TEXT_filename = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_FILENAME' ,FRAME=1 ,XOFFSET=5 ,YOFFSET=5  $
  ,SCR_XSIZE=260 ,SCR_YSIZE=120 ,/WRAP ,VALUE=[''] ,XSIZE=20 ,YSIZE=3)

WID_LABEL_numframe = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_TOTALFRAME' ,XOFFSET=5 ,YOFFSET=130  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Total Frames :' ,XSIZE=20 ,YSIZE=3)
  
WID_TEXT_numframe = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_TOTALFRAME' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=130  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3,/align_right)
  
WID_LABEL_xpix = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_XPIX' ,XOFFSET=5 ,YOFFSET=130+25  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='X Pixels :' ,XSIZE=20 ,YSIZE=3)
  
WID_TEXT_xpix = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_XPIX' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=130+25  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)     
  
WID_LABEL_ypix = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_YPIX' ,XOFFSET=5 ,YOFFSET=130+25+25  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Y Pixels :' ,XSIZE=20 ,YSIZE=3)
  
WID_TEXT_ypix = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_YPIX' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=130+25+25  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
  
WID_LABEL_framemin = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_FRAMEMIN' ,XOFFSET=5 ,YOFFSET=130+25+25+25  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Minimum :' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_framemin = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_FRAMEMIN' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=130+25+25+25  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
  
WID_LABEL_framemax = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_FRAMEMAX' ,XOFFSET=5 ,YOFFSET=130+25+25+25+25  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Maximum :' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_framemax = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_FRAMEMAX' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=130+25+25+25+25  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
                     
;==========
  
W_MENU_file = Widget_Button(WID_BASE_mbar_zmap,  $
  UNAME='W_MENU_FILE' ,/MENU ,VALUE='File')
W_MENU_display = Widget_Button(WID_BASE_mbar_zmap,  $
  UNAME='W_MENU_DISPLAY' ,/MENU ,VALUE='Display')
W_MENU_analysis = Widget_Button(WID_BASE_mbar_zmap,  $
  UNAME='W_MENU_PARAMETERS' ,/MENU ,VALUE='Parameters')
;W_MENU_batch = Widget_Button(WID_BASE_mbar_zmap,  $
;;  UNAME='W_MENU_BATCH' ,/MENU ,VALUE='Batch Processing')
;W_MENU_advance1= Widget_Button(WID_BASE_mbar_zmap,  $
;  UNAME='W_MENU_ANALYSIS' ,/MENU ,VALUE='Analysis')  
      
  
  W_MENU_loadtiff = Widget_Button(W_MENU_file, UNAME='W_MENU_LOADTIFF'  $
    ,VALUE='Open TIFF stacks file')
  W_MENU_loadzmap = Widget_Button(W_MENU_file, UNAME='W_MENU_LOADZMAP'  $
    ,VALUE='Open full data set file (*Zmap.sav)')    
  W_MENU_savezmap = Widget_Button(W_MENU_file, UNAME='W_MENU_SAVEZMAP'  $
    ,VALUE='Save full data set as IDL file (*Zmap.sav) ')    
  W_MENU_savescreentiff = Widget_Button(W_MENU_file, UNAME='W_MENU_SAVESCREENTIFF'  $
    ,VALUE='Save Screenshot as TIFF')
  W_MENU_exportzmap8bit = Widget_Button(W_MENU_file, UNAME='W_MENU_EXPORTZTIFF8'  $
    ,VALUE='Export Z map as 8-bit tiff file (Z range 0-255 nm)')
  W_MENU_exportzmapdouble = Widget_Button(W_MENU_file, UNAME='W_MENU_EXPORTZTIFFDBL'  $
    ,VALUE='Export Z map as 32-bit tiff file')  
;  W_MENU_exportzmap = Widget_Button(W_MENU_file, UNAME='W_MENU_EXPORTZTIFF'  $
;    ,VALUE='Export Z map as text (tab delimited) file')
 
        
W_MENU_autoscale = Widget_Button(W_MENU_display, UNAME='W_MENU_AUTOSCALETIFF'  $
    ,/CHECKED_MENU ,VALUE='Autoscale TIFF Display')
W_MENU_zscale = Widget_Button(W_MENU_display, UNAME='W_MENU_ZSCALE'  $
    ,VALUE='Set Z Color Scale Range')
W_MENU_setpixelsize = Widget_Button(W_MENU_display, UNAME='W_MENU_PIXELSIZE'  $
    ,VALUE='Set Pixel Size (nm)')
W_MENU_scalebar = Widget_Button(W_MENU_display, UNAME='W_MENU_SCALEBAR'  $
    ,VALUE='Show Scale Bar')
    
W_MENU_guessi = Widget_Button(W_MENU_analysis, UNAME='W_MENU_GUESSITERATION'  $
    ,VALUE='Set Number of Guess Iteration')    
W_MENU_guessr = Widget_Button(W_MENU_analysis, UNAME='W_MENU_GUESSMAX'  $
    ,VALUE='Set Upper Limit of Guess Range (nm)')
;W_MENU_mask = Widget_Button(W_MENU_analysis, UNAME='W_MENU_DEFINEMASK'  $
;    ,VALUE='Define Processing Mask')   
W_MENU_maskcode = Widget_Button(W_MENU_analysis, UNAME='W_MENU_MASKCODE'  $
    ,/checked_menu,VALUE='Use Mask instead of Threshold')      
    
;W_MENU_b1 = Widget_Button(W_MENU_batch, UNAME='W_MENU_PRECONVERT'  $
;    ,VALUE='Preconvert Multiple .Tif files')
;W_MENU_b2 = Widget_Button(W_MENU_batch, UNAME='W_MENU_THRESUTIL'  $
;    ,VALUE='Threshold Setting Utility')    
;W_MENU_b3 = Widget_Button(W_MENU_batch, UNAME='W_MENU_DOBATCH'  $
;    ,VALUE='Start Extraction on Multiple *Zmap.sav files')
;    
;W_MENU_a1 = Widget_Button(W_MENU_advance1, UNAME='W_MENU_SETMINSIZE'  $
;    ,VALUE='Set Minimum Region Size for Analysis')
;W_MENU_a2 = Widget_Button(W_MENU_advance1, UNAME='W_MENU_ANA1'  $
;    ,VALUE='Run Analysis')
;W_MENU_a3 = Widget_Button(W_MENU_advance1, UNAME='W_MENU_ANA1SAVE'  $
;    ,VALUE='Export Analysis to file')                      
;        
;====  
WID_slider_frame =   Widget_Slider(WID_BASE_zmap,  $
  UNAME='WID_SLIDER_FRAME' ,XOFFSET=250 ,YOFFSET=5  $
  ,SCR_XSIZE=45 ,SCR_YSIZE=1000 ,TITLE='',MAXIMUM=100,value = 0.,/vertical)
  
WID_slider_top =   Widget_Slider(WID_BASE_zmap,  $
  UNAME='WID_SLIDER_TOP' ,XOFFSET=5 ,YOFFSET=130+25+25+25+25+25  $
  ,SCR_XSIZE=250 ,SCR_YSIZE=45 ,MAXIMUM=32765,value = 0.,title='Top')
  
WID_slider_bottom =   Widget_Slider(WID_BASE_zmap,  $
  UNAME='WID_SLIDER_BOTTOM' ,XOFFSET=5 ,YOFFSET=130+25+25+25+25+25+45  $
  ,SCR_XSIZE=250 ,SCR_YSIZE=45 ,TITLE='Bottom',MAXIMUM=32765,value = 0.)
  
;======
WID_BUTTON_reset = Widget_Button(WID_BASE_zmap,  $
  UNAME='WID_BUTTON_RESET' ,XOFFSET=5 ,YOFFSET=130+25+25+25+25+25+45+60  $
  ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Reset View')
  
WID_DROPLIST_MAP = Widget_Droplist(WID_BASE_zmap,  $
  UNAME='WID_DROPLIST_MAP' ,XOFFSET=5+125+5 ,YOFFSET=130+25+25+25+25+25+45+60+3 ,SCR_XSIZE=125  $
  ,SCR_YSIZE=25 ,VALUE=[ 'Z','Offset','Scaling','Sigma-Z','Sigma-Offset','Sigma-Scaling','Chi Squared'])
  
WID_BUTTON_UnZoom = Widget_Button(WID_BASE_zmap,  $
  UNAME='WID_BUTTON_UNZOOM' ,XOFFSET=5 ,YOFFSET=130+25+25+25+25+25+45+60+35  $
  ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='UnZoomed')
  
WID_BUTTON_Map = Widget_Button(WID_BASE_zmap,  $
  UNAME='WID_BUTTON_MAP' ,XOFFSET=5+125+5 ,YOFFSET=130+25+25+25+25+25+45+60+35  $
  ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='View Map') 
WID_BUTTON_savezMap = Widget_Button(WID_BASE_zmap,  $
  UNAME='WID_BUTTON_SAVEZMAP' ,XOFFSET=5+125+5 ,YOFFSET=130  $
  ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Save *ZMap.sav')   

WID_BUTTON_toggle = Widget_Button(WID_BASE_zmap,  $
  UNAME='WID_BUTTON_SCREENMODE' ,XOFFSET=5+125+5 ,YOFFSET=130+3*30  $
  ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Toggle Raw/Map')     
  
;=============
WID_LABEL_mx = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MX' ,XOFFSET=5 ,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=10 ,SCR_YSIZE=30 ,VALUE='X:' ,XSIZE=20 ,YSIZE=3)  
WID_LABEL_MOUSEX = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MOUSEX' ,XOFFSET=5+20 ,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=40 ,SCR_YSIZE=30 ,VALUE='0000' ,XSIZE=20 ,YSIZE=3) 
WID_LABEL_my = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MY' ,XOFFSET=5+35+30 ,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=10 ,SCR_YSIZE=30 ,VALUE='Y:' ,XSIZE=20 ,YSIZE=3)  
WID_LABEL_MOUSEY = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MOUSEY' ,XOFFSET=5+30+35+20 ,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=40 ,SCR_YSIZE=30 ,VALUE='0000' ,XSIZE=20 ,YSIZE=3) 
WID_LABEL_mz = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MZ' ,XOFFSET=140 ,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=35 ,SCR_YSIZE=20 ,VALUE='Value:' ,XSIZE=20 ,YSIZE=3)  
WID_LABEL_MOUSEz = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_MOUSEZ' ,XOFFSET=180,YOFFSET= 435+100-75  $
  ,SCR_XSIZE=60 ,SCR_YSIZE=20 ,VALUE='0000000' ,XSIZE=20 ,YSIZE=3) 


WID_LABEL_zoommin = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_ZOOMMIN' ,XOFFSET=5 ,YOFFSET= 435+100  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Selection Min: ' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_zoommin = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_ZOOMMIN' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=435+100  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
WID_LABEL_zoommax = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_ZOOMMAX' ,XOFFSET=140 ,YOFFSET= 435+100  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Selection Max: ' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_zoommax = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_ZOOMMAX' ,FRAME=1 ,XOFFSET=220 ,YOFFSET=435+100  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)

WID_LABEL_zoommean = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_ZOOMMEAN' ,XOFFSET=5 ,YOFFSET= 435+25+100 $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Selection Mean: ' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_zoommean = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_ZOOMMEAN' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=435+25+100  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
WID_LABEL_zoomtot = Widget_Label(WID_BASE_zmap,  $
  UNAME='WID_LABEL_ZOOMTOT' ,XOFFSET=140 ,YOFFSET= 435+25+100  $
  ,SCR_XSIZE=75 ,SCR_YSIZE=20 ,VALUE='Selection Sum: ' ,XSIZE=20 ,YSIZE=3)  
WID_TEXT_zoomtot = Widget_Text(WID_BASE_zmap,  $
  UNAME='WID_TEXT_ZOOMTOT' ,FRAME=1 ,XOFFSET=220 ,YOFFSET=435+25+100  $
  ,SCR_XSIZE=50 ,SCR_YSIZE=20 ,/WRAP ,VALUE=['0'] ,XSIZE=20 ,YSIZE=3, /align_right)
  
 WID_BUTTON_PLOTFRAME = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_PLOTFRAME' ,XOFFSET=5 ,YOFFSET=435+25+25+100  $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Plot Selected Properties vs. Frame')
 WID_DROPLIST_Y = Widget_Droplist(WID_BASE_zmap,  $
    UNAME='WID_DROPLIST_Y' ,XOFFSET=5 ,YOFFSET=435+25+25+100+40 ,SCR_XSIZE=200  $
    ,SCR_YSIZE=25 ,TITLE='Properties' ,VALUE=[ 'Mean','Total','Std. Dev.','Min','Max'])
  WID_BUTTON_getstat = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_GETSTAT' ,XOFFSET=5 ,YOFFSET=435+25+25+100+30+30+40  $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Report Stat.of Selected Region')
 
 
   
;=============
 WID_LABEL_title = Widget_Label(WID_BASE_zmap,  $
   UNAME='WID_LABEL_TITLE' ,XOFFSET=1380 ,YOFFSET= 15  $
   ,SCR_XSIZE=250 ,SCR_YSIZE=20 ,VALUE='Excitation Field Parameters: ' ,XSIZE=20 ,YSIZE=3)
   
 wid_base_wavelength = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50, scr_xsize = 240, scr_ysize=80)
 wid_slider_wavelength = cw_fslider(wid_base_wavelength, /DOUBLE,minimum=400., maximum=700.,scroll = 1., $
   title='Excitation Wavelength (nm)',value = 488.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_WAVELENGTH')
   
 wid_base_thick = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+90, scr_xsize = 240, scr_ysize=80)
 wid_slider_thick = cw_fslider(wid_base_thick, /DOUBLE,minimum=0., maximum=3000.,scroll = 1., $
   title='Spacer (Oxide) Thickness (nm)',value = 500.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_THICKNESS')
   
 wid_base_index = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*2, scr_xsize = 240, scr_ysize=80)
 wid_slider_index = cw_fslider(wid_base_index, /DOUBLE,minimum=1., maximum=2.,scroll = .01, $
   title='Spacer (Oxide) Refractive Index',value = 1.4605,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_INDEX')
   
 wid_base_anglemax = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*3, scr_xsize = 240, scr_ysize=80)
 wid_slider_anglemax = cw_fslider(wid_base_anglemax, /DOUBLE,minimum=1., maximum=65.,scroll = .01, $
   title='Maximum Incident Angle (degree)',value = 50.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_ANGLEMAX')
          
  wid_base_angleres = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*4, scr_xsize = 240, scr_ysize=80)
 wid_slider_angleres = cw_fslider(wid_base_angleres, /DOUBLE,minimum=0.5, maximum=10.,scroll = .01, $
   title='Angular Interval (degree)',value = 4.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_ANGLERES')
 
    wid_base_zmax = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*5, scr_xsize = 240, scr_ysize=80)
 wid_slider_zmax = cw_fslider(wid_base_zmax, /DOUBLE,minimum=10, maximum=4000.,scroll = .01, $
   title='Maximum Height above Si (nm)',value = 2500.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_ZMAX')  
   
   wid_base_zres = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*6, scr_xsize = 240, scr_ysize=80)
 wid_slider_zres = cw_fslider(wid_base_zres, /DOUBLE,minimum=0.5, maximum=10.,scroll = .01, $
   title='Height Interval (nm)',value = 2.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_ZRES')
     
 
 wid_base_offset = widget_base(WID_BASE_zmap, xoffset=10, yoffset = 800, scr_xsize = 240, scr_ysize=80)
 wid_slider_offset = cw_fslider(wid_base_offset, /DOUBLE,minimum=0, maximum=2000.,scroll = .01, $
   title='Camera Offset pixel value',value = 100.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_OFFSET')
  wid_base_threshold = widget_base(WID_BASE_zmap, xoffset=10, yoffset = 800+90, scr_xsize = 240, scr_ysize=80)
 wid_slider_offset = cw_fslider(wid_base_threshold, /DOUBLE,minimum=0, maximum=2000.,scroll = 1., $
   title='Minimum mean pixel value cut-off for extraction',value = 200.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_MINVAL')
 WID_BUTTON_threshold = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_THRESHOLD' ,XOFFSET=5 ,YOFFSET=800+90+85  $
    ,SCR_XSIZE=125 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='View Thresholded Data')
  WID_DROPLIST_color = Widget_Droplist(WID_BASE_zmap,  $
    UNAME='WID_DROPLIST_COLOR' ,XOFFSET=5 ,YOFFSET=435+25+25+100+40+30 ,SCR_XSIZE=200  $
    ,SCR_YSIZE=25 ,TITLE='Color Scale' ,VALUE=[ 'Rainbow','#5 Std Gamma II', '#25 Mac Style','Red Temperature # 3','#33 Blue-Red','#34 Rainbow']) 
  WID_BUTTON_GETFIELD = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_FIELD' ,XOFFSET=1330+20 ,YOFFSET=50+(90)*6+80  $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Calculate Excitation Field') 
 wid_base_singlez = widget_base(WID_BASE_zmap, xoffset=1330, yoffset = 50+(90)*6+135, scr_xsize = 240, scr_ysize=80)
 wid_slider_singlez = cw_fslider(wid_base_singlez, /DOUBLE,minimum=0, maximum=1000.,scroll = .01, $
   title='Object Height Z (nm) above spacer',value = 20.,xsize=225,ysize = 80,/edit, uname='WID_SLIDER_SINGLEZ') 
 WID_BUTTON_GETFIELD = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_FIXEDZ' ,XOFFSET=1330+20 ,YOFFSET=50+(90)*6+80+135  $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Field s. Angle at height Z')
 WID_BUTTON_EXTRACTPIX = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_EXTRACTAVG' ,XOFFSET=1330+20 ,YOFFSET= 50+(90)*6+100+80+100 $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Extract Z: Mean Intensity of Selection')
 WID_BUTTON_EXTRACTPIX = Widget_Button(WID_BASE_zmap,  $
    UNAME='WID_BUTTON_EXTRACTPIXZOOM' ,XOFFSET=1330+20 ,YOFFSET=50+(90)*6+40*1+180+100  $
    ,SCR_XSIZE=200 ,SCR_YSIZE=30 ,/ALIGN_CENTER ,VALUE='Extract Z: All Pixels in Selection')
 
  Widget_Control, /REALIZE, WID_BASE_zmap
   XManager, 'WID_BASE_ZMAP', WID_BASE_Zmap, /NO_BLOCK
   
   widget_control,Widget_Info(wid_base_zmap, FIND_BY_UNAME='W_MENU_AUTOSCALETIFF'),set_button=1
    
  
end

pro initializezmap, wWidget
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile
common mouse, mousedown, infoinitial
common analysis, minimumROIsize,labelimage,ROIgroup,anastructarr 

mainwindow= !D.WINDOW
print, 'mainwindow',mainwindow
boxcolor = !D.N_colors-10
info = {image: rawimage, $
    wid:mainwindow, $
    drawID: widget_info(wWidget,find_by_uname='WID_DRAW_MAIN'), $
    pixID:-1, $
    xsize:wxsz, $
    ysize:wysz, $
    sx:-1,$
    sy:-1,$
    boxColor: boxColor}   
infoinitial = info
widget_control, wWidget, set_uvalue =info, /no_copy

print, 'initialized..'
device,decompose=0
loadct, 3

zcolormax = 150.
pixelsizenm = 108.333
guessMaximum=160.
nbuffer = 1.33
nsio2 = 1.4605
nspacer = 1.4605
nsi = 4.5
excitationwavelength = 488.
spacerthickness = 500.
maximumHeight = 3000.
maximumAngle = 60.
angleSpacing = 2.
guessIteration= 10
cameraOffset= 100.
screenmode = 1

zoomcoord = [0,0,4,4]
mapstruct = dblarr(512,512,7)
rawImage = dblarr(256,256,14)
rawMask = bytarr(256,256)
pixelsize = pixelsizenm
timestamp = 0.

maskcode = 0 ; 0 - threshold, 1- use rawMask

minimumROIsize = 5 ; pixels
labelimage = rawMask

end


pro ZMAP, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  
  WID_BASE_zmap, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_

end

pro dialog_event,event
common dialog,selection,fieldid,cho,listid,listindex
on_error,0

; get uvalue of this event
widget_control,event.id,get_uvalue=uvalue

case uvalue of

    'list': begin
        if listindex then selection=event.index else selection=cho(event.index)
        ;; if user double-clicks, then we're done:
        if event.clicks ne 2 then return
    end

    'field': begin
        widget_control,fieldid,get_value=selection
        return
    end

    'buttons': begin
        case 1 of

            ;; field widget?
            widget_info(fieldid,/valid): if (event.value eq 'Cancel') then  $
              selection=event.value else  $
              widget_control,fieldid,get_value=selection

            ;; list widget?
            widget_info(listid,/valid): begin
                if (event.value eq 'Cancel') then begin
                    if listindex then selection=-1 else selection=event.value
                endif else begin
                    id=widget_info(listid,/list_select)
                    if listindex then selection=id else begin
                        if id ge 0 then selection=cho(id) else selection='Cancel'
                    endelse
                endelse
            end

            else: selection=event.value

        endcase
    end

endcase
widget_control,event.top,/destroy
return
end

function dialog,text,buttons=buttons, $
                error=error,warning=warning,info=info,question=question, $
                field=field,float=float,integer=integer, $
                long=long,string=string,value=value, $
                list=list,choices=choices,return_index=return_index, $
                title=title,group=group
common dialog
on_error,2

; set the list and field widget id's to zero, in case
; they've already been defined from a previous instance of dialog.
fieldid=0L
listid=0L
listindex=keyword_set(return_index)

if keyword_set(title) eq 0 then title=' '

; make widget base:
if keyword_set(group) eq 0 then group=0L
if (strmid(!version.release,0,1) eq '5') and $
  widget_info(long(group),/valid) then $
  base=widget_base(title=title,/column,/base_align_center,/modal,group=group) $
else base=widget_base(title=title,/column,/base_align_center)

if keyword_set(float) then field=1
if keyword_set(integer) then field=1
if keyword_set(long) then field=1
if keyword_set(string) then field=1
if n_elements(value) eq 0 then value=0
if n_elements(choices) gt 0 then list=1

; widget configuration depends on type of dialog:
case 1 of
    keyword_set(error):begin
        if n_params() eq 0 then text='Error' else $
          text='Error: '+text
        label=widget_label(base,value=text,frame=0)
        if keyword_set(buttons) eq 0 then buttons=['Abort','Continue']
    end
    keyword_set(warning):begin
        if n_params() eq 0 then text='Warning' else $
          text='Warning: '+text
        label=widget_label(base,value=text,frame=0)
        if keyword_set(buttons) eq 0 then buttons=['OK']
    end
    keyword_set(info):begin
        if n_params() eq 0 then text=' '
        label=widget_label(base,value=text,frame=0)
        if keyword_set(buttons) eq 0 then buttons=['Cancel','OK']
    end
    keyword_set(question):begin
        if n_params() eq 0 then text='Question?'
        label=widget_label(base,value=text,frame=0)
        if keyword_set(buttons) eq 0 then buttons=['Cancel','No','Yes']
    end
    keyword_set(field):begin
        isfield=1
        if n_params() eq 0 then text='Input: '
        sz=size(value)
        if keyword_set(string) and (sz(1) ne 7) then value=strtrim(value)
        fieldid=cw_field(base,title=text, $
                       uvalue='field', $
                       value=value, $
                       /return_events, $
                       float=keyword_set(float), $
                       integer=keyword_set(integer), $
                       long=keyword_set(long), $
                       string=keyword_set(string))
        buttons=['Cancel','OK']
    end
    keyword_set(list):begin
        if keyword_set(choices) eq 0 then $
          message,'Must supply an array of choices for the list.'
        cho=choices
        if n_params() eq 0 then text='Choose: '
        label=widget_label(base,value=text,frame=0)
        listid=widget_list(base,value=choices, $
                           ysize=n_elements(choices) < 10, $
                           uvalue='list')
        buttons=['Cancel','OK']
        cho=choices             ; set common variable for event handler.
    end
endcase
; make widget buttons:
bgroup=cw_bgroup(base,/row,buttons,uvalue='buttons',/return_name)

; realize widget:
widget_control,base,/realize

; manage widget:
if (strmid(!version.release,0,1) eq '5') and  $
  widget_info(long(group),/valid) then $
  xmanager,'dialog',base,group=group  $
else xmanager,'dialog',base,/modal

; return selection:
return,selection
end