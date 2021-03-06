c###sang.for
      SUBROUTINE SANG
C--------------------------------
C
C     THIS ROUTINE RESTRICTS THE PRELIMINARY CALCULATIONS
C     RESTRICT ANGLE SCAN BY DISTANCE, BUT IF USER INSISTS ON HIGHER
C     ANGLES THAN REASONABLE CHECK AMIND.
C
      COMMON/RAYS/ANG(40),IFOB(40,30,5),NANG
      COMMON /DON /ALATD, AMIN, AMIND, BTR, BTRD, DLONG, DMP, ERTR, GCD,
     1 GCDKM, PMP, PWR, TLAT, TLATD, TLONG, TLONGD, RSN, SIGTR, RLAT,
     2 RLATD,RLONG,RLONGD,BRTD,FLUX,ULAT,ULATD,ULONG,ULONGD,SSN,D90R,
     3 D50R,D10R,D90S,D50S,D10S
      DIMENSION NANGX(8)
      DATA NANGX/ 40,    34,    29,    24,    19,    14,    12,    9/
C
C     THESE MUST BE COORDINATED WITH ANG(40) IN COMMON/RAYS/
C
C        DISTANCE            MAXIMUM ANGLE
C
C     .LT. 2000KM                 89.99
C     2000 TO 4000KM              60.
C     4000 TO 6000KM              48.
C     6000 TO 8000KM              38.
C     8000 TO 10000KM             28.
C     10000 TO 12000KM            18.
C     12000 TO 14000KM            14.
C     .GE. 14000KM                8.
C
C     REFLECTRIX TABLE WILL BE CALCULATED ONLY UP TO THESE ANGLES
C
       ID= GCDKM/2000. +1.
      ID=MIN0(ID,8)
      IANG = NANGX(ID)
      IF(AMIND)  120,120,100
  100 IF(ANG(IANG) -10. - AMIND)  105,120,120
  105 CONTINUE
      DO 115 IA = 1,40
      IANG =IA
      IF(ANG(IANG)-8.5 -AMIND) 110,120,120
  110 CONTINUE
  115 CONTINUE
  120 CONTINUE
      NANG=IANG
      RETURN
      END
C--------------------------------
