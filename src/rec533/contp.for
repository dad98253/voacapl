      SUBROUTINE CONTP(X1,XLAT,P)
      COMMON /SOL/ DECL12(12),EQT12(12),DECL,EQT,MONTH,IMON(12)
C
C     CALCULATION OF EXPONENT  P
C
      DIMENSION PVAL1(7,2,6),PVAL2(7,2,6),PPT(12)

      DATA PPT/3*30.,27.5,32.5,35.,37.5,35.,32.5,3*30./
      DATA PVAL1/1.51,-.353,-.09,.191,.133,-.067,-.053,
     *           1.4,-.365,-1.212,-.049,1.187,.119,-.4,
     *           1.49,-.348,-.055,.164,.16,-.041,-.08,
     *           1.45,-.119,-.913,-.64,.347,.458,.107,
     *           1.52,-.41,-.138,.308,.267,-.113,-.133,
     *           1.5,-.492,-.958,.216,.267,-.029,.187,
     *           1.58,-.129,-.228,-.192,.2,.116,-.027,
     *           1.53,-.468,-1.312,.096,.973,.057,-.187,
     *           1.59,.002,-.102,-.579,-.467,.522,.613,
     *           1.49,-.937,-1.622,1.365,1.72,-.873,-.453,
     *           1.6,-.06,-.175,-.037,.147,-.008,-.027,
     *           1.46,-.881,-1.595,.901,2.133,-.395,-.933/
      DATA PVAL2/1.6,-.03,-.135,-.137,.053,.072,.027,
     *           1.43,-.902,-1.667,.905,2.48,-.383,-1.173,
     *           1.59,-.032,-.083,-.119,0.,.031,.053,
     *           1.46,-.831,-1.653,.708,2.32,-.257,-1.067,
     *           1.59,-.06,-.18,-.181,.267,.081,-.107,
     *           1.51,-.809,-1.74,.75,2.24,-.301,-.96,
     *           1.57,-.189,-.207,-.005,.293,.004,-.107,
     *           1.52,-.433,-1.015,-.017,.44,.115,.08,
     *           1.55,-.292,-.275,.093,.427,-.026,-.187,
     *           1.44,-.279,-.77,-.266,.053,.245,.267,
     *           1.51,-.347,-.082,.16,.093,-.048,-.027,
     *           1.4,-.355,-1.212,-.102,1.187,.172,-.4 /

      MES = MONTH
      R2D=180./3.14159265359
      P=0.
      X=ABS(X1*R2D)
      IF (X.GT.70.)  X=70.
      IF (XLAT.LT.0.) THEN
                          MES=MES+6
                          IF (MES.GT.12) MES = MES-12
      ENDIF
500   FORMAT(5X,I2,5x,f4.1)
      PP=PPT(MES)
      IF (X.GT.PP) THEN
                       I=2
                       X= -1.+2.*(X-PP)/(70.-PP)
                   ELSE
                       I=1
                       X=-1.+2.*X/PP
                   ENDIF

      SX=1.
      DO 10 J=1,7
         IF (MES.LE.6) THEN
                           A=PVAL1(J,I,MES)
                       ELSE
                           A=PVAL2(J,I,MES-6)
                       ENDIF

         P=P + A*SX
         SX=SX*X
10    CONTINUE
      RETURN
      END
c*********************************************************************