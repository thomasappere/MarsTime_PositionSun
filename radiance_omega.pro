pro radiance_omega, wvl, moyenne_spectre, lambda, band, lambda2, reflectance, out, tab

; wvl : - la longueur d'onde desiree (ou borne inferieure dans le cas d'un intervalle)
;       - si tab est active, il faut remplir le tableau des lambda ou des spectels
; moyenne_spectre : le spectre obtenu au final (absolu ou moyenne sur l'intervalle des longueurs d'onde)
; lambda : la longueur d'onde lue
; band : 0 ou borne superieure dans le cas d'un intervalle
; lambda2 : la deuxieme longueur d'onde
; reflectance : 0 pour une radiance, 1 pour une reflectance
; out : variable en sortie (par défaut le geocube)
; tab : flag pour rentrer un tableau de longueurs d'onde prescrites (1) ou de spectels (2)

; Auteur : A. Spiga - Mars 2006


common plotttitle, nomfichier


; *************** Reglages
whereami = './'
directory = 'OMEGA_DATA/' ;whereami
save_flag = 1 ; 0 obligatoire si version demo IDL ou peu d'espace disque  
	      ; 1 pour sauver les données extraites (et aller plus vite ensuite)		

;lim_when = 1999  ; borne superieure des orbites considerees
lim_when = 999
; ***************



nomfichier='' & openr,2, whereami+'map_def' & readf,2, nomfichier & close,2


; 1. QUEL SPECTEL CHOSIR ?

; ouverture du tableau des longueurs d'ondes d'OMEGA
openr,lun,whereami+'lambda_352_01.txt',/get_lun
xo=dblarr(352) & readf,lun,xo & free_lun,lun

; placement sur l'indice de spectel correct
if (tab eq 0) then begin
	indice = where(abs(xo-wvl) eq min(abs(xo-wvl)))
	indice = indice[0] & print, 'spectel ', indice
	lambda = xo(indice)
	n = 1
endif else begin
	n = n_elements(wvl)
	lambda = dblarr(n) & indice_tab = dblarr(n)
	for i = 0, n-1 do begin
	       case tab of
	       1: indice = where(abs(xo-wvl[i]) eq min(abs(xo-wvl[i])))
               2: indice = [wvl[i]]
	       endcase
	       indice = indice[0]
	       lambda[i] = xo(indice) & indice_tab[i] = indice
        endfor
	print, indice_tab
	print, lambda
	band = 0
endelse

; Spectels to avoid
; 	dead since ground calibration : 158, 78
; 	dead since orbit 171 : 34
; 		*** correction done in readcube (interpolation)
; 	very hot since the beginning : 69, 88, 224
; 	very hot since orbit 1147 : 188
; 	very hot since orbite 1990 : 155
; 		*** not reliable
; 	moderately hot since orbit 2000 : 55, 66, 79, 85, 121, 127, 200, 222
; 		*** careful : need probably correction


avoid = [34,55,66,69,78,79,85,88,121,127,155,158,188,200,222,224]
when = [171,2000,2000,0,0,2000,2000,0,2000,2000,1990,0,1147,2000,2000,0]
try_again:
w = where((avoid*(when lt lim_when)-indice) eq 0)
if (w ne -1) then begin
	print, indice, 'Avoid this spectel ! I choose the next one ...'
	indice = indice + 1
	goto, try_again
endif

; cas d'une bande de longueur d'onde ...
lambda2 = 0.
if (band ne 0) then begin
        ecart = xo-band
	; pour eviter les recouvrements entre canaux Omega
	ecart = ecart(indice:n_elements(xo)-1)
	indice2 = where(abs(ecart) eq min(abs(ecart)))
        indice2 = indice2[0] + indice
	lambda2 = xo(indice2)
	print, '... to spectel ', indice2
endif

; type de voie omega
if (indice le 128) then begin
	voie = '.spectra_C' & flag = 1
endif else begin
	if (indice le 256) then begin
		voie = '.spectra_L' & flag = 2
	endif else begin
		voie = '.spectra_V' & flag = 3
	endelse
