PRO map_trace, tab, geocube, titre, file=file, uv=uv_yes, already_color, no_palette, topo

;***
; PURPOSE : Mapping OMEGA data on Lat-Lon projection
;	    Dimensions of pixels are exactly plotted from the informations on the geocube
;
; INPUT : - tab : 2D array data to be mapped
;	  - geocube : OMEGA geo-reference
;	  - titre : title for the plot
;	  - (opt) file : name of file for outout
;	  - (opt) uv_yes : control variable for wind vectors
;	  - (opt) already_color : control variable for color palette
;
; OUTPUT : plot on the selected graphics device
;
; AUTHOR :
; B. Dolla - July 2005
; A. Spiga - October 2005 - April 2006 - June 2006
;***


common plotttitle, nomfichier
common winds, u, v
common largeplot, xcorr
common blank, tracelim, temp_yes, time, locx
common window_nb, win
common where_put, images
common dim, imax, jmax

;*************************************
; Variables de dimension utiles      |
;*************************************

; vrai minimum (possibilite avec tracelim de ne pas tracer certains points)
tab = reform(tab)
xmin = min(geocube[*,13:16,*], Max = xmax) & ymin = min(geocube[*,17:20,*], Max = ymax)
tabmax = max(tab) & print, tabmax
tabmin = min(tab*(tab gt tracelim) + (tab lt tracelim)*1e30) & print, tabmin

premier = 0

;********************************************************
; Definition et ajustement de la fenetre graphique      |
;********************************************************

beginn:
	; si besoin de faire plusieurs tests decommenter la ligne suivante
	; ainsi que la boucle finale
	;if (premier ne 0) then stop

; cas ou la couleur n'est pas deja definie dans map.pro !
if (already_color eq 0) then xloadct, /BLOCK

; ajustement automatique selon le type d'orbite
rapport = (ymax-ymin)/float(xmax-xmin)
yoff = 0;- 2* rapport

; sortie postscript
IF (N_Elements(file) NE 0) THEN BEGIN
    set_plot, 'ps'
    device, filename=images+file, /color, Bits_Per_Pixel = 8, Xoffset=6-xcorr, Yoffset=yoff
ENDIF

; sortie graphique ecran
IF (N_Elements(file) EQ 0) THEN BEGIN
    Xsize = 1000/rapport
    window, win, XSize=xsize, YSize=rapport*xsize, Xpos = win*xsize, YPos = 0
ENDIF ELSE BEGIN
    Xsize = 10 / rapport  ;2.5
    Device, Xsize = xsize, ysize = rapport*xsize, /inches
ENDELSE


;**********************************
; Trace du champ en argument      |
;**********************************

pixel = DblArr(2,4)

    FOR i=0, imax-1 DO BEGIN
        FOR j=0, jmax-1 DO BEGIN

            if (tab[i,j] gt tracelim) then begin

            ; coordonnees des quatres coins
	    pixel[0,0] = (geocube[i,13,j]-xmin)/float(xmax-xmin)
 	      pixel[1,0] = (geocube[i,17,j]-ymin)/float(ymax-ymin)
            pixel[0,1] = (geocube[i,14,j]-xmin)/float(xmax-xmin)
              pixel[1,1] = (geocube[i,18,j]-ymin)/float(ymax-ymin)
            pixel[0,2] = (geocube[i,15,j]-xmin)/float(xmax-xmin)
              pixel[1,2] = (geocube[i,19,j]-ymin)/float(ymax-ymin)
            pixel[0,3] = (geocube[i,16,j]-xmin)/float(xmax-xmin)
              pixel[1,3] = (geocube[i,20,j]-ymin)/float(ymax-ymin)

	    ; affichage couleur du champ considéré
	    color = (tab[i,j]-tabmin)/float(tabmax-tabmin)*255.
	    PolyFill, pixel[0,*]*0.6+0.38, pixel[1,*]*0.6+0.38, color = color, /Normal
	    ;; PolyFill, x, y

            endif
       ENDFOR
    ENDFOR




;****************************************************
; Trace des vents ou d'un champ vectoriel            |
; à lire avant et stocker dans les variables u et v |
;****************************************************

if (uv_yes ne 0) then begin

; Rentrer ici les niveaux verticaux
sigma = [0]

level = sigma[uv_yes-1]  
	;levelu = floor(level)
	;leveld = (round((level-levelu)*100)) ; keep precision 0.01 %

  ; preparation du tableau pour PARTVELVECT (mieux que reform)
  ; NB : le sens de remplissage des tableaux est choisi
  ;      de facon a ce que l'ecremage qui suit donne un champ
  ;      de vent lisible pour les orbites allongees OMEGA
      leap=0.
      nmax = imax * jmax
      posx = DblArr(nmax) & posy = DblArr(nmax) & velx = DblArr(nmax) & vely = DblArr(nmax)
      for j=0, jmax-1 do begin
        for i=0, imax-1 do begin
		    posy(i+leap)= ((geocube[i,20,j]-ymin)/float(ymax-ymin))*0.6+0.38
		    velx(i+leap)=u(i,j) & vely(i+leap)=v(i,j)
        endfor
        for n=0, imax-1 do begin
	            posx(n+leap)= ((geocube[n,13,j]-xmin)/float(xmax-xmin))*0.6+0.38
        endfor
	       leap=leap+imax
      endfor

