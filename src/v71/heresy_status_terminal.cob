       IDENTIFICATION DIVISION.
       PROGRAM-ID. HERESY-STATUS-TERMINAL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-WEB-ERROR      PIC X(8).
       01 WS-RAW-ERROR      PIC X(8).
       01 WS-CLASS          PIC X(40).
       01 WS-DIAGNOSTIC     PIC X(80).
       01 WS-PACKAGES       PIC X(16).

       PROCEDURE DIVISION.
           ACCEPT WS-WEB-ERROR FROM ENVIRONMENT "H360_STATUS_WEB"
           ACCEPT WS-RAW-ERROR FROM ENVIRONMENT "H360_STATUS_RAW"
           ACCEPT WS-CLASS FROM ENVIRONMENT "H360_STATUS_CLASS"
           ACCEPT WS-DIAGNOSTIC FROM ENVIRONMENT "H360_STATUS_DIAGNOSTIC"
           ACCEPT WS-PACKAGES FROM ENVIRONMENT "H360_STATUS_PACKAGES"

           DISPLAY "============================================================"
           DISPLAY " HERESY/360 ENTERPRISE CLOUD RELIABILITY TERMINAL"
           DISPLAY " COBOL HAS REVIEWED THE STATUS PAGE"
           DISPLAY "============================================================"
           DISPLAY "WEB/API ERROR  : " FUNCTION TRIM(WS-WEB-ERROR) "%"
           DISPLAY "RAW DOWNLOAD   : " FUNCTION TRIM(WS-RAW-ERROR) "%"
           DISPLAY "OBSERVED CLASS : " FUNCTION TRIM(WS-CLASS)
           DISPLAY "PACKAGES       : " FUNCTION TRIM(WS-PACKAGES)
           DISPLAY "DIAGNOSTIC     : " FUNCTION TRIM(WS-DIAGNOSTIC)
           DISPLAY "------------------------------------------------------------"
           DISPLAY "STATUS PAGE EUPHEMISM != OBSERVED FAILURE RATE"
           DISPLAY "UPTIME BADGE != CURRENT REALITY"
           DISPLAY "ONE NORMAL SERVICE != HEALTHY PLATFORM"
           DISPLAY "------------------------------------------------------------"
           IF FUNCTION TRIM(WS-PACKAGES) = "NORMAL"
               DISPLAY "PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK."
           ELSE
               DISPLAY "PACKAGES NOT NORMAL: PUNCHLINE WITHHELD ON FACTUAL GROUNDS."
           END-IF
           DISPLAY "============================================================"
           STOP RUN.
