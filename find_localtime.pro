pro find_localtime, ltst, lmst, ls, date, longitude
                    
;***
; PURPOSE : Find the localtime from julian date (LTST)
;
; INPUT : a julian date and an east longitude (0 if UTC)
;
; OUTPUT : a value of LTST in martian hours
;          a value of LMST in martian hours [0,24]
;	       a value of Ls in degrees [0,360]
;
; REFERENCE : see mars_time.pdf
;
; WARNING : need of procedure 'find_ls'
;
; EXAMPLE : 'find_localtime, ltst, lmst, ls, 2442765.667, 41.5' >>>> give localtime (and ls) corresponding to julian date at 41.5 degrees east longitude	
;
; AUTHOR :
; A. Spiga - May 2006
; from Fortran routines by E. Millour - April 2006
;***

earth_day = 86400
martian_day = 88775.245 ; number of seconds in a sol (martian day)
n_s = 668.6 ; number of sols in a martian year
ls_perihelion = 250.99 ; perihelion date (in deg)
t_perihelion = 485.35 ; perihelion date (in sols)
a = 1.52368 ; semi-major axis of orbit (in AU)
e = 0.09340 ; orbital eccentricity
epsilon = 25.1919 ; obliquity of equator to orbit (in deg)

; 1. Example of reference date and time : 01-01-1976 at 000:00:00
jd_ref = 2442778.5
lmt_ref = 16.1725
; 2. Local mean time at longitude 0 in martian hours for a given julian date 
lmt0 = (lmt_ref + 24*(date - jd_ref)*earth_day/martian_day) mod 24
; 3. Equation of time EOT in martian hours, for a given aerocentric solar longitude date Ls
find_ls, sol, ls, date
eot = (2*e*sin((ls - ls_perihelion)*!pi/180.)-sin(2*ls*!pi/180.)*(tan(epsilon*!pi/(2*180.)))^2)*24 / (2*!pi)
;4 Local mean solar time at longitude lonE in martian hours
lmst = (lmt0 + longitude/15) mod 24
; 5. Local true solar time at longitude lonE in martian hours
ltst = lmst - eot

end