endelse

; 2. SPECTRE A CHARGER OU A CALCULER
test = 0 & openr, 2, directory+nomfichier+voie, ERROR=test & close, 2
if (test ne 0) then begin
		print, 'Spectra need to be retrieved first from .QUB !'
		CD, Current=Old, whereami+'SOFT03'
		nomfic = nomfichier
		if (flag eq 3) then $
		readomega, nomfic, specmars, geocube, jdat,0 else $
		readomega, nomfic, specmars, geocube, jdat,1
			; le geocube est gros !
			case flag of
			1: ; nothing to do
			2: geocube[*,6:20,*] = geocube[*,21:35,*]
			3: geocube[*,6:20,*] = geocube[*,36:50,*]
			endcase
			geocube = temporary(geocube[*,0:20,*])
		CD, Old
		if (save_flag eq 1) then save, specmars, geocube, jdat, filename=directory+nomfichier+voie
		out = geocube
endif else begin
		print, 'Spectra already retrieved ! '
		restore, filename=directory+nomfichier+voie
		out = geocube
endelse


; 3. RADIANCE ou REFLECTANCE POUR LE SPECTEL CHOISI

; !!! correction de l'atmosphere (d'apres Yves Langevin)(écrit dans le cas d'une reflectance)
flag=3
if (flag ne 3) then correction, jdat, specmars, tab, reflectance
; !!!
; NB : le faire aussi pour le visible ? (pas bcp d'influence ...)

nx = N_Elements(jdat[*,0,0])
ny = N_Elements(jdat[0,0,*])
moyenne_spectre = FltArr(nx,ny)
n_dead = 0 ; nombre de pixels morts ou defectueux
; PLUSIEURS SPECTELS (MOYENNE)
if (band ne 0) then begin
	width = indice2-indice+1
	spectre = FltArr(nx,width, ny)
FOR i=0, width-1 DO BEGIN
	w = where((avoid*(when lt lim_when)-(indice+i)) eq 0) ;test spectel mort
	if (w ne -1) then begin
		spectre[*,i,*] = 0
		n_dead = n_dead + 1
		print, 'bad spectel : ', indice+i
	endif else begin
		if (flag eq 3) then begin
			case reflectance of
			0 : spectre[*,i,*] = float(jdat[*,indice+i,*])  ;radiance
			1 : spectre[*,i,*] = float(jdat[*,indice+i,*]/specmars[indice+i]) ;reflectance
			endcase
		endif else spectre[*,i,*] = float(tab[*,indice+i,*])  ; radiance ou reflectance selon le resultat de la correction

	endelse
ENDFOR

FOR i = 0, nx-1 DO FOR j = 0, ny-1 DO moyenne_spectre(i,j) = total(spectre[i,*,j])/(width-n_dead)

; UN SEUL SPECTEL
endif else begin
if (n le 1) then begin	; une seule valeur
	if (flag eq 3) then begin
	  case reflectance of
	  0 : moyenne_spectre = float(jdat[*,indice,*])  ;radiance
	  1 : moyenne_spectre = float(jdat[*,indice,*]/specmars[indice]) ;reflectance
	  endcase
	endif else moyenne_spectre = float(tab[*,indice,*])  ; radiance ou reflectance selon le resultat de la correction

endif else begin  ; une serie de valeurs
	moyenne_spectre = fltarr(nx,ny,n)
	FOR i=0, n-1 DO BEGIN
	        if (flag eq 3) then begin
	          case reflectance of
	            0 : moyenne_spectre[*,*,i] = float(jdat[*,indice_tab[i],*])  ;radiance
	            1 : moyenne_spectre[*,*,i] = float(jdat[*,indice_tab[i],*]/specmars[indice_tab[i]]) ;reflectance
	          endcase
	        endif else moyenne_spectre[*,*,i] = float(tab[*,indice_tab[i],*])  ; radiance ou reflectance selon le réesultat de la correction

	ENDFOR
endelse
endelse

end
