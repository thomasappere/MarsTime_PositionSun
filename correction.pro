pro correction, jdat, specmars, tab, reflectance
;procedure permettant de corriger la composante atmospherique du spectre
;jdat, specmars sont donnes par readomega



lambdaMax = 255
lambdaMax2 = 155

tab = jdat[*,0:lambdaMax,*]

imax = N_elements(tab[*,0,0])
nmax = N_Elements(tab[0,0,*])

for i=0,imax-1 do begin 
  for n=0,nmax-1 do begin 
    case reflectance of
    	0: tab(i,0:lambdaMax2,n)=tab(i,0:lambdaMax2,n)  ; radiance
    	1: tab(i,0:lambdaMax2,n)=tab(i,0:lambdaMax2,n)/specmars[0:lambdaMax2]  ; réflectance
    endcase
  endfor
endfor

pente=reform(tab(*,26,*)/tab(*,114,*))
alti=reform(alog(tab(*,75,*)/tab(*,68,*))+alog(pente)*0.0909)


atmorap=fltarr(256)
openr,2,'atmorap.dat'
readf,2,atmorap
close,2
expos=alti/alog(atmorap(76)/atmorap(68))


for i=0,imax-1 do begin 
    for n=0,nmax-1 do begin 
      tab(i,0:lambdaMax,n)=tab(i,0:lambdaMax,n)/(atmorap[0:lambdaMax]^expos(i,n)) 
  endfor
endfor




END
