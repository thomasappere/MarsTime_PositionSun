from math import *
import kepler

#***
# PURPOSE : Find the elevation and azimuth of the sun for a given time in UTC
#
# INPUT : a value of Ls, latitude, longitude
#
# OUTPUT : a value of time in UTC
#
# REFERENCE : see mars_time.pdf
#
# EXAMPLE : 'compute_elevation_azimuth_sun' with UTC as 2012-09-21 08:03:55 >>>> LMST = 12:12:34.27, LTST=12:52:9.53
# elevation = 75.51 degrees, azimuth = 296.94 degrees
#
# AUTHOR :
# Thomas Appere - October 2016
# All the calculations of sun elevation and azimuth are based of the Mars 24 algorithm itself based on
# Allison, McEwen, Planetary ans Space Science 48 (2000) 215-235
# https://www.giss.nasa.gov/tools/mars24/help/algorithm.html
#***

#Constants
obl = 25.1919 # obliquity of the Martian orbit (in degree)
earth_day = 86400
martian_day = 88775.245 #number of seconds in a sol (martian day)
n_s = 668.6 #number of sols in a martian year
ls_perihelion = 250.99 #perihelion date (in deg)
t_perihelion = 485.35 #perihelion date (in sols)
a = 1.52368 #semi-major axis of orbit (in AU)
e = 0.09340 #orbital eccentricity
epsilon = 25.1919 #obliquity of equator to orbit (in deg)

def julian(time):
    # PURPOSE : Find the julian date from time in UTC
    # INPUT : time in UTC as a list [year, month, day, hour, minute, seconde]
    # OUTPUT : value the julian date
    # EXAMPLE : 'julian([1976, 1, 1, 0, 0, 0]) >>>> returns julian date 2442778.5 (value by default) corresponding to UTC 1976/1/1 0:0:0
    month = [0,31,59,90,120,151,181,212,243,273,304,334]
    nday = month[time[1]-1] + time[2] - 1
    #traitement des annees bissextiles
    temp = 0
    if time[0] < 1582: temp = 1
    if time[0] == 1582 and time[1] < 10: temp = 1
    if time[0] == 1582 and time[1] == 10 and time[2] < 15: temp = 1

    if temp == 0:
        if ((time[0] % 4) == 0) and ((time[0] % 100) != 0) and (time[1] > 2): nday = nday+1
        if ((time[0] % 400) == 0) and (time[1] > 2): nday = nday+1

    if temp == 1:
        if (time[0] % 4) == 0 and (time[1] > 2): nday = nday+1
        nday = nday + 10 #les fameux dix jour manquants...

    if time[0] > 1968:
        xyear = [i + 1968 for i in range(time[0]-1968+1)]
        for j in range(len(xyear)-1):
            nday = nday + 365
            if ((xyear[j] % 4) == 0) and ((xyear[j] % 100) != 0): nday = nday + 1
            if ((xyear[j] % 400) == 0): nday = nday+1

    if time[0] < 1968:
        xyear = [i + time[0] for i in range(1968-time[0]+1)]
        temp = 1
        for j in range(len(xyear)-1):
            if xyear[j] >= 1582:
                temp = 0

            if temp == 0:
                nday = nday - 365
                if ((xyear[j] % 4) == 0) and ((xyear[j] % 100) != 0): nday = nday-1
                if ((xyear[j] % 400) == 0): nday = nday-1

            if temp == 1:
                nday = nday - 365
                if ((xyear[j] % 4) == 0): nday = nday-1

#correction du passage du calendrier gregorien au calendrier julien
#changement pris pour le 15 octobre 1582 (gregorien)
    a=2439856.5
    b=float(nday)
    c=time[3]/24.
    d=time[4]/1440.
    e=time[5]/86400.0
    return(a+b+c+d+e)

def find_ls(date):
    #PURPOSE : Find the aerocentric longitude from martian day index (sol)
    #INPUT : a value in sols or a julian date (if julian ne 0)
    #OUTPUT : a value of Ls between [0,360] and a value in sols (if julian ne 0)
    if date != 0:
        julian_ref = 2442765.667 #julian_ref is a reference julian date corresponding to a Ls=0 event
        sol = (date - julian_ref) * earth_day / martian_day
        sol = sol % n_s

    #1. compute mean anomaly (rad)
    m = 2 * pi * (sol - t_perihelion) / n_s

    #2. compute eccentric anomaly (rad)
    #>>> have to solve the Kepler's problem
    ecc_anomaly = kepler.solve(m, e)

    #3. compute true anomaly (rad)
    fac = sqrt((1 + e) / (1 - e))
    nu = 2 * atan(fac * tan(ecc_anomaly / 2))

    #4. compute ls (deg)
    ls = ((nu * 180 / pi) + ls_perihelion) % 360

    return(ls, sol)

