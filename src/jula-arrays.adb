pragma Ada_2022;

package body Jula.Arrays is

   type Reversible_Array_Iterator is
     new JSON_Array_Iterators.Reversible_Iterator
   with record
      Container : JSON_Array;
      Cursor    : JSON_Array_Cursor;
   end record;

   function Element_At_Index
     (A : JSON_Array; Cursor : JSON_Array_Cursor) return JSON'Class
   is (A.Elements (Positive (Cursor)));

   function Element_At_Index
     (A : JSON_Array; Index : Positive) return JSON'Class
   is (A.Elements (Index));

   function Is_In_Range (Cursor : JSON_Array_Cursor) return Boolean
   is (Cursor /= 0);

   overriding
   function First
     (Iterator : Reversible_Array_Iterator) return JSON_Array_Cursor
   is (1);

   overriding
   function Next
     (Iterator : Reversible_Array_Iterator; Position : JSON_Array_Cursor)
      return JSON_Array_Cursor
   is (if Position < JSON_Array_Cursor (Iterator.Container.Elements.Last_Index)
       then Position + 1
       else 0);

   overriding
   function Last
     (Iterator : Reversible_Array_Iterator) return JSON_Array_Cursor
   is (JSON_Array_Cursor (Iterator.Container.Elements.Last_Index));

   overriding
   function Previous
     (Iterator : Reversible_Array_Iterator; Position : JSON_Array_Cursor)
      return JSON_Array_Cursor
   is (if Position = 0 then 0 else Position - 1);

   function Iterate
     (A : JSON_Array) return JSON_Array_Iterators.Reversible_Iterator'Class
   is (Reversible_Array_Iterator'(Container => A, Cursor => 0));

   overriding
   function To_String (Object : JSON_Array) return String is
      use all type UBStrings.Unbounded_String;
      Result : UBStrings.Unbounded_String := To_Unbounded_String ("[ ");
   begin
      for Ith in Object.Elements.First_Index .. Object.Elements.Last_Index loop
         Append (Result, Object.Elements (Ith).To_String);
         if Ith < Object.Elements.Last_Index then
            Append (Result, ", ");
         end if;
      end loop;
      Append (Result, " ]");
      return To_String (Result);
   end To_String;

end Jula.Arrays;
