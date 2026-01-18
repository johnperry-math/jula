pragma Ada_2022;

with Ada.Strings.UTF_Encoding;
with Ada.Tags;
with Ada.Text_IO;

with Jula;
with Jula.Literals;
with Jula.Parsing;

package body String_Tests is

   package IO renames Ada.Text_IO;

   use all type Ada.Tags.Tag;

   use all type Jula.UBStrings.Unbounded_String;

   subtype JSON is Jula.JSON;
   subtype JSON_String is Jula.Literals.JSON_String;

   function String_Passes return Boolean is
      Input  : constant String := """hello""";
      Output : constant JSON'Class := Jula.Parsing.From_String (Input);
   begin
      if Output'Tag /= JSON_String'Tag then
         IO.Put_Line
           ("String_Passes: Expected a string but encountered "
            & Output'Image);
         return False;
      else
         declare
            J : constant JSON_String := JSON_String (Output);
         begin
            if J.Text /= "hello" then
               IO.Put_Line
                 ("String_Passes: Expected the string ""hello"""
                  & " but encountered """
                  & Jula.UBStrings.To_String (J.Text)
                  & """");
               return False;
            end if;
         end;
      end if;
      return True;
   end String_Passes;

   function UTF8_To_Wide_Wide_String_Passes return Boolean is
      Input : constant String := """\u2019""";
      Text  : constant Wide_Wide_String :=
        JSON_String (Jula.Parsing.From_String (Input)).To_Wide_Wide_String;
   begin
      if Text'Length /= 1 then
         IO.Put_Line
           ("Expected one character but received"
            & Natural'Image (Text'Length));
         return False;
      end if;
      if Wide_Wide_Character'Pos (Text (1)) /= 16#2019# then
         IO.Put_Line
           ("Expected character 16#2019# but received"
            & Natural'Image (Wide_Wide_Character'Pos (Text (1))));
         return False;
      end if;
      return True;
   end UTF8_To_Wide_Wide_String_Passes;

   function UTF16_To_Wide_Wide_String_Passes return Boolean is
      Input : constant String := """\ud834\udd1e""";
      Text  : constant Wide_Wide_String :=
        JSON_String (Jula.Parsing.From_String (Input)).To_Wide_Wide_String;
   begin
      if Text'Length /= 1 then
         IO.Put_Line
           ("Expected one character but received"
            & Natural'Image (Text'Length));
         return False;
      end if;
      if Wide_Wide_Character'Pos (Text (1)) /= 16#1d11e# then
         IO.Put_Line
           ("Expected character 16#1d11e#  but received"
            & Natural'Image (Wide_Wide_Character'Pos (Text (1))));
         return False;
      end if;
      return True;
   end UTF16_To_Wide_Wide_String_Passes;

   function UTF16_To_UTF_16_String_Passes return Boolean is
      Input : constant String := """\ud834\udd1e""";
      Text  : constant Ada.Strings.UTF_Encoding.UTF_16_Wide_String :=
        JSON_String (Jula.Parsing.From_String (Input)).To_UTF_16_String;
   begin
      if Text'Length /= 2 then
         IO.Put_Line
           ("Expected one character but received"
            & Natural'Image (Text'Length));
         return False;
      end if;
      if Wide_Character'Pos (Text (1)) /= 16#d834#
        or else Wide_Character'Pos (Text (2)) /= 16#dd1e#
      then
         IO.Put_Line
           ("Expected characters 16#d834# and 16#dd1e# but received"
            & Natural'Image (Wide_Character'Pos (Text (1)))
            & Natural'Image (Wide_Character'Pos (Text (2))));
         return False;
      end if;
      return True;
   end UTF16_To_UTF_16_String_Passes;

   function All_Pass return Boolean
   is (String_Passes
       and then UTF8_To_Wide_Wide_String_Passes
       and then UTF16_To_Wide_Wide_String_Passes
       and then UTF16_To_UTF_16_String_Passes);

end String_Tests;
