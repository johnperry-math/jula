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
            if not J.Value then
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
      elsif JSON_Boolean (Output).Value then
         IO.Put_Line
           ("False_Passes: "
            & "Expected a false JSON Boolean but encountered a true one");
         return False;
      end if;
      return True;
   end False_Passes;

   function All_Pass return Boolean
   is (True_Passes and then False_Passes);

end Boolean_Tests;
