with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Iterator_Interfaces;
with Ada.Strings.Hash;

package Jula.Objects is

   --  JSON Ultility Library for Ada
   --
   --  John Perry
   --
   --  CC-BY-SA-3.0
   --
   --  JSON objects: mappings of strings to JSON values,
   --  enclosed by braces: { ... }

   type JSON_Object;

   package JSON_Maps is new
     Ada.Containers.Indefinite_Hashed_Maps
       (Key_Type        => String,
        Element_Type    => JSON'Class,
        Equivalent_Keys => "=",
        Hash            => Ada.Strings.Hash);
   type JSON_Map is new JSON_Maps.Map with null record;

   type JSON_Object is new JSON with record
      Mapping : JSON_Map;
   end record
   with
     Constant_Indexing => Value_At_Key,
     Default_Iterator  => Iterate,
     Iterator_Element  => JSON'Class,
     Put_Image         => JSON_Image;
   --  you can index and iterate either by accessing `Mapping`
   --  or by an ordinary, idiomatic syntax

   function Has_Key (O : JSON_Object; Key : String) return Boolean;

   overriding
   function Is_Object (Value : JSON_Object) return Boolean
   is (True);

   type JSON_Object_Cursor is private;

   function Value_At_Key (O : JSON_Object; Key : String) return JSON'Class;
   --  the JSON value at the indicated key
   --  @param O a JSON object
   --  @param Key a key that appears in object
   --  @exception Constraint_Error if Key is not in O

   function Value_At_Key
     (O : JSON_Object; Cursor : JSON_Object_Cursor) return JSON'Class;
   --  the JSON value at the indicated key
   --  @param O a JSON object
   --  @param Cursor a cursor pointing to the object
   --  @exception Constraint_Error if Cursor is invalid

   overriding
   function To_String (Object : JSON_Object) return String;

   function Is_Valid (Cursor : JSON_Object_Cursor) return Boolean;

   package JSON_Object_Iterators is new
     Ada.Iterator_Interfaces
       (Cursor      => JSON_Object_Cursor,
        Has_Element => Is_Valid);

   function Iterate
     (O : JSON_Object) return JSON_Object_Iterators.Forward_Iterator'Class;

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Object);

private

   type JSON_Object_Cursor is record
      --  Container : System.Address;
      Position : JSON_Maps.Cursor;
   end record;

end Jula.Objects;
