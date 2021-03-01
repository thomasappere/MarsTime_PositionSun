pro rgb_generate, nomfichier, R, G, B, geocube, correction

;***
; PURPOSE : computing RGB triplet derived from received radiances
;
; INPUT : title of OMEGA session (and .NAV & .QUB available)
;
; OUTPUT : R, G, B values & geocube
;
; REFERENCES :
; http://marswatch.astro.cornell.edu/pancam_instrument/projects_1.html
; http://www.cvrl.org/database/data/cmfs/ciexyz31_1.txt
; http://members.cox.net/astro7/color.html
;
; AUTHOR :
; A. Spiga - April 2006	 
;***	 

; 0. Choix d'un intervalle
	; ne pas prendre une seule longueur d'onde 
	; pour eviter bruit et spectels morts	
	
	; Spirit PANCAM (L4, L5, L6)
	;B_l = [0.467, 0.492] &	G_l = [0.52, 0.54] & R_l = [0.59, 0.61]
	; (autres possibilites : SPOT, LANDSAT, MARCI)

; equivalent : avec les spectels suivants ...	
wvl = [270,271,272,273,277,278,279,280,286,287,288,289]
	
; 1. what we get is the radiance received by the satellite
; >>> radiometric correction already included in readomega
		;radiance_omega, B_l[0], B, lambda, B_l[1], lambda2, 0, mute, 0 
		;radiance_omega, G_l[0], G, lambda, G_l[1], lambda2, 0, mute, 0 
		;radiance_omega, R_l[0], R, lambda, R_l[1], lambda2, 0, geocube, 0 
	; plus rapide !!
	radiance_omega, wvl, moyenne_spectre, lambda, 0, lambda2, 0, geocube, 2
	B = reform(moyenne_spectre(*,*,0) + moyenne_spectre(*,*,1) + moyenne_spectre(*,*,2) + moyenne_spectre(*,*,3)) /4
	G = reform(moyenne_spectre(*,*,4) + moyenne_spectre(*,*,5) + moyenne_spectre(*,*,6) + moyenne_spectre(*,*,7)) /4
	R = reform(moyenne_spectre(*,*,8) + moyenne_spectre(*,*,9) + moyenne_spectre(*,*,10) + moyenne_spectre(*,*,11)) /4

	
	if (correction ne 0) then begin 
		; !!! PROVISOIRE : inclusion fonction Henyey-Greenstein	
		; >>> correction angle de phase (!! bricolage)
		nx = n_elements(R[*,0]) & ny = n_elements(R[0,*]) &  c_gamma = fltArr(nx,ny)
		c_gamma(*,*) = cos(!pi - !pi/180.*geocube[*,10,*]*1d-4) 
		g = 0.99
		hg = (1.-g^2.)/(1.+g^2.-2.*g*c_gamma)^1.5 ;calcul de fonction Henyey Greenstein
		R = R * hg & G =  G * hg & B = B * hg
	endif


; 2. compute X Y Z system (values for SPIRIT) 
;    >>> photometric correction
	X = 1.0622*R + 0.1655*G + 0.09564*B
	Y = 0.631*R + 0.862*G + 0.13902*B
	Z = 0.008*R + 0.04216*G + 0.8129501*B 	

; 3. go to sRGB tristimulus space (as an eye would see)
	R = 3.2410*X - 1.5374*Y - 0.4986*Z
        G = -0.9692*X + 1.8760*Y + 0.0416*Z
	B = 0.0556*X - 0.2040*Y + 1.0570*Z	

end


