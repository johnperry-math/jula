pragma Ada_2022;

with Ada.Text_IO;

with Array_Tests;
with Boolean_Tests;
with Multiline_Tests;
with Null_Tests;
with Number_Tests;
with Object_Tests;
with Output_Tests;
with String_Tests;

procedure Tests is

   package IO renames Ada.Text_IO;

begin
   if Number_Tests.All_Pass then
      IO.Put_Line ("Number_Tests: All pass!");
   end if;
   if Boolean_Tests.All_Pass then
      IO.Put_Line ("Boolean_Tests: All pass!");
   end if;
   if Null_Tests.All_Pass then
      IO.Put_Line ("Null_Tests: All pass!");
   end if;
   if String_Tests.All_Pass then
      IO.Put_Line ("String_Tests: All pass!");
   end if;
   if Array_Tests.All_Pass then
      IO.Put_Line ("Array_Tests: All pass!");
   end if;
   if Object_Tests.All_Pass then
      IO.Put_Line ("Object_Tests: All pass!");
   end if;
   if Output_Tests.All_Pass then
      IO.Put_Line ("Output_Tests: All pass!");
   end if;
   if Multiline_Tests.All_Pass then
      IO.Put_Line ("Multiline_Tests: All pass!");
   end if;
end Tests;
