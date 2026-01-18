pragma Ada_2022;

with Ada.Characters.Conversions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada.Strings.Wide_Unbounded;
with Ada.Strings.Wide_Wide_Unbounded;

package body Jula.Literals is

   package IO renames Ada.Text_IO;

   package UBWStrings renames Ada.Strings.Wide_Unbounded;
   package UBWWStrings renames Ada.Strings.Wide_Wide_Unbounded;

   function Trim_Trailing_Zeros (Value : String) return String is
      --  removes trailing zeros from a string representation of a float;
      --  for example, 2.32000 becomes 2.32.
      --  also removes the trailing decimal if the fractional part is 0.
      --
      --  **be advised** that if you feed it the string representation
      --  of an integer that ends in 0's, it will trim that, as well.
      --  @param Position string representation **of a floating point number**
      --  @return a representation without trailing zeros

      Count : Natural := 0;
   begin
      for Char of reverse Value when Char = '0' loop
         Count := @ + 1;
      end loop;
      if Count < Value'Last and then Value (Value'Last - Count) = '.' then
         Count := @ + 1;
      end if;
      return Value (Value'First .. Value'Last - Count);
   end Trim_Trailing_Zeros;

   overriding
   function To_String (Object : JSON_Number) return String is
      package Float_IO is new IO.Float_IO (Num => JSON_Float);
      Result : String (1 .. 20);
   begin
      Float_IO.Put (Result, Object.Value, Exp => 0);
      return
        Trim_Trailing_Zeros
          (Ada.Strings.Fixed.Trim (Result, Ada.Strings.Both));
   end To_String;

   function Unescape (Upper, Lower : Natural) return Wide_Wide_String is
      Position : Natural := 0;
   begin
      if Upper > 0 then
         Position :=
           (Upper - 16#d800#) * 16#0400# + (Lower - 16#dc00#) + 16#10000#;
      else
         Position := Lower;
      end if;
      return Wide_Wide_String'[1 => Wide_Wide_Character'Val (Position)];
   end Unescape;

   function To_Wide_Wide_String (Text : String) return Wide_Wide_String is
      Result  : UBWWStrings.Unbounded_Wide_Wide_String;
      Ith     : Positive := Text'First;
      Message : constant String :=
        "incomplete Unicode escape near end of line: " & Text;
   begin
      while Ith <= Text'Last loop
         if Ith < Text'Last and then Text (Ith .. Ith + 1) = "\u" then
            if Ith + 5 > Text'Last then
               raise Malformed_Unicode with Message;
            elsif Ith + 6 < Text'Last and then Text (Ith + 6 .. Ith + 7) = "\u"
            then
               if Ith + 11 > Text'Last then
                  raise Malformed_Unicode with Message;
               else
                  UBWWStrings.Append
                    (Result,
                     Unescape
                       (Positive'Value
                          ("16#" & Text (Ith + 2 .. Ith + 5) & "#"),
                        Positive'Value
                          ("16#" & Text (Ith + 8 .. Ith + 11) & "#")));
                  Ith := @ + 12;
               end if;
            else
               UBWWStrings.Append
                 (Result,
                  Unescape
                    (0,
                     Positive'Value
                       ("16#" & Text (Ith + 2 .. Ith + 5) & "#")));
               Ith := @ + 6;
            end if;
         else
            UBWWStrings.Append
              (Result,
               Ada.Characters.Conversions.To_Wide_Wide_Character (Text (Ith)));
            Ith := @ + 1;
         end if;
      end loop;
      return UBWWStrings.To_Wide_Wide_String (Result);
   end To_Wide_Wide_String;

   function To_UTF_16_String
     (Object : JSON_String) return Ada.Strings.UTF_Encoding.UTF_16_Wide_String
   is
      Result  : UBWStrings.Unbounded_Wide_String;
      Text    : constant String := UBStrings.To_String (Object.Text);
      Ith     : Positive := Text'First;
      Message : constant String :=
        "incomplete Unicode escape near end of line: " & Text;
   begin
      while Ith <= Text'Last loop
         if Ith < Text'Last and then Text (Ith .. Ith + 1) = "\u" then
            if Ith + 5 > Text'Last then
               raise Malformed_Unicode with Message;
            elsif Ith + 6 < Text'Last and then Text (Ith + 6 .. Ith + 7) = "\u"
            then
               if Ith + 11 > Text'Last then
                  raise Malformed_Unicode with Message;
               else
                  UBWStrings.Append
                    (Result,
                     Wide_Character'Val
                       (Positive'Value
                          ("16#" & Text (Ith + 2 .. Ith + 5) & "#")));
                  UBWStrings.Append
                    (Result,
                     Wide_Character'Val
                       (Positive'Value
                          ("16#" & Text (Ith + 8 .. Ith + 11) & "#")));
                  Ith := @ + 12;
               end if;
            else
               UBWStrings.Append
                 (Result,
                  Wide_Character'Val
                    (Positive'Value
                       ("16#" & Text (Ith + 2 .. Ith + 5) & "#")));
               Ith := @ + 6;
            end if;
         else
            UBWStrings.Append
              (Result,
               Ada.Characters.Conversions.To_Wide_Character (Text (Ith)));
            Ith := @ + 1;
         end if;
      end loop;
      return
        Ada.Strings.UTF_Encoding.UTF_16_Wide_String
          (UBWStrings.To_Wide_String (Result));
   end To_UTF_16_String;

end Jula.Literals;
