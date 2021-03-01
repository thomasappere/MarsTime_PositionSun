PRO  mcd_get, Ls,Date,lat,lon,dust,zkey,sigma,temp,field, Lsolar, localtime, Tsurf

;;;;;;;;;;;;;;;;;;
; This IDL procedure is used to retrieve profiles of atmospheric data
; from  the Mars Climate database V4.
; It calls profils_mcd_idl.F fortran subroutine (which call atmemcd)
; input and ouput are transfered though the harddisk
; (slow but that's OK with atmemcd, and so simple !)
; You must compile first profils_mcd_idl.F to make executable profils_mcd_idl
; F. Forget 02/2005
;;;;;;;;;;;;;;;;;;
; Input: An array (list) of  horizontal space and time coordinates :
;     lat,lon:  latitude (degN), EAST longitude (deg)
;     zkey:     kind of xz: 1:radius 2:z>areoid 3:z>surface 4:pressure
;     Ls,Loct:  Ls (deg) , locatime (hours)
;     
;     At each location, you can provide a different array of altitude :
;     xz :      array of altitude (m) or pressure level (Pa)  
;
;     dust:     Scenarios : MY24=1,2,3 storm=4,5,6 warm=7 cold=8
; output:
;     meanvarz : multidimension meanvar as defined in MCD4. user manual
;     extvarz : multidimension extvar as defined in MCD4. user manual
;     NOTE : meaning of meanvar and extvar is also in beginning of atmemcd.F
;     WARNING : contrary to the usual IDL convention
;     meanvarz and extvarz left index is only used starting at 1
;     to keep the same numbering than in the fortran code and thus
;     be like in the user manual
;
;     In the output, meanvarz wnd extvarz will have the dimension :
;      meanvarz(5,ncoord,nz) and extvarz(50,ncoord,nz)

; Writing input argument
; ----------------------
OPENW, 22, "idl2fort.asc" ;, /DELETE
ncoord = n_elements(lat)
if n_elements(lon) ne ncoord then stop, 'pb of dimension in profils_idl.pro'
if n_elements(ls) ne ncoord then stop, 'pb of dimension in profils_idl.pro'
if n_elements(Date) ne ncoord then stop, 'pb of dimension in profils_idl.pro'
nz = n_elements(sigma)
PRINTF, 22, dust
PRINTF, 22, zkey
PRINTF, 22, ncoord,nz
PRINTF, 22, sigma, format='(D12.10)'
FOR  n=0L, ncoord-1 DO BEGIN
    PRINTF, 22, lat[n],lon[n],ls[n],Date[n], format='(4(D15.7,4x))'
ENDFOR
close, 22


; Call fortran subroutine
; -----------------------
SPAWN, 'mcd_get'
SPAWN, '\rm idl2fort.asc'


; Reading output
; --------------
OPENR, 23, "fort2idl.asc" ,/DELETE


; modified to get surface temperature and additional field
; A. Spiga, november 2006
t=DblArr(nz)
data=DblArr(2)
temp=DblArr(ncoord,nz,/nozero)
field=DblArr(ncoord,/nozero)
Tsurf=DblArr(ncoord,/nozero)

FOR icoord=0L, ncoord-1 DO BEGIN
    READF, 23, t
    temp[icoord,*] = t
    READF, 23, data
    Tsurf[icoord]=data[0]
    field[icoord]=data[1]
ENDFOR
READF, 23, Lsolar
READF, 23, localtime
close, 23

END
