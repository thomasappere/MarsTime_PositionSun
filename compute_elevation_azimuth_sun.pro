pro compute_elevation_azimuth_sun

;***
; PURPOSE : Find the elevation and azimuth of the sun for a given time in UTC
;
; INPUT : a value of Ls, latitude, longitude
;
; OUTPUT : a value of time in UTC
;
; REFERENCE : see mars_time.pdf
;
; WARNING : need of procedure 'julian', 'find_ls', 'find_localtime'
;
; EXAMPLE : 'compute_elevation_azimuth_sun' with UTC as 2012-09-21 08:03:55 >>>> LMST = 12:12:34.27, LTST=12:52:9.53
; elevation = 75.38 degrees, azimuth = 296.74 degrees
;
; AUTHOR :
; Thomas Appere - October 2016
; All the calculations of sun elevation and azimuth are based of the Mars 24 algorithm itself based on
; Allison, McEwen, Planetary ans Space Science 48 (2000) 215-235
; https://www.giss.nasa.gov/tools/mars24/help/algorithm.html
;***

;Constants
;obl = 25.189417 ; obliquity of the Martian orbit (in degree)
obl = 25.1919 ; obliquity of the Martian orbit (in degree) (value from MCD programs)

mission = ''
read, mission, prompt='Mission (MSL:1 / Mars2020:2 / Zhurong:3) : '

if mission eq '1' then begin
    latitude = -4.58947 ;latitude of Curiosity rover (in degree)
    longitude = 137.44164 ;longitude of Curiosity rover (in degree east)
    print, 'Place: Curiosity landing site'
endif

if mission eq '2' then begin
    latitude = 18.4447 ;latitude of Perseverance rover (in degree)
    longitude = 77.4508 ;longitude of Perseverance rover (in degree east)
    print, 'Place: Perseverance landing site'
endif

if mission eq '3' then begin
    latitude = 25.066 ;latitude of Zhurong rover (in degree)
    longitude = 109.925 ;longitude of Zhurong rover (in degree east)
    print, 'Place: Zhurong landing site'
endif

;Enter time of acquisition in UTC
;time=[year, month, day, hour, minute, seconde]
;By default
time=[1976, 1, 1, 0, 0, 0]
READ, year, PROMPT='Year='
READ, month, PROMPT='Month='
READ, day, PROMPT='Day='
READ, hour, PROMPT='Hour='
READ, minute, PROMPT='Minute='
READ, seconde, PROMPT='Seconde='

time=[year, month, day, hour, minute, seconde]
print, 'Time = ', time

;Calculation of Julian date
julian, time, date

;Calculation of localtime
find_localtime, ltst, lmst, ls, date, longitude
;print, 'Local time (LTST) = ', ltst
print, 'Ls = ', ls

;Conversion of localtime in hour, minutes, seconds
hour = floor(ltst)
minutes = (ltst - hour)*60.
seconds = (minutes - floor(minutes))*60.
print, 'Local True Solar Time (LTST) = ', hour, 'h ', floor(minutes), 'min ', seconds, 's'

hour2 = floor(lmst)
minutes2 = (lmst - hour2)*60.
seconds2 = (minutes2 - floor(minutes2))*60.
print, 'Local Mean Solar Time (LMST) = ', hour2, 'h ', floor(minutes2), 'min ', seconds2, 's'
;------------------------------------------------------------
; position of the sun (d : declination of the sun)

d=asin(sin(ls*!pi/180.)*sin(obl*!pi/180.))

;------------------------------------------------------------
;Hour angle
hour_angle = (ltst-12.)*!pi/12.

;Calculation of elevation beta (in degree)
beta = asin(cos(latitude*!pi/180.)*cos(d)*cos(hour_angle) + sin(latitude*!pi/180.)*sin(d))*180./!pi

print, 'Elevation of the sun (°) = ', beta

;Calculation of the azimuth (in degree east with North: azimuth=0°,
;East: azimuth=90°, South: azimuth=180°, West: azimuth=270°)
temp1 = cos(latitude*!pi/180.) * tan(d) - sin(latitude*!pi/180.) * cos(hour_angle)
temp2 = sin(hour_angle)
azimuth = atan(temp2, temp1)*180./!pi ;If 2 parameters are supplied, the ATAN function returns the angle, expressed in radians, whose tangent is equal to Y/X is returned. Result=ATAN(Y,X)

if azimuth lt 0. then azimuth = azimuth + 360.
azimuth = 360.-azimuth

print, 'Azimuth of the sun (with N=0°, E=90°, S=180°, W=270°) = ', azimuth
stop
end
