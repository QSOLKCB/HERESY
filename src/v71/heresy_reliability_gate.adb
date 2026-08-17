with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;

procedure Heresy_Reliability_Gate is
   Web_Error : Integer;
   Raw_Error : Integer;

   procedure Fail (Message : String) is
   begin
      Put_Line (Message);
      Set_Exit_Status (Failure);
   end Fail;
begin
   if Argument_Count /= 2 then
      Fail ("usage: heresy-reliability-gate WEB_API_ERROR_PERCENT RAW_DOWNLOAD_ERROR_PERCENT");
      return;
   end if;

   begin
      Web_Error := Integer'Value (Argument (1));
      Raw_Error := Integer'Value (Argument (2));
   exception
      when Constraint_Error =>
         Fail ("RELIABILITY_INPUT_INVALID");
         return;
   end;

   if Web_Error < 0 or else Web_Error > 100 or else
      Raw_Error < 0 or else Raw_Error > 100
   then
      Fail ("RELIABILITY_PERCENT_OUT_OF_RANGE");
      return;
   end if;

   Put_Line ("GATE=HERESY/360-ADA-RELIABILITY");
   Put_Line ("WEB_API_ERROR_RATE=" & Integer'Image (Web_Error));
   Put_Line ("RAW_DOWNLOAD_ERROR_RATE=" & Integer'Image (Raw_Error));

   if Raw_Error >= 50 then
      Put_Line ("RAW_DOWNLOAD_CLASS=COIN_FLIP");
   elsif Raw_Error >= 20 then
      Put_Line ("RAW_DOWNLOAD_CLASS=INCIDENT");
   elsif Raw_Error > 0 then
      Put_Line ("RAW_DOWNLOAD_CLASS=DEGRADED");
   else
      Put_Line ("RAW_DOWNLOAD_CLASS=NOMINAL");
   end if;

   if Web_Error >= 20 or else Raw_Error >= 50 then
      Put_Line ("OBSERVED_CLASS=INCIDENT");
   elsif Web_Error > 0 or else Raw_Error > 0 then
      Put_Line ("OBSERVED_CLASS=DEGRADED");
   else
      Put_Line ("OBSERVED_CLASS=NOMINAL");
   end if;

   Put_Line ("DISPATCH=FORTRAN_RELIABILITY_RUNTIME");
end Heresy_Reliability_Gate;
