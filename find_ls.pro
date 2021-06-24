pro find_ls, sol, ls, date
                                                                                                                         
;***
; PURPOSE : Find the aerocentric longitude from martian day index (sol)
;
; INPUT : a value in sols or a julian date (if julian ne 0)
;
; OUTPUT : a value of Ls between [0,360] and a value in sols (if julian ne 0)
;
; REFERENCE : see mars_time.pdf
;
; WARNING : use of the function kepler.pro
;
; EXAMPLE : - 'find_ls, 300, ls, 0' >>>> give ls corresponding to sol=300
;	    - 'find_ls, sol, ls, 2442765.667' >>>> give ls and sol corresponding to julian date	
;
; AUTHOR :
; A. Spiga - May 2006
; from Fortran routines by E. Millour - April 2006
;***

common kepler, e, m 

earth_day = 86400
martian_day = 88775.245 ; number of seconds in a sol (martian day)
n_s = 668.6 ; number of sols in a martian year
ls_perihelion = 250.99 ; perihelion date (in deg)
t_perihelion = 485.35 ; perihelion date (in sols)
a = 1.52368 ; semi-major axis of orbit (in AU)
e = 0.09340 ; orbital eccentricity
epsilon = 25.1919 ; obliquity of equator to orbit (in deg)


; (opt) Convert Julian date to martian sol number 
; 	NB : martian sol date is number of sols elapsed 
;            since the beginning of martian year defined by Ls=0
if (date ne 0) then begin
julian_ref = 2442765.667
	; julian_ref is a reference julian date corresponding to a Ls=0 event
sol = (date - julian_ref)*earth_day/martian_day 
sol = sol mod n_s
endif

; 1. compute mean anomaly (rad)
m = 2*!pi*(sol-t_perihelion)/n_s 

; 2. compute eccentric anomaly (rad)
; >>> have to solve the Kepler's problem 
X = [-2*!pi,0,2*!pi]
ecc_anomaly = FX_ROOT(X, 'kepler', tol=1e-7)

; 3. compute true anomaly (rad)
fac = sqrt((1+e)/(1-e))
nu = 2*atan(fac*tan(ecc_anomaly/2))

; 4. compute ls (deg)
ls = ((nu*180/!pi) + ls_perihelion) mod 360
; comparing to Mars24, this algorithm has a .1 precision
;ls = 0.1*round(ls*10)

;print, 'sol', sol, '  ls', ls

end
