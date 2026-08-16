with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO;      use Ada.Text_IO;

procedure Heresy_Kernel is
   type U32 is mod 2 ** 32;

   function FNV1A_32 (S : String) return U32 is
      H : U32 := 16#811C9DC5#;
   begin
      for C of S loop
         H := (H xor U32 (Character'Pos (C))) * 16#01000193#;
      end loop;
      return H;
   end FNV1A_32;

   function Hex8 (Value : U32) return String is
      Digits : constant String := "0123456789ABCDEF";
      Result : String (1 .. 8);
      V      : U32 := Value;
   begin
      for I in reverse Result'Range loop
         Result (I) := Digits (Integer (V mod 16) + 1);
         V := V / 16;
      end loop;
      return Result;
   end Hex8;

   function Is_Specific (Rule : String) return Boolean is
   begin
      return Rule'Length > 0
        and then Rule /= "NONE"
        and then Rule /= "UNSPECIFIED";
   end Is_Specific;

   function Is_Present (Evidence : String) return Boolean is
   begin
      return Evidence'Length > 0
        and then Evidence /= "NONE"
        and then Evidence /= "MISSING";
   end Is_Present;

begin
   if Argument_Count /= 3 then
      Put_Line ("usage: heresy-kernel ACCOUNT RULE_ID EVIDENCE_REF");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Account  : constant String := Argument (1);
      Rule     : constant String := Argument (2);
      Evidence : constant String := Argument (3);
      Case_Key : constant String := Account & "|" & Rule & "|" & Evidence;
   begin
      Put_Line ("KERNEL=HERESY/360-ADA");
      Put_Line ("CASE_ID=H360-" & Hex8 (FNV1A_32 (Case_Key)));
      Put_Line ("RULE_SPECIFIC=" & (if Is_Specific (Rule) then "1" else "0"));
      Put_Line ("EVIDENCE_PRESENT=" & (if Is_Present (Evidence) then "1" else "0"));
      Put_Line ("DISPATCH=FORTRAN_POLICY_RUNTIME");
   end;
end Heresy_Kernel;
