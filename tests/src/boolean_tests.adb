pragma Ada_2022;

with Ada.Tags;
with Ada.Text_IO;

with Jula;
with Jula.Literals;
with Jula.Parsing;

package body Boolean_Tests is

   package IO renames Ada.Text_IO;

   subtype JSON is Jula.JSON;
   subtype JSON_Boolean is Jula.Literals.JSON_Boolean;

   use all type Ada.Tags.Tag;

   function True_Passes return Boolean is
      Input  : constant String := "true";
      Output : constant JSON'Class := Jula.Parsing.From_String (Input);
   begin
      if Output'Tag /= JSON_Boolean'Tag then
         IO.Put_Line
           ("True_Passes: Expected a JSON Boolean but encountered "
            & Output'Image);
         return False;
      else
         declare
            J : constant JSON_Boolean := JSON_Boolean (Output);
         begin
            if not J.Is_True then
               IO.Put_Line
                 ("True_Passes: "
                  & "Expected a true JSON Boolean "
                  & "but encountered a false one");
               return False;
            end if;
         end;
      end if;
      return True;
   end True_Passes;

   function False_Passes return Boolean is
      Input  : constant String := "false";
      Output : constant JSON'Class := Jula.Parsing.From_String (Input);
   begin
      if Output'Tag /= JSON_Boolean'Tag then
         IO.Put_Line
           ("False_Passes: Expected a JSON Boolean but encountered "
            & Output'Image);
         return False;
      elsif JSON_Boolean (Output).Is_True then
         IO.Put_Line
           ("False_Passes: "
            & "Expected a false JSON Boolean but encountered a true one");
         return False;
      end if;
      return True;
   end False_Passes;

   function Boolean_Is_Boolean return Boolean is
      Object : constant JSON'Class := Jula.Literals.JSON_True;
   begin
      if not Object.Is_Boolean then
         IO.Put_Line
           ("Boolean_Is_Boolean:"
            & " Somehow a JSON_Boolean is not recognized as such");
         return False;
      end if;
      if Object.Is_Array
        or else Object.Is_Object
        or else Object.Is_Null
        or else Object.Is_Number
        or else Object.Is_String
      then
         IO.Put_Line
           ("Boolean_Is_Boolean:"
            & " JSON_Boolean is a JSON_Boolean, but"
            & " is somehow also a different type");
      end if;
      return True;
   end Boolean_Is_Boolean;

   function All_Pass return Boolean
   is (True_Passes and then False_Passes and then Boolean_Is_Boolean);

end Boolean_Tests;
