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

   package JSON_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => JSON'Class);
   type JSON_Vector is new JSON_Vectors.Vector with null record;

   type JSON_Array is new JSON with record
      Elements : JSON_Vector;
   end record
   with
     Constant_Indexing => Element_At_Index,
     Default_Iterator  => Iterate,
     Iterator_Element  => JSON'Class;
   --  you can index and iterate either by accessing `Elements`
   --  or by an ordinary, idiomatic syntax

   function Is_Empty (Object : JSON_Array) return Boolean;

   overriding
   function Is_Array (Value : JSON_Array) return Boolean
   is (True);

   type JSON_Array_Cursor is private;

   function Element_At_Index
     (A : JSON_Array; Index : Positive) return JSON'Class;
   --  the value of the array at the indicated Cursor
   --  @param A a JSON array
   --  @param Index where in A; the first index is always 1
   --  @exception Constraint_Error when Cursor is invalid

   function Element_At_Index
     (A : JSON_Array; Cursor : JSON_Array_Cursor) return JSON'Class;
   --  the value of the array at the indicated Cursor
   --  @param A a JSON array
   --  @param Cursor where in A; the first index is always 1
   --  @exception Constraint_Error when Cursor is invalid

   overriding
   function To_String (Object : JSON_Array) return String;

   function Is_In_Range (Cursor : JSON_Array_Cursor) return Boolean;
   --  whether Cursor is valid

   package JSON_Array_Iterators is new
     Ada.Iterator_Interfaces
       (Cursor      => JSON_Array_Cursor,
        Has_Element => Is_In_Range);

   function Iterate
     (A : JSON_Array) return JSON_Array_Iterators.Reversible_Iterator'Class;

private

   type JSON_Array_Cursor is new Natural;

end Jula.Arrays;
