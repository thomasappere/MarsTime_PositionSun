device, true_color=24, decomposed=0

common plotttitle, nomfichier
common winds, u, v
common largeplot, xcorr
common blank, tracelim, temp_yes, time, locx
common window_nb, win
common where_put, images
common dim, imax, jmax

; ************************************
images = './'
correction = 0   ; correction optionnelle sur les images couleur
correction = 1   ; correction optionnelle sur les images couleur
; ************************************



; ************************************
; 0. Lecture du fichier de controle  |
; ************************************
message, '0. Lecture du fichier de controle', /continue

nomfichier='' & temp_yes = 0. & band = 0.
openr,2,'map_def'
	readf,2, nomfichier 
	readf,2, zoneB 
	readf,2, zoneH 
	readf,2, zoneL 
	readf,2, zoneR
	readf,2, temp_yes 
	readf,2, uv_yes 
	readf,2, xcorr
	readf,2, tracelim &
	readf,2, band 
	readf,2,topo 
	readf,2,postscript
close,2

; initialisation d'autres parametres
already_color = 0 & no_palette = 0


; ****************************************
; 1. Lecture des fichiers de sauvegarde  |
; ****************************************
message, '1. Lecture des fichiers de sauvegarde', /continue

if (uv_yes ne 0) then begin            
	; si on desire superposer des vecteurs
	; il faut un champ u et v
	; uv_yes correspond au niveau vertical par exemple
endif

; >> A) tableau personalise
if (temp_yes eq 0) then begin  
    ; charger des champs ....		
    ; puis remplir le champ temp 	
    ; ne pas oublier le geocube

;;*** THERMIQUE    
;restore, filename='OMEGA_DATA/therm0313_4.sav'
;temp = therm
;;temp = therm[30:70,005:115]
;;      print, max(temp), min(temp) & stop
;;radiance_omega, 4.3, yeah, lambda, 0, lambda2, 1, geocube, 0^M
;restore, filename='OMEGA_DATA/ORB0313_4.spectra_L'^M
;geocube = geocube[*,*,0:n_elements(therm(0,*))-1]^M


restore, filename='thermOMEGA_0278_3.sav'
temp = THERMOMEGA
restore, filename='/d5/aslmd/OMEGA/ORBITES/ORB0278_3.param'

restore, filename='masque3_0278_3.sav'
w=where(temp le 273.)
temp[w] = 0;!Values.F_NAN
w=where(temp ge 277.)
temp[w] = 0;!Values.F_NAN
w=where(MASQUE3 eq 0.)
temp[w] = !Values.F_NAN



;*** OZONE
	;radiance_omega, [23,25,24], moyenne_spectre, lambda, 0, lambda2, 0, geocube, 2
	;ratio = 2*moyenne_spectre[*,*,2] / (moyenne_spectre[*,*,0] + moyenne_spectre[*,*,1])
	;
	;radiance_omega, [23,25,24,22,26], moyenne_spectre, lambda, 0, lambda2, 0, geocube,2 
	;ratio = 4*moyenne_spectre[*,*,2] / (moyenne_spectre[*,*,0] + moyenne_spectre[*,*,1] + moyenne_spectre[*,*,3] + moyenne_spectre[*,*,4])	
	;
	;radiance_omega, [23,25,24,22,26,21,27], moyenne_spectre, lambda, 0, lambda2, 0, geocube,2 
	;ratio = 6*moyenne_spectre[*,*,2] / (moyenne_spectre[*,*,0] + moyenne_spectre[*,*,1] + moyenne_spectre[*,*,3] + moyenne_spectre[*,*,4]$
	;	+ moyenne_spectre[*,*,5] + moyenne_spectre[*,*,6] )
	;
	;radiance_omega, [23,25,24], moyenne_spectre, lambda, 0, lambda2, 0, geocube, 2
	;ratio = (moyenne_spectre[*,*,2])^2 / (moyenne_spectre[*,*,0]*moyenne_spectre[*,*,1])
	;ratio = sqrt(ratio)
	;
	;radiance_omega, [23,25,24,22,26], moyenne_spectre, lambda, 0, lambda2, 0, geocube,2 
	;ratio = moyenne_spectre[*,*,2]^4 / (moyenne_spectre[*,*,0]*moyenne_spectre[*,*,1]*moyenne_spectre[*,*,3]*moyenne_spectre[*,*,4])
	;ratio = sqrt(sqrt(ratio)) 

