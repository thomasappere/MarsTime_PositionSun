FUNCTION mcd_get_temp, geocube

;***
; PURPOSE : Get temperature profile from the MCD for a OMEGA given cube
;
; INPUT : - geocube : read from OMEGA
;
; OUTPUT : [lon,lat,field] array
;          - surface temperature value for each OMEGA pixel (field=0)
;          - vertical temperature profile for each OMEGA pixel (field=1 to 33)
;	   - aerocentric longitude (field=34)
;	   - local time (field=35)
;	   - additional horizontal field (ex: dust opacity) (field=36)
;
; AUTHORS :
; A. Spiga - few changes - November 2006
; B. Dolla & F. Forget - main interpolation process and MCD call - August 2005
;***



;------------------------
; Useful data from OMEGA  
;------------------------

nx = N_Elements(geocube[*,0,0])
ny = N_Elements(geocube[0,0,*])
n = nx*ny

lat = Reform(geocube[*,7,*],n)*1d-4
lon = Reform(geocube[*,6,*],n)*1d-4
time = Reform(geocube[*,1,0])


;------------------------
; New grid
;------------------------

latmax = max(lat,min=latmin)
lonmax = max(lon,min=lonmin)

; New grid mesh 
case nx of 
	1: goto, ref ; for a single profile
	16: xratio=2
	32: xratio=4
	64: xratio=8
	128: xratio=10
endcase
yratio = 10

nxgrid = floor(nx/xratio)
nygrid = floor(ny/yratio)

ngrid=nxgrid*nygrid

latgrid = DIndGen(nygrid)/(nygrid-1)*(latmax-latmin)+latmin
longrid = DIndGen(nxgrid)/(nxgrid-1)*(lonmax-lonmin)+lonmin

jlat = interpol(Indgen(nygrid), latgrid, lat)
ilon = interpol(IndGen(nxgrid), longrid, lon)

latgrid = reform(transpose(rebin(latgrid,nygrid,nxgrid)),ngrid)
longrid = reform(rebin(longrid,nxgrid,nygrid),ngrid)

; nevermind this one (use of the julian date ...)
ls = DblArr(ngrid) 

ref:


;-------------
; Julian date
;-------------

julian, time, date
date = replicate(date,ngrid)


;-------------------------------
; Sigma coordinate for altitude
;-------------------------------

sigma = $
[1          ,$   
0.99950	    ,$  
0.99800     ,$ 
0.99501     ,$
0.98909     ,$
0.97744     ,$
0.95500     ,$
0.91329     ,$ ; level 7
0.84061     ,$
0.72685     ,$
0.57464     ,$
0.4074      ,$
0.25888     ,$
0.15007     ,$
0.81573E-01 ,$
0.42627E-01 ,$ ; level 15
0.21789E-01 ,$
0.11008E-01 ,$
0.55281E-02 ,$
0.27676E-02 ,$
0.13835E-02 ,$
0.69104E-03 ,$
0.34504E-03 ,$
0.17224E-03 ,$
0.85977E-04 ,$
0.42914E-04 ,$
0.21419E-04 ,$
0.10691E-04 ,$
0.53359E-05 ,$
0.26632E-05 ,$
0.13292E-05 ,$
0.66341E-06 ,$
0.22086E-06]


;---------------------------
; Call of Fortran procedure
;---------------------------

dust = 2  ; best guess MY24 scenario, with solar average conditions
zkey = 3   ; specify that xz is the altitude above surface (m)

mcd_get, Ls, date, $
	latgrid, longrid, $
	dust, zkey, $
	sigma, Tgrid, $
	field, $
	Lsolar, Localtime, $
	Tsurf


;-----------------------------------
; Temperature profile interpolation
;-----------------------------------

latgrid = reform(latgrid,nxgrid,nygrid)
longrid = reform(longrid,nxgrid,nygrid)

Tgrid = reform(Tgrid,nxgrid,nygrid,33)
T = DblArr(nx,ny,33)

FOR i=0, 32 DO BEGIN
    T[*,*,i]= reform(interpolate(Tgrid[*,*,i],ilon,jlat),nx,ny)
ENDFOR


;-----------------------------------
; Surface field interpolation
;-----------------------------------

field_map = reform(field, nxgrid, nygrid)
field = reform(interpolate(field_map,ilon,jlat),nx,ny)

Tsurf_map = reform(Tsurf, nxgrid, nygrid)
Tsurf = reform(interpolate(Tsurf_map,ilon,jlat),nx,ny)


;-----------------------------------
; Output
;-----------------------------------

out = FltArr(nx,ny,37,/nozero)
out[*,*,0]=float(Tsurf)
out[*,*,1:33]= float(T)
out[*,*,34]= float(Lsolar)
out[*,*,35]= float(localtime)
out[*,*,36]= float(field)

RETURN, out

END
