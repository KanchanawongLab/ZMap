pro zmap_eventcb, event
end

function AddExtension, filename, extension    ; checks if the filename has the extension (caracters after dot in "extension" variable. If it does not, adds the extension.
sep = !VERSION.OS_family eq 'unix' ? '/' : '\'
dot_pos=strpos(extension,'.',/REVERSE_OFFSET,/REVERSE_SEARCH)
short_ext=strmid(extension,dot_pos)
short_ext_pos=strpos(filename,short_ext,/REVERSE_OFFSET,/REVERSE_SEARCH)
ext_pos=strpos(filename,extension,/REVERSE_OFFSET,/REVERSE_SEARCH)
add_ext=(ext_pos lt 0)  ? extension : ''
file_sep_pos=strpos(filename,sep,/REVERSE_OFFSET,/REVERSE_SEARCH)
file_dot_pos=strpos(filename,'.',/REVERSE_OFFSET,/REVERSE_SEARCH)
filename_without_ext = (file_dot_pos gt file_sep_pos) ? strmid(filename,0,file_dot_pos) :  filename
filename_with_ext = (ext_pos gt 0) ? filename : (filename_without_ext + add_ext)
return,filename_with_ext
end

pro adjustcontrast,event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode

screenmode = 0
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),get_value=frame
im = rawImage[*,*,(frame<numberofframes)-1]
;help, im
tvscl, bytarr(wxsz,wysz)
;xdim = dimension[0]
;ydim = dimension[1]
;mgw = fix((wxsz/xdim)<(wysz/ydim))

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]
xdim = xmax-xmin+1 & ydim = ymax-ymin+1
mgw = fix((wxsz/xdim)<(wysz/ydim))

;print, mgw
print, [xmin,ymin, xmax,ymax]
zoomim = im[xmin:xmax,ymin:ymax]
immin = min(zoomim,max = immax)
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FRAMEMIN'),set_value=strtrim(string(immin,format='(3I)'),2)  
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FRAMEMAX'),set_value=strtrim(string(immax,format='(3I)'),2)
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_BOTTOM'),get_value=bottom
  widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_TOP'),get_value=top
  if bottom gt top then begin
    bottom = top
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_BOTTOM'),set_value=bottom  
  end

device,decompose=0
;loadct,3 
imscl = congrid(zoomim,mgw*xdim,mgw*ydim)   
imscl = bytscl(imscl,min=bottom,max=top)
tv,imscl
end
;
;pro viewmask, event
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask, maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;xmin = zoomcoord[0] & ymin = zoomcoord[1]
;xmax = zoomcoord[2] & ymax = zoomcoord[3]
;xdim = xmax-xmin+1 & ydim = ymax-ymin+1
;mgw = fix((wxsz/xdim)<(wysz/ydim))
;
;tv, bytarr(wxsz,wysz)
;
;if total(rawMask) eq 0 then rawMask = bytarr(dimension[0],dimension[1])
;print, xmin, xmax, ymin, ymax
;tv, congrid(bytscl(rawMask[xmin:xmax,ymin:ymax], min =0, max = 1),mgw*xdim,mgw*ydim)
;
;numpix = total(rawMask[xmin:xmax,ymin:ymax])
;timeest = 0.07*numpix/60.
;st2 = 'Estimated time = '+string(timeest,format='(F10.3)')+' minutes'
;xyouts, 0.1, 0.85,st2, charsize = 2, /normal, color=cgcolor('red')
;end
;
;pro regionpropz, event
;  common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;  common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;  common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;  common heightmap, mapStruct, pixelsize, timestamp, mapfile
;  common analysis, minimumROIsize,labelimage,ROIgroup,anastructarr 
;  
;  ;minimumROIsize = 15
;  zmap = mapstruct[*,*,0]
;  szmap = mapstruct[*,*,3]
;  omap = mapstruct[*,*,1]
;  smap  = mapstruct[*,*,2]
;  binmask = (zmap gt 0)
;  labelimage = LABEL_REGION( binmask, /ALL_NEIGHBORS)
;  
;  loadct, 3
;  tvscl, congrid(labelimage,wxsz, wysz)
;  
;  numregion = max(labelimage)
; ; print, numregion
;  
;  for i = 0, numregion-1 do begin
;    ind = where(labelimage eq i, count)
;    if count lt minimumROIsize then labelimage[ind] = 0         
;  endfor
;  
;  labelimage = LABEL_REGION( (labelimage gt 0), /ALL_NEIGHBORS)
;  tvscl, congrid(labelimage,wxsz, wysz)
;  numregion = max(labelimage)
;  print, numregion
;  
;  anastructarr = dblarr(numregion,11)
;  for i = 0, numregion-1 do begin
;    ind = where(labelimage eq i, count)
;    ind2d = array_indices(labelimage,ind)
;    ;print, ind2d
;    thisroi = bytarr(dimension[0],dimension[1])
;    thisroi[ind2d[0,*],ind2d[1,*]]= 1
;    tvscl, congrid(thisroi,wxsz, wysz)
;    
;    box = createboxplotdata(reform(zmap[ind]),outlier_values=xx,suspected_outlier_values=yy)
;    ;print, mean(szmap[ind2d[0,*],ind2d[1,*]])
;    result = {numberofpixels: count, meanz: mean(zmap[ind2d[0,*],ind2d[1,*]]), medianz:  median(zmap[ind2d[0,*],ind2d[1,*]]), maxz:  max(zmap[ind2d[0,*],ind2d[1,*]]), $
;        minz: min(zmap[ind2d[0,*],ind2d[1,*]]), stdevz: stddev(zmap[ind2d[0,*],ind2d[1,*]]), meansigmaz: mean(szmap[ind2d[0,*],ind2d[1,*]]), meanoffset: mean(omap[ind2d[0,*],ind2d[1,*]]), $
;        meanscaling: mean(smap[ind2d[0,*],ind2d[1,*]]), q1z: box[1], q3z: box[3] }
;    anastructarr[i,0] = result.numberofpixels
;    anastructarr[i,1] = result.meanz
;    anastructarr[i,2] = result.stdevz
;    anastructarr[i,3] = result.minz
;    anastructarr[i,4] = result.q1z
;    anastructarr[i,5] = result.medianz
;    anastructarr[i,6] = result.q3z
;    anastructarr[i,7] = result.maxz
;    anastructarr[i,8] = result.meansigmaz
;    anastructarr[i,9] = result.meanoffset
;    anastructarr[i,9] = result.meanscaling     
;  endfor
;  
;  boxes = BOXPLOT(indgen(numregion),anastructarr[*,3:7],yrange=[0,zcolormax],xrange=[0,numregion],xtitle='Region #',ytitle= 'Z position (nm)')
;  boxes.color = 'gray'
;  boxes.fill_color = 'red'
;  boxes.lower_color='blue'
;  
;  cgboxplot, anastructarr[0:28,3:7],yrange = [0,zcolormax],xtitle='Region #',ytitle= 'Z position (nm)',/fillboxes,boxcolor = 'crimson'
;end

;pro exportregionpropz, event
;  common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;  common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;  common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;  common heightmap, mapStruct, pixelsize, timestamp, mapfile
;  common analysis, minimumROIsize,labelimage,ROIgroup,anastructarr 
;
;  filename = Dialog_Pickfile(/write,get_path=fpath,filter=['*.txt'],title='Exporting data to *.txt tab-delimited text file')
;  
;  if strlen(fpath) ne 0 then cd,fpath
;  if filename eq '' then return
;  exfile=AddExtension(filename,'_Zmapregion.txt')
;  
;  fieldname=['NumberOfPixels','MeanZ','StDevZ','MinZ','Quartile1Z','MedianZ','Quartile3Z','MaxZ','MeanSigmaZ','MeanOffset','MeanScaling']
;  Title_String = fieldname[0]
;  for i=1,10 do Title_String=Title_String+' '+string(9B)+' '+fieldname[i]
;  openw,1,exfile,width=1024
;  printf,1,Title_String
;  printf,1,anastructarr,FORMAT='('+strtrim((10),2)+'(E13.5,"'+string(9B)+'"),E13.5)'
;  close,1
;
;
;end


pro viewthreshold,event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

screenmode = 0
displaytiff, event
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_MINVAL'),get_value=threshold

meanImage = mean(rawImage, dimension=3)
imscl = congrid(bytscl(meanImage,min=bottom,max=top),wxsz,wysz)
tv,imscl

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]
xdim = xmax-xmin+1 & ydim = ymax-ymin+1
mgw = fix((wxsz/xdim)<(wysz/ydim))