;radiance_omega, [23,25,24,22,26,21,27], moyenne_spectre, lambda, 0, lambda2, 0, geocube,2 
;ratio = moyenne_spectre[*,*,2]^6 / (moyenne_spectre[*,*,0]*moyenne_spectre[*,*,1]*moyenne_spectre[*,*,3]*moyenne_spectre[*,*,4]*moyenne_spectre[*,*,5]*moyenne_spectre[*,*,6])
;ratio = sqrt(sqrt(sqrt(ratio))) 
;temp = ratio

;;*** THERMIQUE MCD
;restore, filename='/d5/aslmd/OMEGA/ORBITES/ORB3316_4.param'
;out = mcd_get_temp(geocube)
;temp=out(*,*,0)

;restore, filename='/d5/aslmd/OMEGA/ORBITES/ORB3316_4.param'
;restore, filename='/d5/aslmd/OMEGA/ORBITES/ORB3316_4.pres'
;temp=pressure

;;;*** CO2 band
;;radiance_omega, [65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,89], co2_band, lambda, 0, lambda2, 0 ,geocube, 2
;;temp = co2_band[*,*,band]
;radiance_omega, [band], co2_band, lambda, 0, lambda2, 0, geocube, 2
;temp = reform(co2_band)

endif else begin

; >> B) image couleur
if (temp_yes gt 90) then begin
    ; correction de phase (ameliore parfois le contraste)
     	if (correction eq 1) then print, 'correction !'
    ; generation des triplets visibles
	rgb_generate, nomfichier, R, G, B, geocube, correction
    ; tableaux de zoom 
        zoom1 = R & zoom2 = G & zoom3 = B
        zoom_ok = R / (R+B)
	print, 'max: ', max(zoom_ok)
	print, 'min: ', min(zoom_ok)
	print, 'median: ', median(zoom_ok)
	print, 'mean: ', mean(zoom_ok)
	
    ; suppression des pixels de calibration
	calib = 20
	if (zoneB le calib) then zoneB = calib
	rogne = n_elements(R[0,*])-10
	if (zoneH eq 0) or (zoneH gt rogne) then zoneH = rogne
endif else begin

; >> C) carte avec une seule variable
    already_title = 0
    ; >> C1) NUAGES OMEGA
      if (temp_yes eq 41) then begin    
	radiance_omega, [40,41,26,55], moyenne_spectre, lambda, 0, lambda2, 0, geocube, 2
   	eau = sqrt((moyenne_spectre[*,*,0]*moyenne_spectre[*,*,1])/(moyenne_spectre[*,*,2]*moyenne_spectre[*,*,3]))
	temp = 100 * (eau - 0.97) / (1.25 - 0.97) > 15
		;** old stuff better ?
		lim = 29 & ratio = (eau - 0.97) / (1.25 - 0.97) & ratio = ratio * 254
		temp = ratio > lim < 50
		temp[0,0] = lim & temp[0,1] = 70 & temp = bytscl(lim - temp)  ; blanc pour ice, noir pour rien
	temp=float(temp)-255
	print, temp
	already_title = 1 & title = 'Clouds (1.5 microns band test)' & com8 = 'CLOUD_IR'
        loadct, 3 & gamma_ct, 0.68 & already_color=1 & no_palette=1
      endif
    ; >> C2) REFLECTANCE
      if (temp_yes le 40) then radiance_omega, temp_yes, temp, lambda, band, lambda2, 1 ,geocube, 0
    ; >> C3) ALBEDO ET/OU TOPOGRAPHIE
      if (temp_yes eq 50) then begin
        radiance_omega, 0.4, albedo, lambda, 0.9, lambda2, 1, geocube, 0
		angl_inc = reform(geocube[*,8,*]) & angl_inc_abs = reform(geocube[*,2,*])
		mu0ground_ = cos(!pi/180.*angl_inc*1d-4) & mu0_ = cos(!pi/180.*angl_inc_abs*1d-4)
	temp = mu0ground_*(albedo / mu0_)
	already_title = 1 & title = 'ALBEDO' & com8 = 'ALBEDO'
      endif
    ; >> C4) TEST WANG AND INGERSOLL
      if (temp_yes eq 51) then begin
        rgb_generate, nomfichier, R, G, B, geocube, 0
		angl_inc = reform(geocube[*,8,*]) & angl_inc_abs = reform(geocube[*,2,*])
		mu0ground_ = cos(!pi/180.*angl_inc*1d-4) & mu0_ = cos(!pi/180.*angl_inc_abs*1d-4)
	temp = 100 * B / (R+B) ;(R+G+B)
	temp = mu0_ * temp
	limit = median(temp) + abs(mean(temp) - median(temp)) ;limite automatisée 
	temp = temp - limit > 0
		already_color=1 & loadct, 1, /silent & gamma_ct, 0.22
		already_title = 1 & title = 'Clouds (Blue and Red test)' & com8 = 'CLOUD_VIS' & no_palette=1
      endif
    ; >>> ABANDON DES PIXELS INUTILES DE CALIBRATION
      if (temp_yes ge 50) then begin
	calib = 20 & if (zoneB le calib) then zoneB = calib
	rogne = n_elements(temp[0,*])-10 & if (zoneH eq 0) or (zoneH gt rogne) then zoneH = rogne
      endif
      temp = reform(temp)	
