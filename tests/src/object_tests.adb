pragma Ada_2022;

with Ada.Tags;
with Ada.Text_IO;

with Jula;
with Jula.Arrays;
with Jula.Objects;
with Jula.Literals;
with Jula.Parsing;

package body Object_Tests is

   use all type Ada.Tags.Tag;

   package IO renames Ada.Text_IO;

   subtype JSON is Jula.JSON;

   subtype JSON_Array is Jula.Arrays.JSON_Array;
   use all type JSON_Array;

   subtype JSON_Object is Jula.Objects.JSON_Object;

   use all type Jula.Literals.JSON_Float;
   subtype JSON_Boolean is Jula.Literals.JSON_Boolean;
   subtype JSON_Null is Jula.Literals.JSON_Null;
   subtype JSON_Number is Jula.Literals.JSON_Number;

   function Object_Is_Object return Boolean is
      Object : constant JSON_Object := Jula.Objects.Empty_Object;
   begin
      if not Object.Is_Object then
         IO.Put_Line
           ("Object_Is_Object:"
            & " Somehow a JSON_Object is not recognized as such");
         return False;
      end if;
      if Object.Is_Array
        or else Object.Is_Boolean
        or else Object.Is_Null
        or else Object.Is_Number
        or else Object.Is_String
      then
         IO.Put_Line
           ("Object_Is_Object:"
            & " JSON_Object is a JSON_Object, but"
            & " is somehow also a different type");
      end if;
      return True;
   end Object_Is_Object;

   function Object_With_Array_Passes return Boolean is
      Input  : constant String :=
        "  { ""first"" : [2, true], ""second"": null} ";
      Output : constant JSON_Object :=
        JSON_Object (Jula.Parsing.From_String (Input));
   begin
      if Positive (Output.Length) /= 2 then
         IO.Put_Line
           ("Object_With_Array_Passes: Expected an object with two entries"
            & " but received one with"
            & Output.Length'Image);
         return False;
      end if;
      if not Output.Contains ("first") then
         IO.Put_Line
           ("Object_With_Array_Passes: Did not find ""first"" object");
         return False;
      end if;
      if not Output.Contains ("second") then
         IO.Put_Line
           ("Object_With_Array_Passes: Did not find ""second"" object");
         return False;
      end if;
      declare
         First  : constant JSON'Class := Output ("first");
         Second : constant JSON'Class := Output ("second");
      begin
         if First'Tag /= JSON_Array'Tag then
            IO.Put_Line
              ("Object_With_Array_Passes: expected first value to be an array"
               & " but received "
               & First'Image);
            return False;
         end if;
         if Second'Tag /= JSON_Null'Tag then
            IO.Put_Line
              ("Object_With_Array_Passes: expected second value to be null"
               & " but received "
               & Second'Image);
            return False;
         end if;
         declare
            List            : constant JSON_Array := JSON_Array (First);
            Number          : constant JSON_Number := JSON_Number (List (1));
            Correct_Boolean : constant JSON_Boolean := JSON_Boolean (List (2));
         begin
            if Number.Value /= 2.0 then
               IO.Put_Line
                 ("Object_With_Array_Passes:"
                  & " expected first array entry to be 2 but received "
                  & Number'Image);
               return False;
            end if;
            if not Correct_Boolean.Is_True then
               IO.Put_Line
                 ("Object_With_Array_Passes:"
                  & " expected second array entry to be true but received "
                  & Correct_Boolean.Is_True'Image);
               return False;
            end if;
         end;
      end;
      return True;
   end Object_With_Array_Passes;

   function Object_Iteration_Passes return Boolean is
      Input   : constant String :=
        "  { ""first"" : [2, true], ""second"": null} ";
      Output  : constant JSON_Object :=
        JSON_Object (Jula.Parsing.From_String (Input));
      Counter : Natural := 0;
   begin
      for Item of Output loop
         Counter := @ + 1;
         if Counter = 1 then
            if not Item.Is_Array then
               IO.Put_Line ("Expected first reference item to be an array");
               return False;
            end if;
         elsif Counter = 2 and then not Item.Is_Null then
            IO.Put_Line ("Expected second reference item to be null");
            return False;
         end if;
      end loop;
      if Counter /= 2 then
         IO.Put_Line
           ("Expected a generalized loop to touch 2 items but only touched"
            & Counter'Image);
         return False;
      end if;
      Counter := 1;
      for Cursor in Output.Iterate loop
         if Counter = 1 then
            if Jula.Objects.Key (Cursor) /= "first" then
               IO.Put_Line ("Expected the first key to be ""first""");
               return False;
            end if;
            if not Output.Value (Cursor).Is_Array then
               IO.Put_Line ("Expected the first value to be an array");
               return False;
            end if;
         else
            if Jula.Objects.Key (Cursor) /= "second" then
               IO.Put_Line ("Expected the second key to be ""second""");
               return False;
            end if;
            if not Output.Value (Cursor).Is_Null then
               IO.Put_Line ("Expected the second value to be null");
               return False;
            end if;
         end if;
         Counter := @ + 1;
      end loop;
      return True;
   end Object_Iteration_Passes;

   function Object_Access_Passes return Boolean is
      Input  : constant String := "{ ""first"" : 2 }";
      Output : constant JSON_Object :=
        JSON_Object (Jula.Parsing.From_String (Input));
      Number : constant JSON_Number := JSON_Number (Output ("first"));
   begin
      if Number.Value /= 2.0 then
         IO.Put_Line
           ("Object_Access_Passes: somehow we did not get 2, but rather"
            & Number.Value'Image);
         return False;
      end if;
      return True;
   end Object_Access_Passes;

   function Empty_Object_Passes return Boolean is
      Input  : constant String := "{}";
      Output : constant JSON_Object :=
        JSON_Object (Jula.Parsing.From_String (Input));
   begin
      if not Output.Is_Empty then
         IO.Put_Line
           ("Empty_Object_Passes: somehow we parsed ""{}"" to have entries");
         return False;
      end if;
      return True;
   end Empty_Object_Passes;

   function Object_Containment_Passes return Boolean is
      Output : constant JSON_Object :=
        ["first" => JSON'Class (JSON_Number'(Value => 2.0))];
   begin
      if not Output.Contains ("first") then
         IO.Put_Line
           ("Object_Containment_Passes:"
            & " should have contained key ""first"", but did not");
         return False;
      end if;
      return True;
   end Object_Containment_Passes;

   function All_Pass return Boolean
   is (Object_Is_Object
       and then Object_With_Array_Passes
       and then Object_Access_Passes
       and then Object_Iteration_Passes
       and then Object_Containment_Passes
       and then Empty_Object_Passes);

end Object_Tests;