binmask = (meanImage[xmin:xmax,ymin:ymax] gt threshold)
;rawMask[xmin:xmax,ymin:ymax] = binMask
numpix = total(binmask)
tv, congrid(bytscl(binmask, min =0, max = 1),mgw*xdim,mgw*ydim)
st1 = 'Threshold = '+string(threshold,format='(F9.3)')+'  Number of Pixels: '+string(numpix, format='(F9.3)')
timeest = 0.07*numpix/60.
st2 = 'Estimated time = '+string(timeest,format='(F10.3)')+' minutes'
xyouts, 0.1, 0.9,st1, charsize = 2, /normal, color=cgcolor('red')
xyouts, 0.1, 0.85,st2, charsize = 2, /normal, color=cgcolor('red')
end

pro loadsav4batch, event, filename
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

if strpos(filename,'Zmap.sav') ne -1 then restore,filename=filename else return
mapfile = filename
setparam,event
zoomcoord= [ 0, 0,dimension[0]-1,dimension[1]-1]
displaymap, event 

end

pro quicksavesav, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

if dataFile eq '' then return

if mapfile eq '' then filename = dataFile else filename = mapfile

filename=AddExtension(filename,'_Zmap.sav')
readparam,event

save, datafile, numberofframes, dimension, rawImage, rawMask, maskCode, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum, $
  mapStruct, pixelsize, timestamp, filename = filename

widget_control,Widget_Info(Event.Top, find_by_uname='WID_TEXT_FILENAME'),set_value=filename

end

pro saveztiff, event
  common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
  common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
  common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
  common heightmap, mapStruct, pixelsize, timestamp, mapfile
  
filename = dataFile
defaultname=AddExtension(filename,'_Zmap.tif')

filename = Dialog_Pickfile(/write,get_path=fpath,file=defaultname, filter=['*Zmap.tif'],title='Save Z map as  *Zmap.tif file (range limited to 0-255 nm)')
if filename eq '' then return

cd,fpath
mapfile=AddExtension(filename,'_Zmap.tif')

print, mapfile

imclip = (fix(mapstruct[0:dimension[0]-1,0:dimension[1]-1,0])>0)<255

WRITE_TIFF, mapfile, imclip , BITS_PER_SAMPLE=8, COMPRESSION=0, DESCRIPTION='Zmap of'+dataFile,orientation = 0

end

pro saveztiffdbl, event
  common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
  common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
  common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
  common heightmap, mapStruct, pixelsize, timestamp, mapfile
  
  filename = dataFile
  defaultname=AddExtension(filename,'_Zmap.tif')
  
  filename = Dialog_Pickfile(/write,get_path=fpath,file=defaultname, filter=['*Zmap.tif'],title='Save Z map as  *Zmap.tif file (range limited to 0-255 nm)')
  if filename eq '' then return
  
  cd,fpath
  mapfile=AddExtension(filename,'_Zmap.tif')
  
  print, mapfile
  
  im = mapstruct[0:dimension[0]-1,0:dimension[1]-1,0]
  
  WRITE_TIFF, mapfile, im , /float, COMPRESSION=0, DESCRIPTION='Zmap of'+dataFile,orientation = 0
  
end

;
;pro savesav4batch, event, filename
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;save, datafile, numberofframes, dimension, rawImage, rawMask, maskCode, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum, $
;  mapStruct, pixelsize, timestamp, filename = filename
;widget_control,Widget_Info(Event.Top, find_by_uname='WID_TEXT_FILENAME'),set_value=filename
;
;print, 'Save files to: ', filename
;
;end
;
;function loadtiff4batch, event, filename
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;dataFile = filename
;if dataFile eq '' then return, -1
;;
;rawImage = readtiffstack(dataFile)
;timestamp = (file_info(dataFile)).atime
;;help, result
;;Widget_Control, event.top, Get_UValue=info, /No_Copy
;;info.pixID = -1
;;widget_control, event.top, set_uvalue=info,/no_copy
;
;case size(rawImage,/n_dimensions) of 
;  2: begin
;    dimension = size(rawImage,/dimensions)
;    numberofframes = 1
;    ;print, dimension
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FILENAME'),set_value=dataFile
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)  
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
;          
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=1
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1
;    zoomcoord = [0,0,dimension[0]-1,dimension[1]-1]
;    displaytiff, event 
;    ;updateselection, event
;    pixelsize = pixelsizenm
;    return, -1
;  end
;  3: begin
;    dimension = size(rawImage,/dimensions)
;    numberofframes = dimension[2]
;    dimension = dimension[0:1]
;    print, dimension
;    print, numberofframes
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FILENAME'),set_value=dataFile 
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)   
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
;    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
;    ;displaytiff, event       
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=numberofframes
;    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1
;    zoomcoord = [0,0,dimension[0]-1,dimension[1]-1]
;    mapstruct = dblarr(dimension[0],dimension[1],7)
;    rawMask = bytarr(dimension[0],dimension[1])
;    displaytiff, event 
;    ;updateselection, event
;    pixelsize = pixelsizenm
;    return, 1
;  end
;endcase
;return, -1
;end


pro loadsav, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

filename = Dialog_Pickfile(/read,get_path=fpath,filter=['*Zmap.sav'],title='Select *Zmap.sav file to open')
if filename eq '' then begin
  print,'filename not recognized', filename
  return
endif

cd,fpath
print,'opening file: ', filename
if strpos(filename,'Zmap.sav') ne -1 then restore,filename=filename else begin
  print, 'Incorrect filetype'
  return
end
mapfile = filename
widget_control,Widget_Info(Event.Top, find_by_uname='WID_TEXT_FILENAME'),set_value=filename
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),set_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),set_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),set_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),set_value=maximumAngle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),set_value=Zmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZRES' ),set_value=resz
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),set_value=angleSpacing
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),set_value=cameraOffset
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_MINVAL' ),set_value=threshold

widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)   
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
   
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=numberofframes
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1

zoomcoord= [ 0, 0,dimension[0]-1,dimension[1]-1]
displaymap, event    
end

pro savesav,event
  common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
  common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
  common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
  common heightmap, mapStruct, pixelsize, timestamp, mapfile
  
  filename = Dialog_Pickfile(/write,get_path=fpath,file=ref_file, filter=['*Zmap.sav'],title='Save full data set *Zmap.sav file')
  if filename eq '' then return
  
  cd,fpath
  mapfile=AddExtension(filename,'_Zmap.sav')
  
  save, datafile, numberofframes, dimension, rawImage, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
    maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum, $
    mapStruct, pixelsize, timestamp, filename = mapfile
    
  widget_control,Widget_Info(Event.Top, find_by_uname='WID_TEXT_FILENAME'),set_value=mapfile
end