endelse
endelse


; ************************************
; 2. Redimensionnement des tableaux  |
; ************************************
message, '2. Definition de la zone', /continue

; Avant toute modification ...
time = Reform(geocube[*,1,0])

; Taille globale des tableaux
need_size = reform(geocube(*,0,*))
s = size(need_size, /Dimensions) & imax = s[0] & jmax = s[1]
iglob = imax & jglob = jmax & print, nomfichier, iglob, jglob

; Redimensionnement eventuel
zoneH = round(zoneH) & zoneB = round(zoneB) 
zoneL = round(zoneL) & zoneR = round(zoneR)
if (zoneH + zoneB + zoneL + zoneR ne 0) then begin
	
	; nouvelles limites
	if (zoneL + zoneR eq 0) then begin
		ilim = imax
		zoneL = 0 
		zoneR = n_elements(need_size[*,0])-1
	endif
	if (zoneH + zoneB eq 0) then begin
		jlim = jmax
		zoneB = 0
		zoneH = n_elements(need_size[0,*])-1
	endif
	jlim = zoneH - zoneB + 1 & ilim = zoneR - zoneL + 1

print, zoneL, zoneR, zoneB, zoneH
if (temp_yes gt 90) then begin
zoom1 = zoom1[zoneL:zoneR,zoneB:zoneH]
zoom2 = zoom2[zoneL:zoneR,zoneB:zoneH]
zoom3 = zoom3[zoneL:zoneR,zoneB:zoneH]
endif else begin
temp = temp[zoneL:zoneR,zoneB:zoneH]
endelse

geocube = geocube[zoneL:zoneR,*,zoneB:zoneH]
imax = ilim & jmax = jlim & print, 'nouvelles dimensions ', imax, jmax
endif
; Informations utiles
locx = median(geocube[*,6,*]*1e-4)
print, 'pixel (0,0) longitude et latitude :   ', $
	geocube(0,13,0)*1e-4, geocube(0,17,0)*1e-4
print, 'pixel (imax,jmax) longitude et latitude :   ', $
	geocube(imax-1,13,jmax-1)*1e-4, geocube(imax-1,17,jmax-1)*1e-4


; *******************
; Trace des courbes |
; *******************
if (temp_yes ne 0) then begin
message, '3. Trace des cartes', /continue

; >> A) carte couleur
if (temp_yes gt 90) then begin
if (postscript eq 1) or (temp_yes eq 999) then begin
        R = zoom1 & G = zoom2 & B = zoom3 
	rgb_plot, temp_yes, band, R, G, B, temp, color
	already_color=1
	;TV, temp
	carte8 = temp
	title = 'Recomposed visible image'
	com8 = 'VIS_' + color
