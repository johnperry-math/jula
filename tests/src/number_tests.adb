with Ada.Text_IO;

with Jula;
with Jula.Literals;
with Jula.Parsing;

package body Number_Tests is

   package IO renames Ada.Text_IO;

   use all type Jula.Literals.JSON_Float;
   subtype JSON_Number is Jula.Literals.JSON_Number;

   function Integers_Pass return Boolean is
      A : constant String := "123";
      B : constant String := "-456";
      J : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (A));
      K : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (B));
   begin
      if J.Value /= 123.0 or else K.Value /= -456.0 then
         IO.Put_Line
           ("Integers_Pass: Expected 123 and -456; got: "
            & J.Value'Image
            & K.Value'Image);
         return False;
      end if;
      return True;
   end Integers_Pass;

   function Flat_Floats_Pass return Boolean is
      A : constant String := "123.456";
      B : constant String := "-456.789";
      J : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (A));
      K : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (B));
   begin
      if J.Value /= 123.456 or else K.Value /= -456.789 then
         IO.Put_Line
           ("Flat_Floats_Pass: Expected 123.456 and -456.789; got: "
            & J.Value'Image
            & K.Value'Image);
         return False;
      end if;
      return True;
   end Flat_Floats_Pass;

   function Scino_Floats_Pass return Boolean is
      A : constant String := "123E45";
      B : constant String := "-456.7E-89";
      J : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (A));
      K : constant JSON_Number := JSON_Number (Jula.Parsing.From_String (B));
   begin
      if J.Value /= 123.0E45 or else K.Value /= -456.7E-89 then
         IO.Put_Line
           ("Scino_Floats_Pass: Expected 123E45 and -456.7E-89; got: "
            & J.Value'Image
            & K.Value'Image);
         return False;
      end if;
      return True;
   end Scino_Floats_Pass;

   function All_Pass return Boolean
   is (Integers_Pass and then Flat_Floats_Pass and then Scino_Floats_Pass);

end Number_Tests;
