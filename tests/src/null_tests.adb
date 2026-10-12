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

   function Null_Parsing_Passes return Boolean is
      Input  : constant String := "null";
      Output : constant JSON'Class := Jula.Parsing.From_String (Input);
   begin
      if Output'Tag /= JSON_Null'Tag then
         IO.Put_Line
           ("Null_Passes: Expected null but encountered " & Output'Image);
         return False;
      end if;
      return True;
   end Null_Parsing_Passes;

   function Null_Is_Null return Boolean is
      Object : constant JSON_Null := Jula.Literals.Null_Element;
   begin
      if not Object.Is_Null then
         IO.Put_Line
           ("Null_Is_Null:"
            & " Somehow a JSON_Null is not recognized as such");
         return False;
      end if;
      if Object.Is_Array
        or else Object.Is_Boolean
        or else Object.Is_Object
        or else Object.Is_Number
        or else Object.Is_String
      then
         IO.Put_Line
           ("Null_Is_Null:"
            & " JSON_Null is a JSON_Null, but"
            & " is somehow also a different type");
      end if;
      return True;
   end Null_Is_Null;

   function All_Pass return Boolean
   is (Null_Parsing_Passes and then Null_Is_Null);

end Null_Tests;
