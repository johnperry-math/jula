pragma Ada_2022;

with Ada.Tags;
with Ada.Text_IO;
with Ada.Strings.Unbounded;

with Jula;
with Jula.Arrays;
with Jula.Literals;
with Jula.Parsing;

package body Array_Tests is

   use all type Ada.Tags.Tag;

   package IO renames Ada.Text_IO;

   subtype JSON is Jula.JSON;

   subtype JSON_Array is Jula.Arrays.JSON_Array;

   use all type Jula.Literals.JSON_Float;
   subtype JSON_Number is Jula.Literals.JSON_Number;
   subtype JSON_String is Jula.Literals.JSON_String;

   function Array_Is_Array return Boolean is
      Object : constant JSON_Array := (others => <>);
   begin
      if not Object.Is_Array then
         IO.Put_Line
           ("Array_Is_Array:"
            & " Somehow a JSON_Array is not recognized as such");
         return False;
      end if;
      if Object.Is_Object
        or else Object.Is_Boolean
        or else Object.Is_Null
        or else Object.Is_Number
        or else Object.Is_String
      then
         IO.Put_Line
           ("Array_Is_Array:"
            & " JSON_Array is a JSON_Array, but"
            & " is somehow also a different type");
      end if;
      return True;
   end Array_Is_Array;

   function Heterogeneous_Array_Passes return Boolean is
      Input  : constant String := "   [null, 2, ""hello""]  ";
      Output : constant JSON_Array :=
        JSON_Array (Jula.Parsing.From_String (Input));
   begin
      if Positive (Output.Length) /= 3 then
         IO.Put_Line
           ("Heterogeneous_Array_Passes: Expected an array with 3 elements,"
            & " but received one with"
            & Output.Length'Image);
         return False;
      end if;
      declare
         First : constant JSON'Class := Output (1);
      begin
         if First'Tag /= Jula.Literals.JSON_Null'Tag then
            IO.Put_Line
              ("Heterogeneous_Array_Passes: first element should be null,"
               & " but received"
               & First'Image);
            return False;
         end if;
      end;
      declare
         Second : constant JSON'Class := Output (2);
      begin
         if Second'Tag /= Jula.Literals.JSON_Number'Tag then
            IO.Put_Line
              ("Heterogeneous_Array_Passes: second element should be a number,"
               & " but received"
               & Second'Image);
            return False;
         end if;
         if JSON_Number (Second).Value /= 2.0 then
            IO.Put_Line
              ("Heterogeneous_Array_Passes: second element should be 2,"
               & " but received"
               & JSON_Number (Second).Value'Image);
            return False;
         end if;
      end;
      declare
         Third : constant JSON'Class := Output (3);
      begin
         if Third'Tag /= Jula.Literals.JSON_String'Tag then
            IO.Put_Line
              ("Heterogeneous_Array_Passes: third element should be a number,"
               & " but received"
               & Third'Image);
            return False;
         end if;
         if Ada.Strings.Unbounded.To_String (JSON_String (Third).Text)
           /= "hello"
         then
            IO.Put_Line
              ("Heterogeneous_Array_Passes: third element should be ""hello"","
               & " but received"
               & JSON_String (Third).Text'Image);
            return False;
         end if;

      end;
      return True;
   end Heterogeneous_Array_Passes;

   function Empty_Array_Passes return Boolean is
      Input  : constant String := "[]";
      Output : constant JSON_Array :=
        JSON_Array (Jula.Parsing.From_String (Input));
   begin
      if Natural (Output.Length) /= 0 then
         IO.Put_Line
           ("Empty_Array: somehow we parsed ""[]"" to have elements");
         return False;
      end if;
      return True;
   end Empty_Array_Passes;

   function Is_Empty_Passes return Boolean is
      Value : constant JSON_Array := (Elements => <>);
   begin
      if not Value.Is_Empty then
         IO.Put_Line
           ("Is_Empty_Passes: an empty array is not detected as empty");
         return False;
      end if;
      return True;
   end Is_Empty_Passes;

   function Array_Iteration_Passes return Boolean is
      Input   : constant String := "   [null, 2, ""hello""]  ";
      Output  : constant JSON_Array :=
        JSON_Array (Jula.Parsing.From_String (Input));
      Counter : Natural := 0;
   begin
      for Element of Output loop
         Counter := @ + 1;
      end loop;
      if Counter /= 3 then
         IO.Put_Line
           ("Array_Iteration_Passes: expected 3 elements but encountered"
            & Counter'Image);
         return False;
      end if;
      return True;
   end Array_Iteration_Passes;

   function All_Pass return Boolean
   is (Array_Is_Array
       and then Heterogeneous_Array_Passes
       and then Empty_Array_Passes
       and then Is_Empty_Passes
       and then Array_Iteration_Passes);

end Array_Tests;
