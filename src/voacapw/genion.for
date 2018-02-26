c###genion.for
      SUBROUTINE GENION(K)
C--------------------------------
C  THIS SECTION WILL GENERATE AN ELECTRON DENSITY PROFILE, AN IONOGRAM,
C  A REFLECTRIX,TABLE OF OBLIQUE FREQUENCIES AND DISTANCES AT SPECIFIED
C  ANGLES,ORDINARY MODE ONLY
C
C     HTR(50,3)  TRUE HEIGHT PROFILE FOR ELECTRON DENSITY PROFILE -- KM
C     FNSQ(50,3) ELECTRON DENSITY AS PLASMA FREQUENCY -- (MHZ)**2
C     FVERT(30,5) VERTICAL SOUNDING FREQUENCY--MHZ
C     HTRUE(30,5) TRUE HEIGHT OF REFLECTION--KM
C     HPRIM(30,5) VIRTUAL HEIGHT OF REFLECTION--KM
C
C     IFOB(40,30,5) OBLIQUE OPERATING FREQUENCY -- HZ
C     IDIST(40,30,5) PATH DISTANCE -- KM
C     ANG(40)  ELEVATION ANGLE -- DEGREES
C
      COMMON / MFAC / F2M3(5),HPF2(5),ZENANG(5),ZENMAX(5),IEDP,FSECV(3)
      COMMON /RON /CLAT(5), CLONG(5), GLAT(5), RD(5), FI(3,5), YI(3,5),
     1HI(3,5), HPRIM(30,5), HTRUE(30,5), FVERT(30,5),KM,KFX, AFAC(30,5),
     2HTR(50,3), FNSQ(50,3)
      DIMENSION HTE(10),HPE(10)
C.....TRUE AND VIRTUAL HEIGHTS FOR E LAYER WITH 110 AND 20 AS PARAMETERS
      DATA HTE/70.00,84.51,88.52,93.00,94.26,95.71,97.68,100.27,104.22,
     A 107.19 /
      DATA HPE/70.00,87.40,94.00,98.68,100.20,102.65,107.15,113.74,
     A 125.25,140.03/
C  SAMPLE VERTICAL SOUNDING  FREQUENCIES
C D-E  REGION TAIL
C   XTAIL MUST AGREE WITH LECDEN
      XTAIL = .85
      FEX = FI(1,K) * SQRT(1. - XTAIL * XTAIL)
      FVERT (1, K) = .01
      FVERT (4, K) = FEX
      FDIF = (FVERT (4, K) - FVERT (1, K)) / 3.
      FVERT (2, K) = FVERT (1, K) + FDIF
      FVERT (3, K) = FVERT (2, K) + FDIF
C  E REGION NOSE
C.....GUESS FOR E MUF
      FVERT(9,K) = .957 * FI(1,K)
      FVERT(10,K) = 0.99 * FI(1,K)
      FDIF = (FVERT(9,K) - FVERT(4,K)) / 5.
      FVERT (5, K) = FVERT (4, K) + FDIF
      FVERT (6, K) = FVERT (5, K) + FDIF
      FVERT (7, K) = FVERT (6, K) + FDIF
      FVERT (8, K) = FVERT (7, K) + FDIF
C.....E - F CUSP
      FVERT(11,K) =  1.05 * FI(1,K)
C.....F REGION NOSE
      FVERT(30,K) = 0.99 * FI(3,K)
      FVERT (29, K) = 0.98 * FI (3, K)
      FVERT (28, K) = 0.96 * FI (3, K)
      FVERT (27, K) = 0.92 * FI (3, K)
      IF (FI (2, K))385, 385, 400
C   F2 LAYER, NO F1 LAYER
  385 CONTINUE
      FDIF = (FVERT (27, K) - FVERT (11, K)) / 16.
      DO 395 IF = 12, 26
  395 FVERT (IF, K) = FVERT (IF - 1, K) + FDIF
      GO TO 425
C  F1 LAYER  AND F2 LAYER
  400 CONTINUE
      FVERT(20,K) = 0.99 * FI(2,K)
      FDIF = (FVERT (20, K) - FVERT (11, K)) / 9.
      DO 405 IF = 12, 19
  405 FVERT (IF, K) = FVERT (IF - 1, K) + FDIF
C.....F1 - F2 CUSP
      FVERT(21,K) = 1.01 * FI(2,K)
      FDIF = (FVERT (27, K) - FVERT (21, K)) / 6.
      DO 415 IF = 22, 26
  415 FVERT (IF, K) = FVERT (IF - 1, K) + FDIF
  425 CONTINUE
C.....DO FAST VERSION INTEGRATION BY DEFAULT
      IF( IEDP ) 600,705,705
  600 CONTINUE
C
C
C   INTEGRATE TO GET IONOGRAM,  NT-POINT GUASSIAN
C
      DO 640 IF = 1, 30
C.....VERTICAL SOUNDING FREQUENCY
      FXX = FVERT(IF,K)
      CALL GETHP(FXX, HPX, HTX)
C.....HPRIM(IF,K) IS THE VIRTUAL HEIGHT
C.....HTRUE(IF,K) IS THE TRUE HEIGHT
      HPRIM(IF,K) = HPX
      HTRUE(IF,K) = HTX
  640 CONTINUE
      GO TO 750
  705 CONTINUE
C
C FASTER VERSION, PARABOLIC E LAYER ( HI(1,K)=110.,YI(1,K)=20.) WITH
C  EXPONENTIAL TAIL.
C
C.....SAME AS CALL TO SUBROUTINE GETHP FOR DEFAULT E LAYER
      DO 710 IF = 1,10
      HTRUE(IF,K) = HTE(IF)
      HPRIM(IF,K) = HPE(IF)
710   continue
      DO 715 IF = 11,30
      FN = FVERT(IF,K)*FVERT(IF,K)
C.....TRUE HEIGHT BY TABLE LOOKUP
      HTRUE(IF,K) = XLIN(FN,FNSQ(1,1),HTR(1,1),50,1 )
  715 CONTINUE
      IF( FI(2,K) ) 720,720,730
  720 CONTINUE
      DO 725 IF = 11,30
C.....BOTTOM OF F LAYER PLUS BENDING PLUS RETARDATION
      FN = FVERT(IF,K)
      HPRIM(IF,K) = HI(3,K) - YI(3,K) + BENDY(3,K,FN)
     A            + (PEN(1,K,FN) - 2.*YI(1,K) )
  725 CONTINUE
      GO TO 750
  730 CONTINUE
C.....THERE ARE TO MANY POSSIBILITIES WITH F1 PRESENT
      DO 740 IF = 11,30
      FXX = FVERT(IF,K)
      CALL GETHP(FXX,HPX,HTX)
      HPRIM(IF,K) = HPX
  740 CONTINUE
  750 CONTINUE
      RETURN
      END
C--------------------------------