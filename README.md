# MarsTime_PositionSun
These programs computes __Martian local time__ and __position of the Sun__ (elevation and azimuth) for a given position (latitude/longitude) and UTC.

Programs are available both in Python and IDL.

* For Python, download kepler.py package then compute_elevation_azimuth_sun.py. Simply execute compute_elevation_azimuth_sun.py on Python. It asks the landing site (MSL, Perseverance, Zhurong) then the UTC. You can add an option to ask for another position in latitude/longitude.

* For IDL, here is a description of the subroutines:

	* julian.pro: julian date precise computation
	* kepler.pro: kepler function
	* find_localtime.pro: local time retrieval
	* find_ls.pro: aerocentric longitude retrieval
	* compute_elevation_azimuth_sun.pro: elevation and azimuth of the sun retrieval
  
Example : 'compute_elevation_azimuth_sun' with UTC as 2012-09-21 08:03:55 and MSL landing site gives:

* LMST = 12:12:34.27
* LTST=12:52:9.53
* elevation = 75.38 degrees
* azimuth = 296.74 degrees