;
;pro getstat, event
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;colortable = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_COLOR'),/droplist_select)
;;[ 'Rainbow','#5 Std Gamma II', '#25 Mac Style','Red Temperature # 3','#33 Blue-Red','#34 Rainbow']
;case colortable of
;  0: ct = 13
;  1: ct = 5
;  2: ct = 25
;  3: ct = 3
;  4: ct = 33
;  5: ct = 34
;  else: ct = 13
;endcase
;maxmap = zcolormax & minmap = 0
;
;xmin = zoomcoord[0] & ymin = zoomcoord[1]
;xmax = zoomcoord[2] & ymax = zoomcoord[3]
;xdim = xmax-xmin+1 & ydim = ymax-ymin+1
;mgw = fix((wxsz/xdim)<(wysz/ydim))
;wset, mainwindow
;tvscl, bytarr(wxsz, wysz)
;subset = mapstruct[xmin:xmax,ymin:ymax,*]
;nonzeros = where(subset[*,*,0] ne 0, totpix)
;print, totpix
;if totpix lt 1 then begin  
;  xyouts, 0.1,0.5,'No Valid Pixels...',charsize = 3,/normal
;  print, 'No Valid Pixel'
;  return
;end 
;
;z = subset[*,*,0] & sz = subset[*,*,3]
;offset =  subset[*,*,1] & soffset = subset[*,*,4]
;sc =  subset[*,*,2] & ssc = subset[*,*,5]
;chisq =  subset[*,*,6] 
;
;nonz = where(z ne 0)
;averagez = mean(z[nonz]) & stddevz = stddev(z[nonz]) & minz = min(z[nonz],max = maxz)
;averageo = mean(offset[nonz]) & stddevo = stddev(offset[nonz]) & mino = min(offset[nonz],max = maxo)
;averages = mean(sc[nonz]) & stddevs = stddev(sc[nonz]) & mins = min(sc[nonz],max = maxs)
;averagec = mean(chisq[nonz]) & stddevc = stddev(chisq[nonz]) & minc = min(chisq[nonz],max = maxc)
;averagesz = mean(sz[nonz]) & stddevsz = stddev(sz[nonz]) & minsz = min(sz[nonz],max = maxsz)
;
;znz =z[nonz]
;sznz =sz[nonz]
;;print, z[nonz]
;print, averagez, stddevz, minz, maxz
;print, averageo, stddevo, mino, maxo
;print, averages, stddevs, mins, maxs
;print, averagec, stddevc, minc, maxc
;
;st1 = 'File name:'+dataFile
;st2 = 'Number of pixels:'+string(totpix,format='(I8)')
;st3 = 'timestamp: '
;st4 = 'Average Z :'+string(averagez, format='(F10.3)')+' nm st-dev: '+string(stddevz, format='(F10.3)')+' nm min :'+string(minz, format='(F10.3)')+' nm max: '+string(maxz, format='(F10.3)')
;st5 = 'Average Sigma Z :'+string(averagesz, format='(F10.3)')+' nm st-dev: '+string(stddevsz, format='(F10.3)')+' nm min :'+string(minsz, format='(F10.3)')+' nm max: '+string(maxsz, format='(F10.3)')
;st6 = 'Average Offset :'+string(averageo, format='(F10.3)')+' st-dev: '+string(stddevo, format='(F10.3)')+' min :'+string(mino, format='(F10.3)')+' max: '+string(maxo, format='(F10.3)')
;st7 = 'Average Scaling :'+string(averages, format='(F10.3)')+' st-dev: '+string(stddevs, format='(F10.3)')+' min :'+string(mins, format='(F10.3)')+' max: '+string(maxs, format='(F10.3)')
;st8 = 'Average Chi Sq :'+string(averagec, format='(F10.3)')+' st-dev: '+string(stddevc, format='(F10.3)')+' min :'+string(minc, format='(F10.3)')+' max: '+string(maxc, format='(F10.3)')
;st9 = 'Average Z :'+string(averagez, format='(F10.3)')+' nm Median Z : '+string(median(z[nonz]), format='(F10.3)')
;map = mapstruct[xmin:xmax,ymin:ymax,0]
;loadct,ct
;cgImage, bytscl(map,min=minmap,max=maxmap), position=[0.05,0.55,0.45,0.95]
;cgColorbar , POSITION=[0.1,0.97,0.4,0.995],RANGE=[minmap,maxmap]  ,annotatecolor='white'
;loadct,3
;plot,[0,0],[0.,0],/noerase,position=[0.05,0.55,0.45,0.95],/normal,xstyle=1, ystyle=1, xrange=[xmin, xmax],yrange=[ymin,ymax], $
;  xtitle='X pixel',ytitle='Y pixel',charsize = 1 ;,title = 'Height above oxide (spacer) layer (nm)'
;xyouts, 0.0125,0.9825, 'Z',/normal, charsize = 1.25
;
;cghistoplot, znz, locations = zloc, binsize = 1.0, xtitle = 'Z (nm)', ytitle = '#',mininput = 0, maxinput = zcolormax, $
;          position = [0.05,0.05,0.45,0.45], title = 'Z ', noerase=1,color=cgcolor('red')
;
;cghistoplot, sznz, locations = zloc, xtitle = 'sigma Z (nm)', ytitle = '#', $
;          position = [0.05+0.5,0.05,0.45+0.5,0.45], title = 'sigma Z ', noerase=1,color=cgcolor('steel blue')
;
;l = 0.035
;dx =0.02
;xyouts, 0.5-dx, 0.95-0*l,st1,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-1*l,st2,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-2*l,st3,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-3*l,st4,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-4*l,st5,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-5*l,st6,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-6*l,st7,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-7*l,st8,/normal,charsize = 0.9
;xyouts, 0.5-dx, 0.95-9*l,st9,/normal,charsize = 1.25,color=cgcolor('yellow')          
;end

;pro preconverttiff, event
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;readparam, event
;filename = Dialog_Pickfile(/read,/directory,get_path=fpath,title='Select directory of .Tif raw data to preconvert to *Zmap.sav')
;if filename eq '' then return
;cd, fpath
;result = file_search(filename,'*.tif',/fold_case)
;;help, result
;numfiles = n_elements(result)
;if (numfiles eq 1) and (result[1] eq '' )then begin
;  print, 'No Files Found..'
;  return
;end
;print, 'Total TIF files found',numfiles
;;print, result
;for i = 0, numfiles-1 do begin
;  newname = addextension(result[i],'_Zmap.sav')
;  print,'Source: ',result[i],' Target: ',newname
;  loadtiffflag = loadtiff4batch(event, result[i])
;  if loadtiffflag ge 1 then begin
;      print, 'Export to : ',newname
;      savesav4batch, event, newname
;  endif else print, 'Problem loading file: ',result[i]
;end
;print, 'finish preconversion..',numfiles,' files'
;
;end
;
;pro checkbatch, event
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;filename = Dialog_Pickfile(/read,/directory,get_path=fpath,title='Select a directory of _Zmap.sav files')
;if filename eq '' then return
;cd, fpath
;result = file_search(filename,'*Zmap.sav',/fold_case)
;;help, result
;numfiles = n_elements(result)
;if (numfiles eq 1) and (result[1] eq '' )then begin
;  print, 'No Files Found..'
;  return
;end
;print, 'Total Zmap.sav files found',numfiles
;filenumber = numfiles
;filelist = result
;
;timebegin = systime(/seconds)
;
;for i = 0, numfiles-1 do begin
;  print, 'Processing: ',filelist[i]
;  tvscl,bytarr(wxsz,wysz)
;  xyouts, 0.05, 0.5,'Processing: '+filelist[i],/normal
;  xyouts, 0.05, 0.48,'File: '+string(i+1)+' / '+string(numfiles),/normal
;  xyouts, 0.05, 0.46, 'time since beginning: '+string(systime(/seconds)-timebegin)+' seconds',/normal
;  loadsav4batch, event, filelist[i]
;
;endfor
;tottime = systime(/seconds)-timebegin
;xyouts, 0.05,0.05,' Elapsed time: '+string(tottime),/normal
;print,' Elapsed time: ',tottime
;end
;
;pro batchextraction, event
;common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
;common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
;  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
;common heightmap, mapStruct, pixelsize, timestamp, mapfile
;
;filename = Dialog_Pickfile(/read,/directory,get_path=fpath,title='Select a directory of _Zmap.sav files')
;if filename eq '' then return
;cd, fpath
;result = file_search(filename,'*Zmap.sav',/fold_case)
;;help, result
;numfiles = n_elements(result)
;if (numfiles eq 1) and (result[1] eq '' )then begin
;  print, 'No Files Found..'
;  return
;end
;print, 'Total Zmap.sav files found',numfiles
;filenumber = numfiles
;filelist = result
;
;timebegin = systime(/seconds)
;
;for i = 0, numfiles-1 do begin
;  print, 'Processing: ',filelist[i]
;  tvscl,bytarr(wxsz,wysz)
;  xyouts, 0.05, 0.5,'Processing: '+filelist[i],/normal
;  xyouts, 0.05, 0.48,'File: '+string(i+1)+' / '+string(numfiles),/normal
;  xyouts, 0.05, 0.46, 'time since beginning: '+string(systime(/seconds)-timebegin)+' seconds',/normal
;  loadsav4batch, event, filelist[i]
;  extractzpixzoom, event
;  savesav4batch, event,filelist[i]
;  
;endfor
;tottime = systime(/seconds)-timebegin
;xyouts, 0.05,0.05,' Elapsed time: '+string(tottime),/normal
;print,' Elapsed time: ',tottime
;
;end

pro readparam,event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_MINVAL'),get_value=threshold
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),get_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),get_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),get_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),get_value=maximumAngle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),get_value=maximumHeight
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),get_value=angleSpacing
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),get_value=cameraOffset
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_MINVAL' ),get_value=threshod
end

pro setparam,event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_MINVAL'),set_value=threshold
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),set_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),set_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),set_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),set_value=maximumAngle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),set_value=maximumHeight
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),set_value=angleSpacing
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),set_value=cameraOffset
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_MINVAL' ),set_value=threshold

widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)   
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
   
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=numberofframes
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1

end


pro displaymap, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common heightmap, mapStruct, pixelsize, timestamp, mapfile

screenmode = 1
colortable = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_COLOR'),/droplist_select)
;[ 'Rainbow','#5 Std Gamma II', '#25 Mac Style','Red Temperature # 3','#33 Blue-Red','#34 Rainbow']
case colortable of
  0: ct = 13
  1: ct = 5
  2: ct = 25
  3: ct = 3
  4: ct = 33
  5: ct = 34
  else: ct = 13
endcase

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]
xdim = xmax-xmin+1 & ydim = ymax-ymin+1
mgw = fix((wxsz/xdim)<(wysz/ydim))

print, xmin, xmax, ymin, ymax
;help, mapstruct

