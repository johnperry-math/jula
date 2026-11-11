pragma Ada_2022;

with Ada.Strings.Text_Buffers;
with Ada.Strings.Unbounded;

package Jula is
   --  JSON Ultility Library for Ada
   --
   --  John Perry
   --
   --  CC-BY-SA-3.0
   --
   --  This library's main goal is an API based on Ada's standard library that
   --  allows the user to access and manipulate the object
   --  using familiar tools, rather than a completely new
   --  or slightly different API.
   --
   --  In particular, it is possible to:
   --  * access the elements of a JSON_Array or JSON_Object
   --    using the usual indexing / access techniques for vectors and maps;
   --  * iterate over the elements of a JSON_Array or JSON_Object
   --    using the usual iteration techniques for vectors and maps.

   package UBStrings renames Ada.Strings.Unbounded;
   --  used as a shortcut throughout the library.
   --  the user will mainly be interested in this when using a JSON_String
   --  (see Jula.Strings).

   type JSON is abstract tagged null record with Put_Image => JSON_Image;

   function To_String (Object : JSON) return String
   is ("<JSON>");
   --  create a legal and, therefore, parseable string
   --  that one can feed to Jula.Parsing.From_String and obtain Object.
   --  @param Object any
   --  @return a parseable string representation of object

   function Is_Array (Value : JSON) return Boolean
   is (False);
   function Is_Boolean (Value : JSON) return Boolean
   is (False);
   function Is_Null (Value : JSON) return Boolean
   is (False);
   function Is_Number (Value : JSON) return Boolean
   is (False);
   function Is_Object (Value : JSON) return Boolean
   is (False);
   function Is_String (Value : JSON) return Boolean
   is (False);

   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON);

end Jula;
