pragma Ada_2022;

with Ada.Tags;
with Ada.Text_IO;

with Jula;
with Jula.Arrays;
with Jula.Literals;
with Jula.Parsing;

package body Multiline_Tests is

   package IO renames Ada.Text_IO;

   subtype JSON_Array is Jula.Arrays.JSON_Array;

   function Commented_Lines_Passes return Boolean is
      Inputs : constant Jula.Parsing.String_Vector :=
        ["// this is a test", "[", "   null,", "   2 // of comments", "]"];
      Output : constant JSON_Array :=
        JSON_Array (Jula.Parsing.From_Strings (Inputs));
   begin
      if Natural (Output.Length) /= 2 then
         IO.Put_Line
           ("Commented_Lines_Passes: expected 2 elements but encountered"
            & Output.Length'Image);
         return False;
      end if;
      return True;
   end Commented_Lines_Passes;

   function Multiple_Values_Passes return Boolean is
      Inputs : constant Jula.Parsing.String_Vector :=
        ["""a string""", "null", "2"];
      Output : constant JSON_Array :=
        JSON_Array (Jula.Parsing.From_Strings (Inputs));
      use all type Ada.Tags.Tag;
   begin
      if Natural (Output.Length) /= 3 then
         IO.Put_Line
           ("Multiple_Values_Passes: expected 3 elements but encountered"
            & Output.Length'Image);
         return False;
      end if;
      if Output (2)'Tag /= Jula.Literals.JSON_Null'Tag then
         IO.Put_Line
           ("Multiple_Values_Passes: second item should have been null;"
            & " instead it's"
            & Output (2)'Image);
      end if;
      return True;
   end Multiple_Values_Passes;

   function All_Pass return Boolean
   is (Commented_Lines_Passes and then Multiple_Values_Passes);

end Multiline_Tests;