wset, mainwindow
maptype = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_MAP'),/droplist_select)
case maptype of
  0: begin
      map = mapstruct[xmin:xmax,ymin:ymax,0]
      st = 'Z' &  maxmap = zcolormax & minmap = 0
     end
  1: begin
      map = mapstruct[xmin:xmax,ymin:ymax,1]
      st = 'Offset' & maxmap = max(map, min = minmap)
     end
  2: begin
        map = mapstruct[xmin:xmax,ymin:ymax,2]
        st = 'Scaling'& maxmap = max(map, min = minmap)
     end
  3: begin
        map = mapstruct[xmin:xmax,ymin:ymax,3]
        st = 'Sigma Z'& maxmap = max(map, min = minmap)
     end
  4: begin
        map = mapstruct[xmin:xmax,ymin:ymax,4]
        st = 'Sigma Offset'& maxmap = max(map, min = minmap)
     end
  5: begin
        map = mapstruct[xmin:xmax,ymin:ymax,5]
        st = 'Sigma Scaling'& maxmap = max(map, min = minmap)
     end
  6: begin
        map = mapstruct[xmin:xmax,ymin:ymax,6]
        st = 'Chi Squared'& maxmap = max(map, min = minmap)
     end
  else: begin
          map = mapstruct[xmin:xmax,ymin:ymax,0]
          st = 'Z'& maxmap = zcolormax & minmap = 0
        end
endcase

tvscl, bytarr(wxsz,wysz)
loadct,ct
cgImage, bytscl(map,min=minmap,max=maxmap), position=[0.1,0.1,0.9,0.9]
cgColorbar , POSITION=[0.25,0.93,0.75,0.97],RANGE=[minmap,maxmap]  ,annotatecolor='white'
loadct,3
plot,[0,0],[0.,0],/noerase,position=[0.1,0.1,0.9,0.9],/normal,xstyle=1, ystyle=1, xrange=[xmin, xmax],yrange=[ymin,ymax], $
  xtitle='X pixel',ytitle='Y pixel',charsize = 2 ;,title = 'Height above oxide (spacer) layer (nm)'
xyouts, 0.025,0.937, st,/normal, charsize = 2.5


end

pro displaytiff, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode

if datafile eq '' then begin
  print, 'Load Data first'
  return
end

wset, mainwindow
screenmode = 0
widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),get_value=frame
im = rawImage[*,*,(frame<numberofframes)-1]

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]
xdim = xmax-xmin+1 & ydim = ymax-ymin+1
mgw = fix((wxsz/xdim)<(wysz/ydim))

;print, [xmin,ymin, xmax,ymax]
;help, im
zoomim = im[xmin:xmax,ymin:ymax]

zoommin = min(zoomim, max= zoommax)
zoommean = mean(zoomim)
zoomtot = total(zoomim)

tvscl, bytarr(wxsz,wysz)
immin = min(im,max = immax)
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FRAMEMIN'),set_value=strtrim(string(immin,format='(3I)'),2)  
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FRAMEMAX'),set_value=strtrim(string(immax,format='(3I)'),2)

widget_control,widget_info(event.top,find_by_uname='WID_TEXT_ZOOMMIN'),set_value=strtrim(string(zoommin,format='(3I)'),2)
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_ZOOMMAX'),set_value=strtrim(string(zoommax,format='(3I)'),2)
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_ZOOMMEAN'),set_value=strtrim(string(zoommean,format='(3I)'),2)
widget_control,widget_info(event.top,find_by_uname='WID_TEXT_ZOOMTOT'),set_value=strtrim(string(zoomtot,format='(3I)'),2)

loadct,3 
;print, mgw
imscl = congrid(zoomim,mgw*xdim,mgw*ydim) 
if autoscale ne 0 then begin
  tvscl, imscl
  widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_BOTTOM'),set_value=immin
  widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_TOP'),set_value=immax 
endif else begin
  widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_BOTTOM'),get_value=bottom
  widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_TOP'),get_value=top
  if bottom gt top then begin
    bottom = top
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_BOTTOM'),set_value=bottom  
  end
  imscl = bytscl(imscl,min=bottom,max=top)
  tv,imscl
end

end
;
pro plotselection, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode

screenmode = 1
xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]

tvscl, bytarr(wxsz,wysz)
y = dblarr(numberofframes)
fr = indgen(numberofframes)+1
case widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_Y'),/droplist_select) of 
  0: begin
        for index = 0L, numberofframes-1 do begin
          zoomim = rawImage[xmin:xmax,ymin:ymax,index]
          y[index] = mean(zoomim)
        endfor
        rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]
        plot,  fr, y, xstyle =1,yrange = yrange, title='mean vs. frame', xtitle = 'frame', ytitle = 'mean of frame'
     end
  1: begin
        for index = 0L, numberofframes-1 do begin
          zoomim = rawImage[xmin:xmax,ymin:ymax,index]
          y[index] = total(zoomim)
        endfor
        rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]
        plot,  fr, y, xstyle =1,yrange = yrange, title='total vs. frame', xtitle = 'frame', ytitle = 'total of frame'
     end
  2: begin
        for index = 0L, numberofframes-1 do begin
          zoomim = rawImage[xmin:xmax,ymin:ymax,index]
          y[index] = stddev(zoomim)
        endfor
        rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]
        plot,  fr, y, xstyle =1,yrange = yrange, title='std. dev. vs. frame', xtitle = 'frame', ytitle = 'std.dev. of frame'
     end
  3: begin
        for index = 0L, numberofframes-1 do begin
          zoomim = rawImage[xmin:xmax,ymin:ymax,index]
          y[index] = min(zoomim)
        endfor
        rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]
        plot,  fr, y, xstyle =1,yrange = yrange, title='min vs. frame',xtitle = 'frame', ytitle = 'min of frame'
     end
  4: begin
        for index = 0L, numberofframes-1 do begin
          zoomim = rawImage[xmin:xmax,ymin:ymax,index]
          y[index] = max(zoomim)
        endfor
        rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]
        plot,  fr, y, xstyle =1,yrange = yrange, title='max vs. frame',xtitle = 'frame', ytitle = 'max of frame'
     end
  else: 
endcase
end

pro loadtiff, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common heightmap, mapStruct, pixelsize, timestamp, mapfile
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
  
dataFile = Dialog_Pickfile(/read,get_path=fpath,filter=['*.tif','*.tiff'],title='Select *.tif file to open')

if dataFile eq '' then return

cd, fpath
;
rawImage = readtiffstack(dataFile)
timestamp = (file_info(dataFile)).atime
;help, result
Widget_Control, event.top, Get_UValue=info, /No_Copy
info.pixID = -1
widget_control, event.top, set_uvalue=info,/no_copy


case size(rawImage,/n_dimensions) of 
  2: begin
    dimension = size(rawImage,/dimensions)
    numberofframes = 1
    print, dimension
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FILENAME'),set_value=dataFile
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)  
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
          
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=1
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1
    zoomcoord = [0,0,dimension[0]-1,dimension[1]-1]
    displaytiff, event 
    ;updateselection, event
    pixelsize = pixelsizenm
  end
  3: begin
    dimension = size(rawImage,/dimensions)
    numberofframes = dimension[2]
    dimension = dimension[0:1]
    print, dimension
    print, numberofframes
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_FILENAME'),set_value=dataFile 
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_XPIX'),set_value=strtrim(string(dimension[0],format='(3I)'),2)   
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_YPIX'),set_value=strtrim(string(dimension[1],format='(3I)'),2)   
    widget_control,widget_info(event.top,find_by_uname='WID_TEXT_TOTALFRAME'),set_value=string(numberofframes)
    ;displaytiff, event       
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_value=1
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_max=numberofframes
    widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_FRAME'),set_slider_min=1
    zoomcoord = [0,0,dimension[0]-1,dimension[1]-1]
    mapstruct = dblarr(dimension[0],dimension[1],7)
    displaytiff, event 
    ;updateselection, event
    pixelsize = pixelsizenm
  end
endcase

end



function readtiffstack,imagefile,rect=rect,start_frame=start_frame, $
   stop_frame=stop_frame
;readtiffstack.pro
;Eric Corwin
;Monday, November 20
;a function to read in a tiff stack into a single variable

;imagefile is the file to be read
;rect is the rectangular region of the image to be read. It has the form
;[x,y,width,height] measured in pixels from lower left corner (rh coord sys)

ok = query_tiff(imagefile, info)
start = 0
stop = info.num_images-1
if (keyword_set(start_frame)) then start = start_frame
if (keyword_set(stop_frame)) then stop = stop_frame


if (keyword_set(rect)) then $
imgarr = uintarr(rect[2]-rect[0],rect[3]-rect[1],stop-start+1) $
else imgarr=uintarr(info.dimensions[0],info.dimensions[1],stop-start+1)

if (ok) then begin
  for i=start,stop do begin
    if (keyword_set(rect)) then $
      img=read_tiff(imagefile,image_index=i,sub_rect=rect) $
    else img=read_tiff(imagefile,image_index=i)
    s=size(a)
    if (s[0] eq 3) then begin
      imgarr = img
      i = stop
    endif else begin
      imgarr[*,*,i-start] = img
    endelse
  endfor
endif