endif else goto, screen_plot
endif else begin

; >> B) autre carte
; titre
if (already_title eq 0) then begin
	lstring = STRTRIM(lambda,2) & l2string = STRTRIM(lambda2,2)
	llstring = STRTRIM(temp_yes,2) & ll2string = STRTRIM(band,2)
	title = 'Reflectance at ' + lstring + ' microns'
	if (band ne 0) then title = 'Mean reflectance between ' + lstring + ' and ' + l2string + ' microns '
	com8 = llstring
	if (band ne 0) then com8 = llstring+'_'+ll2string
endif
endelse

; >> trace
carte8 = temp
map_trace,carte8,geocube,title,file=nomfichier+'carte8_'+com8+'.ps', uv=uv_yes, already_color, no_palette, topo
goto, noplot
endif


; >> POSTSCRIPT
if (postscript eq 1) then begin

; *** Carte avec/sans vent
; pour une raison inconnue, map_trace refuse de tracer deux fois de suite les vents
  carte_w = temp
  title_w = 'Carte perso'
  file_w = nomfichier+'_carte'+'.ps'
  color=33	
  	already_title = 1 & title_w = 'Apparent ozone abundance (O2 1.27 microns dayglow)' 
        file_w = nomfichier+'_ozone'+'.ps'		
	color=9 ;19
  loadct, color & already_color = 1 ;& gamma_ct, 1.6
  map_trace,carte_w,geocube,title_w,file=file_w, uv=uv_yes, already_color, no_palette, topo

; *** Cartes sans vent
  loadct, 16 & already_color = 1
   ; etc etc
  goto, noplot	


; >> AFFICHAGE ECRAN
endif else begin
screen_plot:
no_palette = 1  ; l'affichage des palettes est problematique dans ce mode

; >> 1. Cartes couleur
if (temp_yes gt 90) then begin
R = zoom1 & G = zoom2 & B = zoom3
	; red image
	rgb_plot, 91, band, R, G, B, out, color
	already_color=1
	carte_G = out & title_G = 'Recomposed visible image'
	win = 0
	map_trace,carte_G,geocube,titre_G,uv=0,already_color,no_palette,0
R = zoom1 & G = zoom2 & B = zoom3
        ; blue image
	rgb_plot, 92, band, R, G, B, out, color
	already_color=1
	carte_M = out & title_M = 'Recomposed visible image'
	win = 1
	map_trace,carte_M,geocube,titre_M,uv=0,already_color,no_palette,0
R = zoom1 & G = zoom2 & B = zoom3
        ; color image
	rgb_plot, 99, band, R, G, B, out, color
	already_color=1
	carte_D = out & title_D = 'Recomposed visible image'
	win = 2
	map_trace,carte_D,geocube,titre_D,uv=0,already_color,no_palette,0
endif else begin
; >> 2. Cartes perso
carte1 = temp*1e5
carte2 = temp*1e5
carte3 = temp*1e5
carte_G = carte1 & titre_G = 'Carte perso 1'
carte_M = carte2 & titre_M = 'Carte perso 2'
carte_D = carte3 & titre_D = 'Carte perso 3'

; parametrer si besoin
color_G = 16 & color_M = 16 & color_D = 33
topo_G = 0 & topo_M = 0 & topo_D = topo
uv_G = 0 & uv_M = 0 & uv_D = uv_yes

; >>> fenetre gauche
win = 0 & loadct, color_G & already_color = 1
map_trace,carte_G,geocube,titre_G,uv=uv_G,already_color,no_palette,topo_G
; >>> fenetre milieu
win = 1 & loadct, color_M & already_color = 1
map_trace,carte_M,geocube,titre_M,uv=uv_M,already_color,no_palette,topo_M
; >>> fenetre droite
win = 2 & loadct, color_D & already_color = 1
map_trace,carte_D,geocube,titre_D,uv=uv_D,already_color,no_palette,topo_D

endelse
goto, noplot
endelse
noplot:

print, 'Done !'
end


