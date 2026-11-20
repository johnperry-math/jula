with Ada.Finalization;
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
   --  raised when a string contains invalid Unicode

   type JSON_Literal is new JSON with null record;
   --  this intermediate type is included in case you want to test
   --  if a JSON value is a literal without knowing which specific one.

   type JSON_Boolean is new JSON_Literal with private;

   function Is_True (Self : JSON_Boolean) return Boolean;
   --  `True` iff `Self` is

   overriding
   function To_String (Self : JSON_Boolean) return String
   is (if Self.Is_True then "true" else "false");

   overriding
   function Is_Boolean (Value : JSON_Boolean) return Boolean
   is (True);

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Boolean);

   JSON_True  : constant JSON_Boolean;
   --  the true value of a JSON_Boolean; use for initialization;
   --  for comparison, you're better off using `Is_True`
   JSON_False : constant JSON_Boolean;
   --  the false value of a JSON_Boolean; use for initialization;
   --  for comparison, you're better off using `Is_True`

   type JSON_Null is new JSON_Literal with null record
   with Put_Image => JSON_Image;
   --  the `null` value

   overriding
   function To_String (Self : JSON_Null) return String
   is ("null");

   overriding
   function Is_Null (Value : JSON_Null) return Boolean
   is (True);

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Null);

   Null_Element : constant JSON_Null := (null record);
   --  the JSON null object; use for initialization;
   --  for comparison, you're better off using `Is_Null`

   type JSON_Float is digits 15;

   type JSON_Number is new JSON_Literal with record
      Value : JSON_Float;
   end record
   with Put_Image => JSON_Image;
   --  a floating point number that should be
   --  consistent with the JSON standard (digits 15)

   overriding
   function To_String (Self : JSON_Number) return String;

   overriding
   function Is_Number (Value : JSON_Number) return Boolean
   is (True);

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Number);

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
   end record
   with Put_Image => JSON_Image;
   --  a JSON string

   overriding
   function To_String (Self : JSON_String) return String
   is ("""" & UBStrings.To_String (Self.Text) & """");

   overriding
   function Is_String (Value : JSON_String) return Boolean
   is (True);

   function To_Wide_Wide_String (Object : JSON_String) return Wide_Wide_String
   is (To_Wide_Wide_String (UBStrings.To_String (Object.Text)));
   --  returns a Wide_Wide_String, with appropriate conversion of UTF-8.
   --  this may be necessary after parsing, since
   --  we **do not** convert unicode escapes.
   --
   --  this function essentially wraps the one with a `String` argument.
   --  @param Self a JSON string, presumably with "\u" somewhere within it
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
   --  @param Self a JSON string, presumably with "\u" somewhere within it
   --  @return a `Wide_Wide_String` with any Unicode escapes
   --     encoded appropriately for display
   --  @exception Malformed_Unicode when:
   --  * a Unicode escape string is too close to the end of the string
   --    to have a valid Unicode (`\uABCD`)

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_String);

private

   type JSON_Boolean is new JSON_Literal with record
      Value : Boolean := False;
   end record
   with Put_Image => JSON_Image;

   JSON_True  : constant JSON_Boolean := (Value => True);
   JSON_False : constant JSON_Boolean := (Value => False);

end Jula.Literals;