return, imgarr
end

pro zmapdrawevents, event
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common heightmap, mapStruct, pixelsize, timestamp, mapfile
common mouse, mousedown, infoinitial

  ;print, 'Event handler'
  ;Fanning's IDL Coyote code: drawbox_widget
  
  ;print, event.type
  IF event.type GT 2 THEN RETURN
  eventTypes = ['DOWN', 'UP', 'MOTION']
  thisEvent = eventTypes[event.type]
  Widget_Control, event.top, Get_UValue=info, /No_Copy

  
  if screenmode eq 0 then begin
  
    xmin = zoomcoord[0] & ymin = zoomcoord[1]
    xmax = zoomcoord[2] & ymax = zoomcoord[3]
    xdim = xmax-xmin+1 & ydim = ymax-ymin+1
    mgw = fix((wxsz/xdim)<(wysz/ydim))
    
    if size(info,/type) ne 8 then begin
        info = infoinitial
        widget_control, event.top, set_uvalue=info,/no_copy
        print, 'Reinitialized info..'
        return
      end 
    
    
    case thisevent of
      'DOWN':begin           
      widget_control, info.drawID, draw_motion_events =1
      window, /free,/pixmap,xsize=info.xsize,ysize=info.ysize
      info.pixID = !D.window
      device,copy=[0,0,info.xsize,info.ysize,0,0,info.wid]
      info.sx = event.x >0
      info.sy = event.y >0
      wset, mainwindow
      mousedown = 1
      widget_control, event.top, set_uvalue=info,/no_copy
    ;print, 'down'
    end
    'MOTION': begin
      wset,info.wid
      device,copy=[0,0,info.xsize,info.ysize,0,0,info.pixID]
      sx=info.sx
      sy=info.sy
      dx=(event.x < wxsz)>0
      dy= (event.y < wysz)>0
      ; forcing square
      dim = abs(dx-sx)<abs(dy-sy)
      dx = (event.x gt sx) ? info.sx+dim:info.sx-dim
      dy = (event.y gt sy) ? info.sy+dim:info.sy-dim
      plotS, [sx,sx,dx,dx,sx],[sy,dy,dy,sy,sy],/device, color =info.boxcolor
      wset, mainwindow
      widget_control, event.top, set_uvalue=info,/no_copy
    end
    'UP': begin
      if mousedown eq 0 then begin
        widget_control, event.top, set_uvalue=info,/no_copy
        return
      endif
;      if size(info,/type) ne 8 then return
      mousedown = 0
      if info.pixID eq -1 then begin
        window, /free,/pixmap,xsize=info.xsize,ysize=info.ysize
        info.pixID = !D.window
        widget_control, event.top, set_uvalue=info,/no_copy
        return
      end
      device, window_state= windowstate      
      if windowstate[info.pixID] lt 1 then return
      wset, info.wid
      
      device,copy=[0,0,info.xsize,info.ysize,0,0,info.pixID]
      wdelete, info.pixID
      widget_control, info.drawID, draw_motion_events =0, clear_events=1
      dx=(event.x < wxsz)>0
      dy= (event.y < wysz)>0
      sx=info.sx
      sy=info.sy
      ; forcing square
      dim = abs(dx-sx)<abs(dy-sy)
      dx = (event.x gt sx) ? info.sx+dim-1:info.sx-dim-1
      dy = (event.y gt sy) ? info.sy+dim-1:info.sy-dim-1
      
      sx= min([info.sx,dx],max=dx)
      sy= min([info.sy,dy],max=dy)   

      zoomcoord = [sx/mgw+xmin,sy/mgw+ymin,dx/mgw+xmin,dy/mgw+ymin]
      widget_control, event.top, set_uvalue=info,/no_copy
      displaytiff, event
    end
  endcase
  
endif else begin

      if size(info,/type) ne 8 then begin
        info = infoinitial
        widget_control, event.top, set_uvalue=info,/no_copy
        print, 'Reinitialized info..'
        return
      end 

  case thisevent of
    'DOWN':begin
      if event.press eq 4 then begin
        mousedown = 0
        xpress = event.x
        ypress = event.y
        conv =convert_coord(xpress,ypress,[0,0],/device,/to_data)
        widget_control,widget_info(event.top,find_by_uname='WID_LABEL_MOUSEX'),set_value=string(conv[0],format='(F7.2)')
        widget_control,widget_info(event.top,find_by_uname='WID_LABEL_MOUSEY'),set_value=string(conv[1],format='(F7.2)')
        maptype = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_MAP'),/droplist_select)
        datax  = (conv[0]>0)<(dimension[0]-1) & datay  = (conv[1]>0)<(dimension[1]-1)
        widget_control,widget_info(event.top,find_by_uname='WID_LABEL_MOUSEZ'),set_value=string(mapstruct[datax,datay,maptype],format='(F10.3)')
        widget_control, event.top, set_uvalue=info,/no_copy
    ; widget_control, info.drawID, draw_motion_events =0
      endif else begin
        mousedown = 1
        widget_control, info.drawID, draw_motion_events =1
        window, /free,/pixmap,xsize=info.xsize,ysize=info.ysize
        info.pixID = !D.window
        device,copy=[0,0,info.xsize,info.ysize,0,0,info.wid]
        info.sx = event.x >0
        info.sy = event.y >0
        wset, mainwindow
        widget_control, event.top, set_uvalue=info,/no_copy
    endelse
    
    
  ;print, 'down'
  end
  'MOTION': begin
    wset,info.wid
    device,copy=[0,0,info.xsize,info.ysize,0,0,info.pixID]
    sx=info.sx
    sy=info.sy
    dx=(event.x < wxsz)>0
    dy= (event.y < wysz)>0
    ; forcing square
    ;      dim = abs(dx-sx)<abs(dy-sy)
    ;      dx = (event.x gt sx) ? info.sx+dim:info.sx-dim
    ;      dy = (event.y gt sy) ? info.sy+dim:info.sy-dim
    plotS, [sx,sx,dx,dx,sx],[sy,dy,dy,sy,sy],/device, color =info.boxcolor
    wset, mainwindow
    widget_control, event.top, set_uvalue=info,/no_copy
  end
  'UP': begin
   ; if size(info, /type) ne 8 then return
    if mousedown eq 0 then begin
      widget_control, event.top, set_uvalue=info,/no_copy
      return
    end   
    if info.pixID eq -1 then begin
      window, /free,/pixmap,xsize=info.xsize,ysize=info.ysize
      info.pixID = !D.window
      widget_control, event.top, set_uvalue=info,/no_copy
      return
    end
    if event.release eq 4 then begin
      info.pixID = !D.window
      widget_control, event.top, set_uvalue=info,/no_copy
      return
    end
    device, window_state= windowstate
    
    if windowstate[info.pixID] lt 1 then return
    if windowstate[info.wid] lt 1 then return
    wset, info.wid
    
    device,copy=[0,0,info.xsize,info.ysize,0,0,info.pixID]
    wdelete, info.pixID
    widget_control, info.drawID, draw_motion_events =0, clear_events=1
    dx=(event.x < wxsz)>0
    dy= (event.y < wysz)>0
    sx=info.sx
    sy=info.sy
    ; forcing square
    dim = abs(dx-sx)<abs(dy-sy)
    dx = (event.x gt sx) ? info.sx+dim-1:info.sx-dim-1
    dy = (event.y gt sy) ? info.sy+dim-1:info.sy-dim-1
    
    sx= min([info.sx,dx],max=dx)
    sy= min([info.sy,dy],max=dy)
    
    ;print, [sx/mgw+xmin,sy/mgw+ymin,dx/mgw+xmin,dy/mgw+ymin]
    ;zoomcoord = [sx,sy,dx,dy]/mgw
    conv =convert_coord([sx , dx],[ sy, dy],[0,0],/device,/to_data)
    xmin = (conv[0,0]>0)<(dimension[0]-1) &  xmax = (conv[0,1]>0)<(dimension[0]-1)
    ymin = (conv[1,0]>0)<(dimension[1]-1) &  ymax = (conv[1,1]>0)<(dimension[1]-1)
    zoomcoord = [fix(xmin),fix(ymin),fix(xmax),fix(ymax)]
    ;print, fix(xmin),fix(xmax),fix(ymin),fix(ymax)
    widget_control, event.top, set_uvalue=info,/no_copy
    displaymap, event
  end
  
  else:
endcase

endelse

;widget_control, event.top, set_uvalue=info,/no_copy
end

function VIAFLICLM, X, A
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

field =  SAIMfield1(A[2],excitationwavelength, spacerthickness, X)
increment = 2.
intensity =  real_part(field*conj(field))
y = A[0]+A[1]*intensity
dyda0 = 1.
dyda1 = intensity
fieldinc = SAIMfield1(A[2]+increment,excitationwavelength, spacerthickness, X)
fielddiff = (real_part(fieldinc*conj(fieldinc))-intensity)/increment
dyda2 = A[1]*fielddiff

