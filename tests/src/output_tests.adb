pragma Ada_2022;

with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Jula;
with Jula.Arrays;
with Jula.Literals;
with Jula.Objects;
with Jula.Parsing;

package body Output_Tests is

   package IO renames Ada.Text_IO;

   package UBStrings renames Ada.Strings.Unbounded;
   use all type UBStrings.Unbounded_String;

   subtype JSON is Jula.JSON;

   type String_Array is
     array (Positive range <>) of UBStrings.Unbounded_String;

   function Is_Substring (Candidate, Container : String) return Boolean
   is (for some Ith in
         Container'First .. Container'Last - Candidate'Length + 1 =>
         Container (Ith .. Ith + Candidate'Length - 1) = Candidate);

   function Contains (Container : String; Values : String_Array) return Boolean
   is
   begin
      for Value of Values loop
         declare
            Candidate : constant String := UBStrings.To_String (Value);
            Last      : Positive := Candidate'Last;
         begin
            if Candidate (Last) = ',' then
               Last := @ - 1;
            end if;
            if not Is_Substring
                     (Candidate (Candidate'First .. Last), Container)
            then
               IO.Put_Line ("Unable to find " & UBStrings.To_String (Value));
               return False;
            end if;
         end;
      end loop;
      return True;
   end Contains;

   function The_Cycle_Is_Complete return Boolean is
      Inputs : constant String_Array (1 .. 5) :=
        [To_Unbounded_String ("{"),
         To_Unbounded_String ("""first"" : [ 2, true ],"),
         To_Unbounded_String ("""second"" : null,"),
         To_Unbounded_String ("""third"" : ""hello"""),
         To_Unbounded_String ("}")];
      Input  : constant String :=
        To_String (Inputs (1))
        & " "
        & To_String (Inputs (2))
        & " "
        & To_String (Inputs (3))
        & " "
        & To_String (Inputs (4))
        & " "
        & To_String (Inputs (5));
      Object : constant JSON'Class := Jula.Parsing.From_String (Input);
      Output : constant String := Object.To_String;
   begin
      if Output'Length /= Input'Length or else not Contains (Output, Inputs)
      then
         IO.Put_Line
           ("The_Cycle_Is_Complete: Expected `"
            & Input
            & "` but received `"
            & Output
            & "`");
         return False;
      end if;
      return True;
   end The_Cycle_Is_Complete;

   function JSON_Put_Image_Passes return Boolean is
      Temp    : Jula.Literals.JSON_Boolean;
      Blocked : constant JSON'Class := Temp;
   begin
      return JSON (Blocked)'Image = "<JSON>";
   end JSON_Put_Image_Passes;

   function JSON_Boolean_Image_Passes return Boolean is
      Value : Jula.Literals.JSON_Boolean;
   begin
      return Value'Image = "false";
   end JSON_Boolean_Image_Passes;

   function JSON_Null_Image_Passes return Boolean
   is (Jula.Literals.Null_Element'Image = "null");

   function JSON_Number_Image_Passes return Boolean is
      Value : constant Jula.Literals.JSON_Number := (Value => 3.14159);
   begin
      return Value'Image = "3.14159";
   end JSON_Number_Image_Passes;

   function JSON_String_Image_Passes return Boolean is
      Value : constant Jula.Literals.JSON_String :=
        (Text => UBStrings.To_Unbounded_String ("test"));
   begin
      return Value'Image = """test""";
   end JSON_String_Image_Passes;

   function JSON_Array_Image_Passes return Boolean is
      Value : constant Jula.Arrays.JSON_Array :=
        (Elements => [JSON'Class (Jula.Literals.Null_Element)]);
   begin
      return Value'Image = "[ null ]";
   end JSON_Array_Image_Passes;

   function JSON_Object_Image_Passes return Boolean is
      Value : constant Jula.Objects.JSON_Object :=
        (Mapping => ["first" => JSON'Class (Jula.Literals.Null_Element)]);
   begin
      return Value'Image = "{ ""first"" : null }";
   end JSON_Object_Image_Passes;

   function All_Pass return Boolean
   is (The_Cycle_Is_Complete
       and then JSON_Put_Image_Passes
       and then JSON_Boolean_Image_Passes
       and then JSON_Null_Image_Passes
       and then JSON_Number_Image_Passes
       and then JSON_String_Image_Passes
       and then JSON_Array_Image_Passes
       and then JSON_Object_Image_Passes);

end Output_Tests;
