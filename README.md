# MarsTime_PositionSun
Compute Martian local time and position of the Sun for a given UTC.

Programs available both in Python and IDL.

For Python, download kepler.py package.

For IDL, here is a description of the subroutines:

find_localtime.pro

	>> local time retrieval
	
find_ls.pro

	>> aerocentric longitude retrieval
	
julian.pro

	>> julian date precise computation
	
kepler.pro

	>> kepler function
	
compute_elevation_azimuth_sun.pro

	>> elevation and azimuth of the sun retrieval
  
Example : 'compute_elevation_azimuth_sun' with UTC as 2012-09-21 08:03:55 and MSL landing site gives:

LMST = 12:12:34.27

LTST=12:52:9.53

elevation = 75.38 degrees

azimuth = 296.74 degrees
  