return,[y, dyda0, dyda1, dyda2]
end

pro fieldfixedz, event
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode

screenmode = 1
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),get_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),get_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),get_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),get_value=Tdegmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),get_value=Zmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZRES' ),get_value=resz
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),get_value=resangle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),get_value=cameraOffset
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_SINGLEZ' ),get_value=singlez

dimensionangle = fix(Tdegmax/resangle)+1
Tint = dindgen(dimensionangle)*resangle
field = SAIMfield1(singlez,excitationwavelength, spacerthickness, Tint)
;print, field
intensity = field*conj(field)
;print, intensity
tvscl, bytarr(wxsz,wysz)
sttitle = 'Intensity vs. Angle: Wavelength = '+string(excitationwavelength,format='(F7.1)')+' nm '+$
  ' spacer thickness: '+ string(spacerthickness,format='(F7.1)')+ ' nm Object Height : '+string(singlez,format='(F6.2)')+' nm'
plot, Tint, intensity, xstyle =1,xtitle='Angle',ystyle = 1, yrange= [0,4],thick = 2,ytitle='Relative Intensity', $
  title=sttitle,position=[0.05,0.05,0.95,0.95],/normal
  oplot, Tint, intensity, psym=7, color=cgcolor('red'),symsize = 2
  

end

function extractzfast, angle, experimental
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

mindata = min(experimental-cameraOffset);
scaling = max(experimental-cameraOffset-mindata)/4.;
rescaleddata = (experimental-cameraOffset-mindata)/scaling;
A = [0, 1, 0]
;print, A
  
guesszarray  = indgen(guessIteration)*(maximumHeight*0.1/guessIteration)
allchisq = dblarr(guessIteration)
resultA = dblarr(guessIteration,3)
resultsigma = dblarr(guessIteration,3)
resultchisq = dblarr(guessIteration,3)
for i = 0L, guessIteration-1 do begin
      A = [0,1,guesszarray[i]]
      result = LMFIT( angle, rescaleddata, A , CHISQ=chisq,/double,convergence=conv, $
      FITA=[1,1,1], FUNCTION_NAME='VIAFLICLM', ITER=numiter, SIGMA=sigma, TOL=1e-5)
;      result = curvefit(angle, rescaleddata, weightings,A,/double,fita=[1,1,1],$
;        function_name='VIAFLICFIT',itmax = 100, iter=numiter,/noderivative,yerror = residual)
;      yrange = [min([rescaleddata, result]),max([rescaleddata, result])*1.1]
;      plot, angle, rescaleddata, xstyle =1 ,yrange = yrange, xtitle='Angle (degree',ytitle = 'Relative Intensity'
;      oplot, angle, rescaleddata, color=cgcolor('red'),psym = 7
;      oplot, angle, result, color=cgcolor('green')
;      st1 = 'Trial Z initial: '+string(guesszarray[i],format='(F5.2)')
;      xyouts, 0.2, 0.9, st1, charsize=2,/normal
;      st2 = 'Fit Result: '+string(A[2],format='(F5.2)') 
      allchisq[i] = chisq 
      resultA[i,*] = A    
      resultsigma[i,*] = sigma
     
  endfor
zfit = resultA[*,2]
scalingfit = resultA[*,1]
;print, zfit
;print, allchisq

nonzeros = where((zfit gt 0) and (scalingfit gt 0), count)
if count le 0 then begin
  print, 'No good fit found'
  xyouts, 0.125, 0.9-0.05*4, 'No good fit found', charsize=2.5,/normal, color=cgcolor('red')
  return, {z:!VALUES.F_NAN , offset:!VALUES.F_NAN, scaling:!VALUES.F_NAN , $
    sigmaz:!VALUES.F_NAN, sigmaOffset:!VALUES.F_NAN, sigmascaling:!VALUES.F_NAN,chisq:!VALUES.F_NAN}
endif

residualz = allchisq[nonzeros]
indexmin = 0.
minresiduals =min(residualz,indexmin)
nonzerosA = resultA[nonzeros,*]


bestA = nonzerosA[indexmin,*]
nonzerossigma = resultsigma[nonzeros,*]
bestsigma = nonzerossigma[indexmin, *]

;print, bestA[2]
;;print, resultsigma[indexmin, *]
;bestfit = VIAFLICLM(angle,bestA)
;bestsigma = resultsigma[indexmin, *]

;ymax = max([rescaleddata, bestfit],min= ymin) 
;yrange = [ymin-0.1*(ymax-ymin),ymax+0.1*(ymax-ymin)]
;
;plot, angle, rescaleddata, xstyle =1 ,yrange = yrange, xtitle='Angle (degree)',ytitle = 'Relative Intensity',ystyle = 1
;oplot, angle, rescaleddata, color=cgcolor('red'),psym = 7
;oplot, angle, bestfit, color=cgcolor('green'),thick  = 2
;oplot, angle, bestfit, color=cgcolor('green'),psym = 7
;
;st1 = 'Best Fit Z: '+string(bestA[2],format='(F9.2)')+' nm Sigma :'+string(bestsigma[2],format='(F7.2)')+' nm'
;xyouts, 0.125, 0.9, st1, charsize=1.75,/normal, color= cgcolor('yellow')
;st2 = 'Best Fit Offset: '+string(bestA[0],format='(F5.2)')+' Sigma :'+string(bestsigma[0],format='(F5.2)')
;st3 = 'Best Fit Scaling: '+string(bestA[1],format='(F5.2)')+' Sigma :'+string(bestsigma[1],format='(F5.2)')
;st4 = 'Chi. Squared :'+string(allchisq[indexmin],format='(F5.2)')
;xyouts, 0.125, 0.9-0.05, st2, charsize=1.5,/normal
;xyouts, 0.125, 0.9-0.05*2, st3, charsize=1.5,/normal
;xyouts, 0.125, 0.9-0.05*3, st4, charsize=1.5,/normal

return, {z:bestA[2] , offset:bestA[0], scaling:bestA[1] , sigmaz:bestsigma[2], sigmaOffset:bestsigma[0], sigmascaling:bestsigma[1],chisq:allchisq[indexmin]}
end

function extractz, angle, experimental
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

mindata = min(experimental-cameraOffset);
scaling = max(experimental-cameraOffset-mindata)/4.;
rescaleddata = (experimental-cameraOffset-mindata)/scaling;
A = [0, 1, 0]
;print, A
  
guesszarray  = indgen(guessIteration)*(maximumHeight*0.1/guessIteration)
allchisq = dblarr(guessIteration)
resultA = dblarr(guessIteration,3)
resultsigma = dblarr(guessIteration,3)
resultchisq = dblarr(guessIteration,3)
for i = 0L, guessIteration-1 do begin
      A = [0,1,guesszarray[i]]
      result = LMFIT( angle, rescaleddata, A , CHISQ=chisq,/double,convergence=conv, $
      FITA=[1,1,1], FUNCTION_NAME='VIAFLICLM', ITER=numiter, SIGMA=sigma, TOL=1e-5)
;      result = curvefit(angle, rescaleddata, weightings,A,/double,fita=[1,1,1],$
;        function_name='VIAFLICFIT',itmax = 100, iter=numiter,/noderivative,yerror = residual)
      yrange = [min([rescaleddata, result]),max([rescaleddata, result])*1.1]
      plot, angle, rescaleddata, xstyle =1 ,yrange = yrange, xtitle='Angle (degree',ytitle = 'Relative Intensity'
      oplot, angle, rescaleddata, color=cgcolor('red'),psym = 7
      oplot, angle, result, color=cgcolor('green')
      st1 = 'Trial Z initial: '+string(guesszarray[i],format='(F5.2)')
      xyouts, 0.2, 0.9, st1, charsize=2,/normal
      st2 = 'Fit Result: '+string(A[2],format='(F5.2)') 
      allchisq[i] = chisq 
      resultA[i,*] = A    
      resultsigma[i,*] = sigma
     
  endfor
zfit = resultA[*,2]
;print, zfit
;print, allchisq

nonzeros = where(zfit gt 0, count)
if count le 0 then begin
  print, 'No good fit found'
  xyouts, 0.125, 0.9-0.05*4, 'No good fit found', charsize=2.5,/normal, color=cgcolor('red')
  return, {z:!VALUES.F_NAN , offset:!VALUES.F_NAN, scaling:!VALUES.F_NAN , $
    sigmaz:!VALUES.F_NAN, sigmaOffset:!VALUES.F_NAN, sigmascaling:!VALUES.F_NAN,chisq:!VALUES.F_NAN}
endif

residualz = allchisq[nonzeros]
indexmin = 0.
minresiduals =min(allchisq,indexmin)
nonzerosA = resultA[nonzeros,*]
bestA = nonzerosA[indexmin,*]
nonzerossigma = resultsigma[nonzeros,*]
bestsigma = nonzerossigma[indexmin, *]