; *** Regler ce paramètre pour tracer plus ou moins de vecteurs vent
sev=1000   ; on ne trace un vecteur vent que tous les 1000 pixels
; ***
   count = 0
   for i = 0L, n_elements(u)-1 do begin
	  if (count ne sev) then begin
	  velx(i) = 1e-10 & vely(i) = 1e-10 ; pour éviter les divisions par zéro
	  posx(i) = posx(0) & posy(i) = posy(0)
          count = count + 1
          endif else begin
	  count = 0.
          endelse
   endfor

endif

;**************************
; Trace des echelles      |
;**************************

;    scale = 0.2
    scale = 1.
    winds = ''

    ; titre
    if (temp_yes eq 0) then ytitle='Units' else ytitle=''

    ; reglages
    !P.Position = [0.38,0.38,0.98,0.98]
    !P.thick = 2;4

    ; palette de couleur a afficher
    if (temp_yes lt 98) and (no_palette ne 1) then begin
  	t = rebin((Indgen(256)),256,20)
    	t = transpose(t)
   	   TV, t, 0+0.2, 0.38, Xsize=0.03, Ysize=0.5, /normal
	   ;TV, t, -3., 0.38, Xsize=0.3, Ysize=0.5, /normal
	   ;xyouts, -3.2, 0.36, string(min(tab), '(F4.2)')
	   ;xyouts, -3.2, 0.90, string(max(tab), '(F4.2)')
    endif

    ; couleur des lignes
    loadct, 0, /silent
    if (N_Elements(file) EQ 0) then line_color=255 else line_color=0   
	; background in IDL window is black whereas background in PS files is white

    ; affichage des coordonnees temporelles
    	julian, time, date
    	find_ls, sol, ls, date
	find_localtime, localtime, ls, date, locx
    	ls = 0.1*round(ls*10) & localtime = 0.1*round(localtime*10)
    	temps = ' Ls ' + STRTRIM(ls,2) + ' Lt ' + STRTRIM(localtime,2)
    	winds = temps

    ; trace des vents
    if (uv_yes ne 0) then begin
	    levstring1 = STRTRIM(levelu,2)
	    levstring2 = ''
	    if (leveld ne 0) then levstring2 = '.'+STRTRIM(leveld,2)
	    winds = ' + GCM winds at sigma level '+ levstring1 + levstring2 + ' %'
	    ; utilisation de la fonction importee PARTVELVECT ... VELOVECT est capricieux !
	    partvelvec, velx, vely, posx, posy, /over   ;, length=0.15
    endif

    ; trace du quadrillage lat/lon et eventuellement de la topographie
    if (topo eq 0) then begin
    plot, [0,1,2], /nodata, YStyle=1, Xstyle=1, $
	    XRange=[xmin*1e-4, xmax*1e-4], YRange=[ymin*1e-4, ymax*1e-4], $
	    YGridstyle=1, YTICKLEN=1,xGridstyle=1, xTICKLEN=1, $
	    Yminor=1, Xminor=1,/noerase, $
	    Title=titre, Subtitle=nomfichier+winds, XTitle='East Longitude', Ytitle='North Latitude', $
	    color=line_color, xtickinterval=scale, Xcharsize=0.8, Ycharsize=0.8, ytickinterval=1.
    endif else begin
	Z = reform(geocube[*,12,*]/1000)
	X = reform(geocube[*,6,*]*1e-4) & Y = reform(geocube[*,7,*]*1e-4)
	Z = smooth(Z,4)
	level = 15 ;10 20
    contour, Z,X,Y, nlevels=level, c_labels=labels,/follow, YStyle=1, Xstyle=1, $
	    XRange=[xmin*1e-4, xmax*1e-4], YRange=[ymin*1e-4, ymax*1e-4], $
	    YGridstyle=1, YTICKLEN=1,xGridstyle=1, xTICKLEN=1, $
	    Yminor=1, Xminor=1,/noerase, $
	    Title=titre, Subtitle=nomfichier+winds, XTitle='East Longitude', Ytitle='North Latitude', $
	    color=line_color, xtickinterval=scale, Xcharsize=0.8, Ycharsize=0.8, ytickinterval=1.
    endelse

   ; encadrement palette de couleur
   if (temp_yes lt 98) and (no_palette ne 1) then begin
   plot, [0,0,0,0], XRange = [0.1,0.2], YRange=[tabmin, tabmax], /noerase, position=[0.+0.2,0.38,0.03+0.2,0.88], $
   	   Xstyle=1, YStyle=1, Yticks=4, Yminor=10, YTitle=ytitle, $
   	   Xticks=1, XTIckformat='(A1)', YTicklen=0.2, color=line_color
   endif


;***************
; Clôture      |
;***************

IF (N_Elements(file) NE 0) THEN BEGIN
    device, /close
    ;set_plot, 'x'
ENDIF

;if (temp_yes ne 0) then begin
;	premier = 1
;	goto, beginn
;endif

END
