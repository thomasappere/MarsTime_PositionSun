pro rgb_plot, temp_yes, band, R, G, B, temp, color

;***
; PURPOSE : Intermediate routine to prepare RGB plot
;
; INPUT : - temp_yes : control variable
;         - band : luminosity control parameter
;         - R, G, B : triplet of corrected color values
;
;
; OUTPUT : - 2D temp field ready for tracecarte.pro
;	   - (or) 24 bits JPEG image
;	   - color title
;
; AUTHOR :
; A. Spiga - April 2006
;***


; color correction
coeff = 0.3   ;NB : 0.5 for Valles Marineris 
;coeff = 0.5
coeff = 0.2
print, 'color correction ... ', coeff

; NB : dans toutes les operations
; ne pas briser la repartition relative des couleurs !

	; fausses couleurs dans le cas ou un pixel est defectueux
	;R = 100 * R / (R + G + B)
	;B = 100 * B / (R + G + B)
	;G = 100 * G / (R + G + B)

;R[0,0] = 72.1
;R[0,1] = 114
;; dust storm on 1201 and 1212
	
nb_color = 256
print, 'red ', min(R), max(R)
print, 'blue ', min(B), max(B)
print, 'green', min(G), max(G)

;; corrective factor (homothetia)
;; (pictures are too blue and not red enough)
red_change = 1 + coeff 
green_change = 1
blue_change = 1 - coeff 

; scale on a [0,255] pixel tab
red_scaled = BytScl(R, Top=nb_color-1) * red_change < 255
green_scaled = BytScl(G, Top=nb_color-1) * green_change < 255
blue_scaled = BytScl(B, Top=nb_color-1) * blue_change < 255

; reference black and white pixels
red_scaled[0,0] = 0 & blue_scaled[0,0] = 0 & green_scaled[0,0] = 0
red_scaled[0,1] = 255 & blue_scaled[0,1] = 255 & green_scaled[0,1] = 255

; possible luminosity correction
if (band ne 0) then begin
red_scaled = (red_scaled + band) < 255 > 0
green_scaled = (green_scaled + band) < 255 > 0
blue_scaled = (blue_scaled + band) < 255 > 0
endif

; ******** 24_bits TRUE COLOR image not referenced
if (temp_yes gt 990) then begin

	s = size(red_scaled, /dimensions)
	r = Dblarr(256) & r = SORT(r)
	b = Dblarr(256) & b = SORT(b)
	g = Dblarr(256) & g = SORT(g)
	TVLCT, r, g, b

	red = r[red_scaled] & green = g[green_scaled] & blue = b[blue_scaled]

        image24 = BytArr(3, s[0], s[1])
	image24[0, *, *] = red
	image24[1, *, *] = green
	image24[2, *, *] = blue

	n = n_elements(image24[0,*,0])
	save_image24 = image24
	for i = 0, n-1 do image24[*,i,*]=save_image24[*,n-1-i,*]
	color = '24bits'

	; iTool IDL
	IIMAGE, image24
	stop

	; image JPEG
	;Write_JPEG, nomfichier+'_color.jpg', image24, True=1, Quality=230;75

	; image postscript
	;SET_PLOT, 'PS'
        ;DEVICE, FILE=nomfichier+'_color.ps', /COLOR, BITS=8
	;TV, image24, true=1
endif




; ******** 8 bits 256-COLOR image referenced

; 95 : BLACK AND WHITE (cf IDL web page Fanning Corp.)
if (temp_yes eq 95) then begin
	loadct, 0 & color='BW'
	temp = 0.3*red_scaled + 0.59*green_scaled + 0.1*blue_scaled
endif

; 91 : RED
if (temp_yes eq 91) then begin
	temp = red_scaled & loadct, 3 & color='red'
endif

; 92 : BLUE
if (temp_yes eq 92) then begin
        temp = blue_scaled & loadct, 1 & color='blue'
endif

; 93 : GREEN
if (temp_yes eq 93) then begin
	temp = green_scaled & loadct, 8 & color='green'
endif

; 99 : VISIBLE SIMULATED TRUE COLOR
if (temp_yes eq 99) then begin
	temp = COLOR_QUAN(red_scaled,green_scaled,blue_scaled,r,g,b,colors=256)
	TVLCT, r, g, b
	color='color'
endif

end


