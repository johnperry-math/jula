pragma Ada_2022;

with Ada.Strings.Unbounded;
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
   else
      IO.Put_Line (">>> At least one failure in Number_Tests");
   end if;
   if Boolean_Tests.All_Pass then
      IO.Put_Line ("Boolean_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Boolean_Tests");
   end if;
   if Null_Tests.All_Pass then
      IO.Put_Line ("Null_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Null_Tests");
   end if;
   if String_Tests.All_Pass then
      IO.Put_Line ("String_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in String_Tests");
   end if;
   if Array_Tests.All_Pass then
      IO.Put_Line ("Array_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Array_Tests");
   end if;
   if Object_Tests.All_Pass then
      IO.Put_Line ("Object_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Object_Tests");
   end if;
   if Output_Tests.All_Pass then
      IO.Put_Line ("Output_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Output_Tests");
   end if;
   if Multiline_Tests.All_Pass then
      IO.Put_Line ("Multiline_Tests: All pass!");
   else
      IO.Put_Line (">>> At least one failure in Multiline_Tests");
   end if;
end Tests;
