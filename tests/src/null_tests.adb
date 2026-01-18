pragma Ada_2022;

with Ada.Tags;
with Ada.Text_IO;

with Jula;
with Jula.Literals;
with Jula.Parsing;

package body Null_Tests is

   package IO renames Ada.Text_IO;

   use all type Ada.Tags.Tag;

   subtype JSON is Jula.JSON;
   subtype JSON_Null is Jula.Literals.JSON_Null;

   function Null_Passes return Boolean is
      Input  : constant String := "null";
      Output : constant JSON'Class := Jula.Parsing.From_String (Input);
   begin
      if Output'Tag /= JSON_Null'Tag then
         IO.Put_Line
           ("Null_Passes: Expected null but encountered " & Output'Image);
         return False;
      end if;
      return True;
   end Null_Passes;

   function All_Pass return Boolean
   is (Null_Passes);

end Null_Tests;