print, bestA[2]
;print, resultsigma[indexmin, *]
bestfit = VIAFLICLM(angle,bestA)

ymax = max([rescaleddata, bestfit],min= ymin) 
yrange = [ymin-0.1*(ymax-ymin),ymax+0.1*(ymax-ymin)]

plot, angle, rescaleddata, xstyle =1 ,yrange = yrange, xtitle='Angle (degree)',ytitle = 'Relative Intensity',ystyle = 1
oplot, angle, rescaleddata, color=cgcolor('red'),psym = 7
oplot, angle, bestfit, color=cgcolor('green'),thick  = 2
oplot, angle, bestfit, color=cgcolor('green'),psym = 7

st1 = 'Best Fit Z: '+string(bestA[2],format='(F9.2)')+' nm Sigma :'+string(bestsigma[2],format='(F7.2)')+' nm'
xyouts, 0.125, 0.9, st1, charsize=1.75,/normal, color= cgcolor('yellow')
st2 = 'Best Fit Offset: '+string(bestA[0],format='(F5.2)')+' Sigma :'+string(bestsigma[0],format='(F5.2)')
st3 = 'Best Fit Scaling: '+string(bestA[1],format='(F5.2)')+' Sigma :'+string(bestsigma[1],format='(F5.2)')
st4 = 'Chi. Squared :'+string(allchisq[indexmin],format='(F5.2)')
xyouts, 0.125, 0.9-0.05, st2, charsize=1.5,/normal
xyouts, 0.125, 0.9-0.05*2, st3, charsize=1.5,/normal
xyouts, 0.125, 0.9-0.05*3, st4, charsize=1.5,/normal

return, {z:bestA[2] , offset:bestA[0], scaling:bestA[1] , sigmaz:bestsigma[2], sigmaOffset:bestsigma[0], sigmascaling:bestsigma[1],chisq:allchisq[indexmin]}
end

pro extractzavg, event
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]

tvscl, bytarr(wxsz,wysz)
y = dblarr(numberofframes)

widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),get_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),get_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),get_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),get_value=Tdegmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),get_value=Zmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZRES' ),get_value=resz
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),get_value=resangle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),get_value=cameraOffset

for index = 0L, numberofframes-1 do begin
  zoomim = rawImage[xmin:xmax,ymin:ymax,index]
  y[index] = mean(zoomim)
endfor
rangey = max(y)-min(y) & yrange = [min(y)-rangey*.1,max(y)+rangey*.1]

angle = indgen(numberofframes)*resangle
;plot,  angle, y, xstyle =1,yrange = yrange, title='total vs. frame', xtitle = 'frame', ytitle = 'total of frame'
;oplot, angle, y, color = cgcolor('crimson'), psym = 7, symsize = 2

;guess = guessz(y,angle)
;renorm = (y-guess.offset)/guess.scaling
;plot,  angle, renorm, xstyle =1,yrange=[0,4.1], title='total vs. frame', xtitle = 'angle', ytitle = 'renorm. total of frame'
;oplot, angle, renorm, color = cgcolor('crimson'), psym = 7, symsize = 2
;
;print, guess.z
;guessfit = SAIMfield1(guess.z,excitationwavelength, spacerthickness, angle)
;oplot, angle, guessfit, color = cgcolor('steel blue')
;loadct, 3

result = extractz(angle,y)

end

pro extractzpixzoom, event
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common rawdata, datafile, numberofframes, dimension, rawImage, rawMask,maskCode
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
common heightmap, mapStruct, pixelsize, timestamp, mapfile
 
viewthreshold, event
screenmode = 1

 widget_control,widget_info(event.top,find_by_uname='WID_SLIDER_MINVAL'),get_value=threshold
 meanImage = mean(rawImage, dimension=3)

print, maskcode
if maskcode eq 0 then begin
  viewthreshold, event
  binmask = (meanImage gt threshold)
endif else begin
  binmask = rawmask
  viewmask,event
endelse


widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),get_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),get_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),get_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),get_value=Tdegmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),get_value=Zmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZRES' ),get_value=resz
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),get_value=resangle
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_OFFSET' ),get_value=cameraOffset
maximumAngle=Tdegmax
angleSpacing=resangle
maximumHeight=Zmax

colortable = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_COLOR'),/droplist_select)
;[ 'Rainbow','#5 Std Gamma II', '#25 Mac Style','Red Temperature # 3','#33 Blue-Red','#34 Rainbow']
case colortable of
  0: ct = 13
  1: ct = 5
  2: ct = 25
  3: ct = 3
  4: ct = 33
  5: ct = 34
  else: ct = 13
endcase

xmin = zoomcoord[0] & ymin = zoomcoord[1]
xmax = zoomcoord[2] & ymax = zoomcoord[3]

y = dblarr(numberofframes)
angle = indgen(numberofframes)*resangle

xdim = xmax-xmin+1
ydim = ymax-ymin+1
fitmap = dblarr(xdim,ydim, 7)
zoommask = binmask[xmin:xmax,ymin:ymax]
numpix = total(zoommask)

if numpix lt 1 then begin
  xyouts, 0.1, 0.5,'No valid pixels!!', charsize = 3, /normal, color=cgcolor('red')
  print, 'No valid pixels'
  return
end

pixcount = 0
tbegin = systime(/seconds)
widget_control,/hourglass

reportpixinterval = fix(numpix/100)

pixcount = 0
percentfinish = 0
for i = 0,xdim-1 do begin
  for j = 0, ydim-1 do begin
      if zoommask[i,j] gt 0 then begin
        pixx = xmin+i & pixy = ymin+j
        y = reform(rawimage[pixx,pixy,*])
        result = extractzfast(angle,y)
        ;      {z:bestA[2] , offset:bestA[0], scaling:bestA[1] , sigmaz:bestsigma[2], sigmaOffset:bestsigma[0], sigmascaling:bestsigma[1],chisq:allchisq[indexmin]}
        fitmap[i,j,*] = [result.z,result.offset, result.scaling, result.sigmaz, result.sigmaoffset, result.sigmascaling, result.chisq]
        pixcount = pixcount+1
        if pixcount eq reportpixinterval then begin
          percentfinish = percentfinish+1
          st = 'Progress : '+string(percentfinish)+' % z = '+string(result.z)+' nm'
          print, st
          xyouts,0.05, percentfinish/100.,'^ '+st,charsize = 1,/normal,color = cgcolor('yellow')
          pixcount = 0
        end
      end 
  endfor
endfor  

mapstruct[xmin:xmax,ymin:ymax,0] = fitmap[*,*,0]
mapstruct[xmin:xmax,ymin:ymax,1] = fitmap[*,*,1]
mapstruct[xmin:xmax,ymin:ymax,2] = fitmap[*,*,2]
mapstruct[xmin:xmax,ymin:ymax,3] = fitmap[*,*,3]
mapstruct[xmin:xmax,ymin:ymax,4] = fitmap[*,*,4]
mapstruct[xmin:xmax,ymin:ymax,5] = fitmap[*,*,5]
mapstruct[xmin:xmax,ymin:ymax,6] = fitmap[*,*,6]

displaymap,event
ttotal = systime(/seconds)-tbegin
tperpix = ttotal/(xdim*ydim)

stt = 'Total time = '+string(ttotal,format='(F10.1)')+' seconds Time per pixel = '+string(tperpix,format='(F10.2)')+' seconds'
xyouts, 0.025,0.03,stt,/normal

  
end

pro plotfield, event
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
common display, wxsz, wysz, mainwindow, autoscale, zoomcoord, screenmode
;print, 'plotfield'
screenmode = 1
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_WAVELENGTH' ),get_value=excitationwavelength
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_THICKNESS' ),get_value=spacerthickness
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_INDEX' ),get_value=nspacer
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLEMAX' ),get_value=Tdegmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZMAX' ),get_value=Zmax
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ZRES' ),get_value=resz
widget_control,widget_info(event.top, find_by_uname='WID_SLIDER_ANGLERES' ),get_value=resangle
colortable = widget_info(widget_info(event.top,find_by_uname='WID_DROPLIST_COLOR'),/droplist_select)
;[ 'Rainbow','#5 Std Gamma II', '#25 Mac Style','Red Temperature # 3','#33 Blue-Red','#34 Rainbow']
case colortable of
  0: ct = 13
  1: ct = 5
  2: ct = 25
  3: ct = 3
  4: ct = 33
  5: ct = 34
  else: ct = 13
endcase

dOx = spacerthickness
lambda = excitationwavelength
intensity = SAIMintensityMap(Zmax, Tdegmax, dOx, lambda, resangle, resz)

