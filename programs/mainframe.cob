       IDENTIFICATION DIVISION.
       PROGRAM-ID. HERESY3.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 USER-REQUEST-RECORD.
          05 REQ-ID          PIC 9(5).
          05 HTTP-METHOD     PIC X(4).
          05 ROUTE-CODE      PIC X(12).
          05 DEV-ANXIETY     PIC X(10).
          05 CHANGE-TICKET   PIC X(12).
          05 PAYLOAD         PIC X(29).
       PROCEDURE DIVISION.
           DISPLAY 'JSON IS A PASSING FAD'.
           STOP RUN.
