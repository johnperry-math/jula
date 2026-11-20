pragma Ada_2022;

package body Jula.Arrays is

   function Empty_Array return JSON_Array
   is ((Elements => []));

   procedure Append (Self : in out JSON_Array; Object : JSON) is
   begin
      Self.Elements.Append (Object);
   end Append;

   procedure Insert_At
     (Self : in out JSON_Array; Object : JSON; Index : Positive) is
   begin
      Self.Elements.Insert (Index, Object);
   end Insert_At;

   procedure Trim (Self : in out JSON_Array; Number : Positive) is
   begin
      Self.Elements.Delete_Last (Ada.Containers.Count_Type (Number));
   end Trim;

   procedure Remove_At (Self : in out JSON_Array; Index : Positive) is
   begin
      Self.Elements.Delete (Index);
   end Remove_At;

   function Length (Self : JSON_Array) return Ada.Containers.Count_Type
   is (Self.Elements.Length);

   type Reversible_Array_Iterator is
     new JSON_Array_Iterators.Reversible_Iterator
   with record
      Container : JSON_Array;
      Cursor    : JSON_Array_Cursor;
   end record;

   function Element_At_Index
     (Self : JSON_Array; Cursor : JSON_Array_Cursor) return JSON'Class
   is (Self.Elements (Positive (Cursor)));

   function Element_At_Index
     (Self : JSON_Array; Index : Positive) return JSON'Class
   is (Self.Elements (Index));

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
     (Self : JSON_Array) return JSON_Array_Iterators.Reversible_Iterator'Class
   is (Reversible_Array_Iterator'(Container => Self, Cursor => 0));

   overriding
   function To_String (Self : JSON_Array) return String is
      use all type UBStrings.Unbounded_String;
      Result : UBStrings.Unbounded_String := To_Unbounded_String ("[ ");
   begin
      for Ith in Self.Elements.First_Index .. Self.Elements.Last_Index loop
         Append (Result, Self.Elements (Ith).To_String);
         if Ith < Self.Elements.Last_Index then
            Append (Result, ", ");
         end if;
      end loop;
      Append (Result, " ]");
      return To_String (Result);
   end To_String;

   function Is_Empty (Self : JSON_Array) return Boolean
   is (Self.Elements.Is_Empty);

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Array) is
   begin
      Buffer.Put (Value.To_String);
   end JSON_Image;

end Jula.Arrays;
