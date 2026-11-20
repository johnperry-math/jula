pragma Ada_2022;

with Ada.Containers.Indefinite_Vectors;
with Ada.Iterator_Interfaces;

package Jula.Arrays is
   --  JSON Ultility Library for Ada
   --
   --  John Perry
   --
   --  CC-BY-SA-3.0
   --
   --  JSON arrays: sequences of JSON values, enclosed by brackets: [ ... ]

   type JSON_Vector is private;
   --  @exclude

   type JSON_Array is new JSON with record
      Elements : JSON_Vector;
      --  an array of `JSON` elements; currently an instantiation
      --  of the standard Ada vector library
   end record
   with
     Aggregate         => (Empty => Empty_Array, Add_Unnamed => Append),
     Constant_Indexing => Element_At_Index,
     Default_Iterator  => Iterate,
     Iterator_Element  => JSON'Class,
     Put_Image         => JSON_Image;
   --  you can index and iterate using ordinary, idiomatic syntax

   overriding
   function Is_Array (Self : JSON_Array) return Boolean
   is (True);
   --  `True` for `JSON_Array`

   function Empty_Array return JSON_Array;
   --  you should never, ever, **ever** need to use this,
   --  since it's the default value of a `JSON_Array`
   --  @return an array with no elements.

   procedure Append (Self : in out JSON_Array; Object : JSON);
   --  appends `Object` to the end of `Self`

   procedure Insert_At
     (Self : in out JSON_Array; Object : JSON; Index : Positive);
   --  inserts `Object` at the indicated `Index` in `Self`;
   --  be sure it's Self legitimate index; otherwise, expect `Constraint_Error`

   procedure Trim (Self : in out JSON_Array; Number : Positive);
   --  removes `Number` of objects from the end of `Self`

   procedure Remove_At (Self : in out JSON_Array; Index : Positive);
   --  removes item at `Index` from `Self`;
   --  be sure it's Self legitimate index; otherwise, expect `Constraint_Error`

   function Length (Self : JSON_Array) return Ada.Containers.Count_Type;
   --  the number of elements in `Self`

   function Is_Empty (Self : JSON_Array) return Boolean;
   --  `True` iff `Self` is empty

   type JSON_Array_Cursor is private;
   --  @exclude

   function Element_At_Index
     (Self : JSON_Array; Index : Positive) return JSON'Class;
   --  the Self of the array at the indicated `Index`
   --  @param Self a JSON array
   --  @param Index where in `Self`; the first index is always 1
   --  @exception `Constraint_Error` when `Index` is invalid

   function Element_At_Index
     (Self : JSON_Array; Cursor : JSON_Array_Cursor) return JSON'Class;
   --  the value of the array at the indicated `Cursor`
   --  @param Self a JSON array
   --  @param Cursor where in `Self`; the first index is always 1
   --  @exception `Constraint_Error` when `Cursor` is invalid

   overriding
   function To_String (Self : JSON_Array) return String;

   function Is_In_Range (Cursor : JSON_Array_Cursor) return Boolean;
   --  `True` iff Cursor is valid

   package JSON_Array_Iterators is new
     Ada.Iterator_Interfaces
       (Cursor      => JSON_Array_Cursor,
        Has_Element => Is_In_Range);

   function Iterate
     (Self : JSON_Array) return JSON_Array_Iterators.Reversible_Iterator'Class;

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Array);

private

   package JSON_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => JSON'Class);
   type JSON_Vector is new JSON_Vectors.Vector with null record;

   type JSON_Array_Cursor is new Natural;

end Jula.Arrays;