im = congrid(intensity, 1024, 1024,/interp,/minus_one)
loadct,ct
;tvscl, im
;imx = image(im,/current)
wset, mainwindow
tvscl, bytarr(wxsz,wysz)
cgImage, bytscl(im,min=0,max=4), position=[0.1,0.1,0.9,0.9]
cgColorbar , POSITION=[0.25,0.93,0.75,0.97],RANGE=[0,4]  ,annotatecolor='white'

loadct,3
plot,[0,0],[0.,0],/noerase,position=[0.1,0.1,0.9,0.9],/normal,xstyle=1, ystyle=1, xrange=[0, Tdegmax],yrange=[0,Zmax], $
  xtitle='Angle (degree)',ytitle='Height above Oxide(spacer) layer (nm)',charsize = 2
  
;cgColorbar [, /ADDCMD] [, ANNOTATECOLOR=string] [, BOTTOM=integer] [, /BREWER] [, CHARPERCENT=float] [, CHARSIZE=float] $
;[, CLAMP=float] [, COLOR=string] [, CTINDEX=integer] [, /DISCRETE] [, DIVISIONS=integer] [, /FIT] [, FONT=integer] [, FORMAT=string] $
;[, /INVERTCOLORS] [, MAXRANGE=MAXRANGE] [, MINOR=integer] [, MINRANGE=float] [, NCOLORS=integer] [, NEUTRALINDEX=integer] $
;[, NODISPLAY=NODISPLAY] [, OOB_FACTOR=float] [, OOB_HIGH=string] [, OOB_LOW=string] [, PALETTE=byte] [, POSITION=float] [, RANGE=float] $
;[, /REVERSE] [, /RIGHT] [, TCHARSIZE=float] [, TEXTTHICK=float] [, TLOCATION=string] [, TICKINTERVAL=float] [, TICKLEN=float] [, TICKNAMES=string] $
;[, TITLE=string] [, /TOP] [, /VERTICAL] [, /XLOG] [, XTICKINTERVAL=float] [, XTICKLAYOUT=integer] [, XTITLE=string] [, /YLOG] [, YTICKINTERVAL=float]$
; [, YTICKLAYOUT=integer] [, YTITLE=string] [, /WINDOW] [, _REF_EXTRA=_REF_EXTRA]

end

function  SAIMintensityMap,Zmax, Tdegmax, dOx, lambda, resangle, resz
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

dimensionangle = fix(Tdegmax/resangle)+1
dimensionz = fix(Zmax/resz)+1

zint = dindgen(dimensionz)*resz & Tint = dindgen(dimensionangle)*resangle

Intensity = dblarr(dimensionangle,dimensionz)
Field = complexarr(dimensionangle,dimensionz)

for i = 0L, dimensionangle-1 do begin
    for j = 0L, dimensionz-1 do begin
      Field(i,j) = SAIMfield1(Zint(j),lambda, dOx, Tint(i));
  endfor
endfor

Intensity = abs(Field*conj(Field));
return, Intensity

end


function SAIMfield1,Height,lambda, dox, thetabdeg, sign=sign
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

; from MATLAB F = SAIMfield1(H,lambda, dox, thetabdeg)
;numtheta = numel(thetabdeg);
;if numtheta == 1 

numel = n_elements(thetabdeg)
  thetab = thetabdeg*!pi/180.;
  if size(nbuffer,/type) eq 0 then nbuffer = 1.33
    if size(nspacer,/type) eq 0 then nbuffer = 1.4605
  nb = nbuffer
  nox = nspacer

if numel eq 1 then begin

  thetaox = asin(nb*sin(thetab)/nox);
  thetasi = asin(nox*sin(thetaox)/nsi);
  
  mTE = complexarr(2,2);
  kox = 2*!pi*nox/lambda;
  mTE[0,0] = cos(kox*dox*cos(thetaox));
  mTE[0,1] =-1*complex(0,1)*sin(kox*dox*cos(thetaox))/(nox*cos(thetaox));
  mTE[1,0] = -1*complex(0,1)*(nox*cos(thetaox))*sin(kox*dox*cos(thetaox));
  mTE[1,1] = cos(kox*dox*cos(thetaox));
  ;print, mTE
  if keyword_set(sign) then begin
    rTEnum = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab)-(mTE[1,0]+mTE[1,1]*nsi*cos(thetasi)));
    print, 'sign'
  endif
  rTEnum = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab)+(mTE[1,0]-mTE[1,1]*nsi*cos(thetasi)));
  rTEdenom = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab)+(mTE[1,0]+mTE[1,1]*nsi*cos(thetasi)));
  rTE = rTEnum/rTEdenom;
  F = 1+rTE*exp(complex(0,1)*4*!pi*nb*Height*cos(thetab)/lambda);
endif else begin
  
  F = complexarr(numel)
  for i = 0, numel-1 do begin
    
    thetaox = reform(asin(nb*sin(thetab[i])/nox));
    thetasi = asin(nox*sin(thetaox)/nsi);
  
    mTE = complexarr(2,2);
    kox = 2*!pi*nox/lambda;
    mTE[0,0] = cos(kox*dox*cos(thetaox));
    mTE[0,1] =-1*complex(0,1)*sin(kox*dox*cos(thetaox))/(nox*cos(thetaox));
    mTE[1,0] = -1*complex(0,1)*(nox*cos(thetaox))*sin(kox*dox*cos(thetaox));
    mTE[1,1] = cos(kox*dox*cos(thetaox));
    
     if keyword_set(sign) then begin
      rTEnum = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab)-(mTE[1,0]+mTE[1,1]*nsi*cos(thetasi)));
      print, 'sign'
     endif
    rTEnum = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab[i])+(mTE[1,0]-mTE[1,1]*nsi*cos(thetasi)));
    rTEdenom = ((mTE[0,0]+mTE[0,1]*nsi*cos(thetasi))*nb*cos(thetab[i])+(mTE[1,0]+mTE[1,1]*nsi*cos(thetasi)));
    ;help, rTEnum
    rTE = rTEnum/rTEdenom;
    ;print, rTEnum/rTEdenom
    ;help, rTE
    ;print, mte
    F[i] = 1+rTE*exp(complex(0,1)*4*!pi*nb*Height*cos(thetab[i])/lambda);
    ;print, 'exp', exp(complex(0,1)*4*!pi*nb*Height*cos(thetab[i])/lambda)
    ;print, F[i]
    
;    mTE(1,1) = cos(kox*dox*cos(thetaox));
;        mTE(1,2) =-1*1i*sin(kox*dox*cos(thetaox))/(nox*cos(thetaox));
;        mTE(2,1) = -1i*(nox*cos(thetaox))*sin(kox*dox*cos(thetaox));
;        mTE(2,2) = cos(kox*dox*cos(thetaox));
;        
;        rTEnum = ((mTE(1,1)+mTE(1,2)*nsi*cos(thetasi))*nb*cos(thetab)+(mTE(2,1)-mTE(2,2)*nsi*cos(thetasi)));
;        rTEdenom = ((mTE(1,1)+mTE(1,2)*nsi*cos(thetasi))*nb*cos(thetab)+(mTE(2,1)+mTE(2,2)*nsi*cos(thetasi)));
;        rTE = rTEnum/rTEdenom;
;        F(i) = 1+rTE*exp(1i*4*pi*nb*H*cos(thetab)/lambda);  
    
  endfor
end
return, F
end

PRO VIAFLICFIT, X, A, F
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum
    ; X is the angle
    ; A = [ offset, scaling, z]
     field =  SAIMfield1(A[2],excitationwavelength, spacerthickness, X)    
     F = A[0]+A[1]*real_part(field*conj(field))
END

function guessz, data, angle
common VIAFLIC, nbuffer, nsio2, nspacer, nsi, Field, Intensity, excitationwavelength, spacerthickness, $
  maximumHeight, maximumAngle, angleSpacing, guessIteration,cameraOffset,threshold, zcolormax,pixelsizenm,guessMaximum

numel = n_elements(data)
datamin = min(data, max = datamax)
scaling = (datamax-cameraOffset)/4.
offset = cameraOffset

normdata = (data-offset)/scaling

guesszarray  = indgen(guessIteration)*(maximumHeight/guessIteration)
residuals = dblarr(guessIteration)
  for i = 0L, guessIteration-1 do begin
      calcf = SAIMfield1(guesszarray[i],excitationwavelength, spacerthickness, angle)
      residuals = total((normdata-(calcf^2))^2)        
  endfor
indexmin = 0.
minresiduals =min(residuals,indexmin)
;print, guesszarray[indexmin]

return, {scaling:scaling, offset:offset, z:guesszarray[indexmin]}

end

pro savescreentiff, event
filename = Dialog_Pickfile(/write,get_path=fpath)
if strlen(fpath) ne 0 then cd,fpath
if filename eq '' then return
presentimage=reverse(tvrd(true=1),3)
filename=AddExtension(filename,'.tiff')
write_tiff,filename,presentimage,orientation=1

end

