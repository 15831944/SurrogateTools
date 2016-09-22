
        INTEGER FUNCTION FINDR4( K1, K2, K3, K4, 
     &                           N, LIST1, LIST2, LIST3, LIST4 )

C***********************************************************************
C Version "@(#)$Header$"
C EDSS/Models-3 I/O API.
C Copyright (C) 1992-2002 MCNC and Carlie J. Coats, Jr.,
C (C) 2003-2010 by Baron Advanced Meteorological Systems.
C Distributed under the GNU LESSER GENERAL PUBLIC LICENSE version 2.1
C See file "LGPL.txt" for conditions of use.
C.........................................................................
C  function body starts at line 59
C
C  RETURNS:
C       subscript at which the targeted key-quadruple appears, or 
C       -1 in case of failure.
C       EXAMPLE:  search for <STK, FIP,ID7,ID3> in table of 
C       STACK, FIP and ASC values
C       (where ID7 is leading-7 digits and ID3 is trailing 3 digits
C       in a 10-digit Area Source Code).
C
C  PRECONDITIONS REQUIRED:
C       Sorted table <N,LIST1,LIST3,LIST3,LIST4> for searching
C
C  SUBROUTINES AND FUNCTIONS CALLED:  none
C
C  REVISION  HISTORY:
C       prototype 3/31/1995 by CJC
C       Modified 03/2010 by CJC: F9x changes for I/O API v3.1
C***********************************************************************

      IMPLICIT NONE


C...........   ARGUMENTS and their descriptions:
        
        REAL   , INTENT(IN   ) :: K1             !  first  key
        REAL   , INTENT(IN   ) :: K2             !  second key
        REAL   , INTENT(IN   ) :: K3             !  third  key
        REAL   , INTENT(IN   ) :: K4             !  third  key
        INTEGER, INTENT(IN   ) :: N              !  table size
        REAL   , INTENT(IN   ) :: LIST1( N )     !  table to search for K1
        REAL   , INTENT(IN   ) :: LIST2( N )     !  table to search for K2
        REAL   , INTENT(IN   ) :: LIST3( N )     !  table to search for K3
        REAL   , INTENT(IN   ) :: LIST4( N )     !  table to search for K4


C...........   SCRATCH LOCAL VARIABLES and their descriptions:
        
        INTEGER  LO
        INTEGER  HI
        INTEGER  M


C***********************************************************************
C   begin body of function  FINDR4

        LO = 1
        HI = N
        
11      CONTINUE        !  head of bin search loop

            IF ( LO .GT. HI ) THEN

                FINDR4 = -1
                RETURN

            END IF
           
            M = ( LO + HI ) / 2
            IF ( K1 .GT. LIST1( M ) ) THEN
                LO = M + 1
                GO TO  11
            ELSE IF ( K1 .LT. LIST1( M ) ) THEN
                HI = M - 1
                GO TO  11
            ELSE IF ( K2 .GT. LIST2( M ) ) THEN
                LO = M + 1
                GO TO  11
            ELSE IF ( K2 .LT. LIST2( M ) ) THEN
                HI = M - 1
                GO TO  11
            ELSE IF ( K3 .GT. LIST3( M ) ) THEN
                LO = M + 1
                GO TO  11
            ELSE IF ( K3 .LT. LIST3( M ) ) THEN
                HI = M - 1
                GO TO  11
            ELSE IF ( K4 .GT. LIST4( M ) ) THEN
                LO = M + 1
                GO TO  11
            ELSE IF ( K4 .LT. LIST4( M ) ) THEN
                HI = M - 1
                GO TO  11
            END IF          !  end of bin search loop for this <K1,K2,K3,K4>
        
        
        FINDR4 = M
        RETURN
        END FUNCTION FINDR4

