with Ada.Strings.UTF_Encoding;

package Jula.Literals is
   --  JSON Ultility Library for Ada
   --
   --  John Perry
   --
   --  CC-BY-SA-3.0
   --
   --  JSON literals: numbers, `true`, `false`, `null`, and string.

   Malformed_Unicode : exception;

   type JSON_Literal is abstract new JSON with null record;
   --  this intermediate type is included in case you want to test
   --  if a JSON value is a literal without knowing which specific one.

   type JSON_Boolean is new JSON_Literal with record
      Value : Boolean;
   end record;
   --  the `true` and `false` values are both accessible in this fashion

   overriding
   function To_String (Object : JSON_Boolean) return String
   is (if Object.Value then "true" else "false");

   type JSON_Null is new JSON_Literal with null record;
   --  the `null` value

   overriding
   function To_String (Object : JSON_Null) return String
   is ("null");

   type JSON_Float is digits 15;

   type JSON_Number is new JSON_Literal with record
      Value : JSON_Float;
   end record;

   overriding
   function To_String (Object : JSON_Number) return String;

   function To_Wide_Wide_String (Text : String) return Wide_Wide_String;
   --  returns a Wide_Wide_String, with appropriate conversion of UTF-8.
   --  this may be necessary after parsing, since
   --  we **do not** convert unicode escapes.
   --  @param Text a JSON string, presumably with "\u" somewhere within it
   --  @return a `Wide_Wide_String` with any Unicode escapes
   --     encoded appropriately for display
   --  @exception Malformed_Unicode when:
   --  * a Unicode escape string is too close to the end of the string
   --    to have a valid Unicode (`\uABCD`)

   type JSON_String is new JSON_Literal with record
      Text : UBStrings.Unbounded_String;
   end record;

   overriding
   function To_String (Object : JSON_String) return String
   is ("""" & UBStrings.To_String (Object.Text) & """");

   function To_Wide_Wide_String (Object : JSON_String) return Wide_Wide_String
   is (To_Wide_Wide_String (UBStrings.To_String (Object.Text)));
   --  returns a Wide_Wide_String, with appropriate conversion of UTF-8.
   --  this may be necessary after parsing, since
   --  we **do not** convert unicode escapes.
   --
   --  this function essentially wraps the one with a `String` argument.
   --  @param Object a JSON string, presumably with "\u" somewhere within it
   --  @return a `Wide_Wide_String` with any Unicode escapes
   --     encoded appropriately for display
   --  @exception Malformed_Unicode when:
   --  * a Unicode escape string is too close to the end of the string
   --    to have a valid Unicode (`\uABCD`)

   function To_UTF_16_String
     (Object : JSON_String) return Ada.Strings.UTF_Encoding.UTF_16_Wide_String;
   --  returns a UTF16_String, with appropriate conversion of UTF-8.
   --  this may be necessary after parsing, since
   --  we **do not** convert unicode escapes.
   --  @param Object a JSON string, presumably with "\u" somewhere within it
   --  @return a `Wide_Wide_String` with any Unicode escapes
   --     encoded appropriately for display
   --  @exception Malformed_Unicode when:
   --  * a Unicode escape string is too close to the end of the string
   --    to have a valid Unicode (`\uABCD`)

end Jula.Literals;