def find_localtime(ls, date, longitude):
    #PURPOSE : Find the localtime from julian date (LTST)
    #INPUT : a julian date and an east longitude (0 if UTC)
    #OUTPUT : a value of LTST in martian hours
    #         a value of LMST in martian hours [0,24]

    #1. Example of reference date and time : 01-01-1976 at 000:00:00
    jd_ref = 2442778.5
    lmt_ref = 16.1725

    #2. Local mean time at longitude 0 in martian hours for a given julian date
    lmt0 = (lmt_ref + 24. * (date - jd_ref) * earth_day / martian_day) % 24

    #3. Equation of time EOT in martian hours, for a given aerocentric solar longitude date Ls
    eot = (2 * e * sin((ls - ls_perihelion) * pi / 180.) - sin(2 * ls * pi / 180.) * (tan(epsilon * pi/(2 * 180.)))**2)*24 / (2 * pi)

    #4 Local mean solar time at longitude lonE in martian hours
    lmst = (lmt0 + longitude / 15) % 24

    #5. Local true solar time at longitude lonE in martian hours
    ltst = lmst - eot

    return(ltst, lmst)

mission = ''
mission = input('Mission (MSL:1 / Mars2020:2 / Zhurong:3) ')
if mission=='1':
    latitude = -4.58947 #latitude of Curiosity rover (in degree)
    longitude = 137.44164 #longitude of Curiosity rover (in degree east)
    print('Place: Curiosity landing site')

if mission=='2':
    latitude = 18.4447 #latitude of Perseverance rover (in degree)
    longitude = 77.4508 #longitude of Perseverance rover (in degree east)
    print('Place: Perseverance landing site')

if mission=='3':
    latitude = 25.066 #latitude of Zhurong rover (in degree)
    longitude = 109.925 #longitude of Zhurong rover (in degree east)
    print('Place: Zhurong landing site')

#Enter time of acquisition in UTC
#By default
time = [1976, 1, 1, 0, 0, 0]

year = int(input('Year='))
month = int(input('Month='))
day = int(input('Day='))
hour = int(input('Hour='))
minute = int(input('Minute='))
seconde = int(input('Seconde='))

time=[year, month, day, hour, minute, seconde]
print('Time = '+str(time))

#Calculation of Julian date
date=(julian(time))

#Calculation of localtime
sol = find_ls(date)[1]
ls = find_ls(date)[0]
print('Ls = ' + str(ls))

ltst = find_localtime(ls, date, longitude)[0]
lmst = find_localtime(ls, date, longitude)[1]

#Conversion of localtime in hour, minutes, seconds
hour = floor(ltst)
minutes = (ltst - hour)*60.
seconds = (minutes - floor(minutes))*60.
print('Local True Solar Time (LTST) = ' + str(hour) + 'h ' + str(floor(minutes)) + 'min ' + str(seconds), 's')

hour2 = floor(lmst)
minutes2 = (lmst - hour2)*60.
seconds2 = (minutes2 - floor(minutes2))*60.
print('Local Mean Solar Time (LMST) = ' + str(hour2) + 'h ' + str(floor(minutes2)) + 'min ' + str(seconds2) + 's')

#------------------------------------------------------------
# position of the sun (d : declination of the sun)

d=asin(sin(ls * pi / 180.) * sin(obl * pi / 180.))

#------------------------------------------------------------
#Hour angle
hour_angle = (ltst - 12.) * pi / 12.

#Calculation of elevation beta (in degree)
beta = asin(cos(latitude * pi / 180.) * cos(d) * cos(hour_angle) + sin(latitude * pi / 180.) * sin(d)) * 180. / pi

print('Elevation of the sun (°) = ' + str(beta))

#Calculation of the azimuth (in degree east with North: azimuth=0°,
#East: azimuth=90°, South: azimuth=180°, West: azimuth=270°)
temp1 = cos(latitude * pi / 180.) * tan(d) - sin(latitude * pi / 180.) * cos(hour_angle)
temp2 = sin(hour_angle)
azimuth = atan2(temp2, temp1) * 180./ pi #The atan2 function returns the angle, expressed in radians, whose tangent is equal to Y/X is returned. Result=atan2(Y,X). The signs of Y and X gives the quadrant of the result.

if azimuth < 0.: azimuth = azimuth + 360.
azimuth = 360.-azimuth

print('Azimuth of the sun (with N=0°, E=90°, S=180°, W=270°) = ' + str(azimuth))