PRO julian, time, date

;                                Calcul de la date julian

month = [0,31,59,90,120,151,181,212,243,273,304,334]

nday = month[time[1]-1] + time[2] - 1.

;traitement des annees bissextiles

julian = 0.
IF time[0] LT 1582 THEN julian = 1.
IF time[0] EQ 1582 AND time[1] LT 10 THEN julian = 1.
IF time[0] EQ 1582 AND time[1] EQ 10 AND time[2] LT 15 THEN julian = 1.

IF julian EQ 0. THEN BEGIN
    IF ((time[0] MOD 4) EQ 0) AND ((time[0] MOD 100) NE 0) AND (time[1] GT 2) THEN nday = nday+1
    IF ((time[0] MOD 400) EQ 0) AND (time[1] GT 2) THEN nday = nday+1 
ENDIF

IF julian EQ 1. THEN BEGIN
    IF (time[0] MOD 4) EQ 0 AND (time[1] GT 2) THEN nday = nday+1
    nday = nday + 10; les fameux dix jour manquants...
ENDIF

IF time[0] GT 1968 THEN BEGIN 
    xyear = Indgen(time[0]-1968+1)+1968
    FOR j=0, N_Elements(xyear)-2 DO BEGIN
        nday = nday + 365.
        IF ((xyear[j] MOD 4) EQ 0) AND ((xyear[j] MOD 100) NE 0) THEN nday = nday + 1
        IF ((xyear[j] MOD 400) EQ 0) THEN nday = nday+1 
    ENDFOR
ENDIF

IF time[0] LT 1968 THEN BEGIN
    xyear = Indgen(1968-time[0]+1)+time[0]
    julian = 1.
    FOR j=0, N_Elements(xyear)-2 DO BEGIN

        IF xyear[j] GE 1582 THEN BEGIN
            julian = 0.
        ENDIF        
        
        IF julian EQ 0. THEN BEGIN
            nday = nday - 365.
            IF ((xyear[j] MOD 4) EQ 0) AND ((xyear[j] MOD 100) NE 0) THEN nday = nday-1
            IF ((xyear[j] MOD 400) EQ 0) THEN nday = nday-1 
        ENDIF
        
        IF julian EQ 1. THEN BEGIN
            nday = nday - 365.
            IF ((xyear[j] MOD 4) EQ 0) THEN nday = nday-1
        ENDIF
            
    ENDFOR                      ;correction du passage du calendrier
                                ;gregorien au calendrier julien
                                ;changement pris pour le 15 octobre 1582 (gregorien)
    
ENDIF

date = 2.4398565d6+double(nday)+time[3]/2.4d1+time[4]/1.44d3+time[5]/8.64d4


Print, date, format='(F12.4)'


END
