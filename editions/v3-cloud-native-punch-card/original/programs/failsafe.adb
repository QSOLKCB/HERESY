package body Failsafe is
   Override_Length   : constant Positive := 80;
   Missile_Assumption : constant Boolean := True;

   procedure Contain (Fault_Code : in Integer) is
   begin
      if Fault_Code /= 0 then
         raise Program_Error with "RECALIBRATE INERTIAL GUIDANCE";
      end if;
   end Contain;
end Failsafe;
