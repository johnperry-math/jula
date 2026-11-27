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
   --  This library's main goal is an API
   --  based on Ada's standard library
   --  that allows the user to access and manipulate the Self
   --  using idiomatic tools, such as:
   --  * access the elements of a JSON_Array or JSON_Object
   --    using the usual indexing / access techniques for vectors and maps;
   --  * iterate over the elements of a JSON_Array or JSON_Object
   --    using the usual iteration techniques for vectors and maps.

   package UBStrings renames Ada.Strings.Unbounded;
   --  used as a shortcut throughout the library.
   --  the user will mainly be interested in this when using a JSON_String
   --  (see `Jula.Strings`).

   type JSON is abstract tagged null record with Put_Image => JSON_Image;

   function To_String (Self : JSON) return String
   is ("");
   --  create a legal and, therefore, parseable string
   --  that one can feed to `Jula.Parsing.From_String` and obtain `Self`.
   --  @param Self any
   --  @return a parseable string representation of Self

   function Is_Array (Self : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is an array (JSON: `[...]`)

   function Is_Boolean (Value : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is a boolean value (JSON :`true`, `false`)

   function Is_Null (Value : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is a null value (JSON: `null`)

   function Is_Number (Value : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is a number

   function Is_Object (Value : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is an Self; also known as a mapping
   --  (JSON: `{ "key": <Self>, ... }`)

   function Is_String (Value : JSON) return Boolean
   is (False);
   --  `True` iff `Self` is a string (JSON: `"..."`)

   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON);
   --  used to define output for the various types;
   --  see also `To_String`

end Jula;
