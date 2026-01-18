with Ada.Containers.Indefinite_Vectors;

package Jula.Parsing is
   --  JSON Ultility Library for Ada
   --
   --  John Perry
   --
   --  CC-BY-SA-3.0
   --
   --  The parser follows the specification of
   --  [RFC 8259](https://www.rfc-editor.org/rfc/rfc8259).
   --  It allows some features common to real-world JSON texts
   --  that other implementations prohibit:
   --  * Comments beginning with `//`. This is allowed per section 9:
   --     _A JSON parser MAY accept non-JSON forms or extensions._
   --  * More than one json value per text, per section 2:
   --     _A JSON text is a sequence of tokens. ... Note that certain previous
   --    specifications of JSON constrained a JSON text to be an object or an
   --    array._
   --
   --  **Caution**
   --
   --  In order to return a JSON string as a `String`; the parser _does not_
   --  convert Unicode escape characters into UTF-8;
   --  it leaves them as `\uWXYZ`.
   --  There are several reasons for this, one of them being that your target
   --  may support only ASCII, Latin-1, etc.
   --  For targets capable of supporting UTF-8, use
   --  `jula.literals.To_Wide_Wide_String` or `jula.literals.To_UTF_16_String`.
   --  ...Or decode them in your own custome fashion.

   Invalid_Escape_Character,
     Invalid_Number,
     Invalid_Unicode,
     Unknown_Term,
     Unexpected_Character_In_String,
     Unexpected_End_Of_File,
     Unexpected_Symbol,
     Unterminated_String : exception;

   package String_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => String);
   subtype String_Vector is String_Vectors.Vector;

   function From_Strings (Lines : String_Vector) return JSON'Class;
   --  create a JSON object
   --  @param Lines strings that will be scanned in the order they appear
   --     in the vector. more than one JSON object can appear.
   --  @return the JSON specified by the vector

   function From_String (Value : String) return JSON'Class;
   --  create a JSON object from a string.
   --  equivalent to calling From_Strings with a singleton vector
   --  @param Value string to parse
   --  @return the JSON specified by the vector

   function From_File (Path : String) return JSON'Class;
   --  create a JSON from a file.
   --  equivalent to calling From_Strings
   --  with each line as an element of Lines.
   --  @param Path full path to the file to parse
   --  @return the JSON specified by the vector

end Jula.Parsing;
