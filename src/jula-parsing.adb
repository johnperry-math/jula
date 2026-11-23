pragma Ada_2022;

with Ada.Characters.Handling;
with Ada.Characters.Latin_1;
with Ada.Text_IO;

with Jula.Arrays;
with Jula.Objects;
with Jula.Literals;

package body Jula.Parsing is

   function Is_Space (C : Character) return Boolean
   renames Ada.Characters.Handling.Is_Space;

   package IO renames Ada.Text_IO;

   subtype JSON_Array is Jula.Arrays.JSON_Array;
   subtype JSON_Object is Jula.Objects.JSON_Object;

   subtype JSON_Float is Jula.Literals.JSON_Float;
   use all type JSON_Float;

   function From_File (Path : String) return JSON'Class is
      Input : IO.File_Type;
      Lines : String_Vector;
   begin
      IO.Open (Input, IO.In_File, Path);
      while not IO.End_Of_File (Input) loop
         declare
            Line : constant String := IO.Get_Line (Input);
         begin
            Lines.Append (Line);
         end;
      end loop;
      IO.Close (Input);
      return From_Strings (Lines);
   end From_File;

   function From_String (Value : String) return JSON'Class
   is (From_Strings ([Value]));

   function Parse_Value
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class;
   --  starts at the indicated column of the indicated row (line)

   function Position_After_Whitespace (Line : String) return Positive is
      Result : Positive := Line'First;
   begin
      while Result <= Line'Last and then Is_Space (Line (Result)) loop
         Result := @ + 1;
      end loop;
      if Result < Line'Last and then Line (Result .. Result + 1) = "//" then
         Result := Line'Last + 1;
      end if;
      return Result;
   end Position_After_Whitespace;

   type String_Vector_Position is record
      Row, Column : Positive;
   end record;

   function Position_After_Whitespace
     (Lines : String_Vector; Position : String_Vector_Position)
      return String_Vector_Position
   is
      Row    : Positive := Position.Row;
      Column : Positive := Position.Column;
   begin
      while Row <= Lines.Last_Index loop
         declare
            Line : constant String := Lines.Constant_Reference (Row);
         begin
            if Column > Line'Last then
               Row := @ + 1;
               Column := 1;
            elsif Is_Space (Line (Column)) then
               while Column <= Line'Last and then Is_Space (Line (Column)) loop
                  Column := @ + 1;
               end loop;
            elsif Column < Line'Last
              and then Line (Column .. Column + 1) = "//"
            then
               Column := 1;
               Row := @ + 1;
            else
               exit;
            end if;
         end;
      end loop;
      return (Row => Row, Column => Column);
   end Position_After_Whitespace;

   function From_Strings (Lines : String_Vector) return JSON'Class is
      Result      : Jula.Arrays.JSON_Array;
      Row, Column : Positive := 1;
      Position    : String_Vector_Position;
      use all type Ada.Containers.Count_Type;
   begin
      while Row <= Lines.Last_Index loop
         Result.Append (JSON (Parse_Value (Lines, Row, Column)));
         Position := (Row => Row, Column => Column);
         Position := Position_After_Whitespace (Lines, Position);
         Row := Position.Row;
         Column := Position.Column;
      end loop;
      return (if Result.Length = 1 then Result (1) else Result);
   end From_Strings;

   function Parse_String
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class;

   function Parse_Array
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class;

   function Parse_Object
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class;

   function Parse_True
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class;

   function Parse_False
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class;

   function Parse_Null
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class;

   function Parse_Number
     (Line : String; Row : Positive; Column : in out Positive)
      return JSON'Class;

   function Parse_Value
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class
   is
      Skipping_Whitespace : Boolean := True;
      EOF_Info            : constant String :=
        "at line"
        & Row'Image
        & " column"
        & Column'Image
        & " while seeking a value";
   begin
      while Skipping_Whitespace loop
         declare
            Line : constant String := Lines.Constant_Reference (Row);
         begin
            Column := Position_After_Whitespace (Line (Column .. Line'Last));
            if Column > Line'Last then
               Column := 1;
               Row := @ + 1;
            else
               Skipping_Whitespace := False;
            end if;
            if Row > Positive (Lines.Last_Index) then
               raise Unexpected_End_Of_File with EOF_Info;
            end if;
         end;
      end loop;
      declare
         Line : constant String := Lines.Constant_Reference (Row);
      begin
         if Column > Line'Last then
            raise Unexpected_End_Of_File with EOF_Info;
         end if;
         case Line (Column) is
            when '['              =>
               Column := @ + 1;
               return Parse_Array (Lines, Row, Column);

            when '{'              =>
               Column := @ + 1;
               return Parse_Object (Lines, Row, Column);

            when '"'              =>
               Column := @ + 1;
               return Parse_String (Lines, Row, Column);

            when 't'              =>
               return Parse_True (Lines, Row, Column);

            when 'f'              =>
               return Parse_False (Lines, Row, Column);

            when 'n'              =>
               return Parse_Null (Lines, Row, Column);

            when '-' | '0' .. '9' =>
               return Parse_Number (Lines (Row), Row, Column);

            when others           =>
               raise Unexpected_Symbol
                 with "at line" & Row'Image & " column" & Column'Image;
         end case;
      end;
   end Parse_Value;

   subtype Digit_Range is Character range '0' .. '9';

   procedure Parse_Escape
     (Line   : String;
      Row    : Positive;
      Column : in out Positive;
      Value  : in out UBStrings.Unbounded_String)
   is
      use all type UBStrings.Unbounded_String;
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
   begin
      case Line (Column) is
         when '"'    =>
            Value := @ & '"';

         when '\'    =>
            Value := @ & '\';

         when '/'    =>
            Value := @ & '/';

         when 'b'    =>
            Value := @ & Ada.Characters.Latin_1.BS;

         when 'f'    =>
            Value := @ & Ada.Characters.Latin_1.FF;

         when 'n'    =>
            Value := @ & Ada.Characters.Latin_1.LF;

         when 'r'    =>
            Value := @ & Ada.Characters.Latin_1.CR;

         when 't'    =>
            Value := @ & Ada.Characters.Latin_1.HT;

         when 'u'    =>
            if Column + 4 > Line'Last then
               raise Invalid_Unicode
                 with Position_Info & " need a valid, 4-character hex";
            else
               Value := @ & "\" & Line (Column .. Column + 4);
               Column := @ + 4;
            --  Parse_Hex (Line, Row, Column, Value);
            end if;

         when others =>
            raise Invalid_Escape_Character with Position_Info;

      end case;
   end Parse_Escape;

   function Extract_String
     (Line : String; Row : Positive; Column : in out Positive) return String
   is
      use all type UBStrings.Unbounded_String;
      Value : UBStrings.Unbounded_String;
   begin
      while Column <= Line'Last and then Line (Column) /= '"' loop
         case Line (Column) is
            when '\'                                            =>
               Column := @ + 1;
               Parse_Escape (Line, Row, Column, Value);

            when ' ' | '!' | '#' .. '[' | ']' .. Character'Last =>
               Value := @ & Line (Column);

            when others                                         =>
               raise Unexpected_Character_In_String
                 with "at line" & Row'Image & " column" & Column'Image;
         end case;
         Column := @ + 1;
      end loop;
      if Column > Line'Last then
         raise Unterminated_String with "at line" & Row'Image;
      end if;
      --  the only way we can arrive at the next line is if we are on a quote
      Column := @ + 1;
      return To_String (Value);
   end Extract_String;

   function Parse_String
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class
   is
      Value : constant String := Extract_String (Lines (Row), Row, Column);
   begin
      return
        JSON'Class
          (Jula.Literals.JSON_String'
             (Text => UBStrings.To_Unbounded_String (Value)));
   end Parse_String;

   function Parse_True
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class
   is
      Line          : constant String := Lines.Constant_Reference (Row);
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
   begin
      if Column + 3 > Line'Last then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Line'Last);
      elsif Line (Column .. Column + 3) /= "true" then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Column + 3);
      end if;
      Column := @ + 4;
      return Jula.Literals.JSON_True;
   end Parse_True;

   function Parse_False
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class
   is
      Line          : constant String := Lines.Constant_Reference (Row);
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
   begin
      if Column + 3 > Line'Last then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Line'Last);
      elsif Line (Column .. Column + 4) /= "false" then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Column + 4);
      end if;
      Column := @ + 5;
      return Jula.Literals.JSON_False;
   end Parse_False;

   function Parse_Null
     (Lines : String_Vector; Row : Positive; Column : in out Positive)
      return JSON'Class
   is
      Line          : constant String := Lines.Constant_Reference (Row);
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
      Happy_Path    : Jula.Literals.JSON_Null;
   begin
      if Column + 3 > Line'Last then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Line'Last);
      elsif Line (Column .. Column + 3) /= "null" then
         raise Unknown_Term
           with Position_Info & ": " & Line (Column .. Column + 3);
      end if;
      Column := @ + 4;
      return Happy_Path;
   end Parse_Null;

   function Parse_Number
     (Line : String; Row : Positive; Column : in out Positive)
      return JSON'Class
   is
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
      Value         : JSON_Float := JSON_Float (0);
      Is_Negative   : constant Boolean :=
        Column < Line'Last and then Line (Column) = '-';
   begin
      if Is_Negative then
         Column := @ + 1;
         if Line (Column) not in Digit_Range then
            raise Invalid_Number
              with
                Position_Info
                & "a negative number seems to start, but doesn't";
         end if;
      end if;
      --  integer part
      if Line (Column) = '0'
        and then Column < Line'Last
        and then Line (Column + 1) = '0'
      then
         raise Invalid_Number with Position_Info & ": multiple leading 0's";
      end if;
      while Column <= Line'Last and then Line (Column) in Digit_Range loop
         Value :=
           @
           * 10.0
           + JSON_Float (Character'Pos (Line (Column)) - Character'Pos ('0'));
         Column := @ + 1;
      end loop;
      if Column < Line'Last and then Line (Column) = '.' then
         Column := @ + 1;
         declare
            Denominator : JSON_Float := 10.0;
         begin
            while Column <= Line'Last and then Line (Column) in Digit_Range
            loop
               Value :=
                 @
                 + JSON_Float
                     (Character'Pos (Line (Column)) - Character'Pos ('0'))
                   / Denominator;
               Denominator := @ * 10.0;
               Column := @ + 1;
            end loop;
         end;
      end if;
      if Column < Line'Last
        and then (Line (Column) = 'e' or else Line (Column) = 'E')
      then
         Column := @ + 1;
         declare
            Exponent          : Integer := 0;
            Negative_Exponent : constant Boolean := Line (Column) = '-';
         begin
            if Negative_Exponent then
               if Column + 1 > Line'Last then
                  raise Invalid_Number
                    with
                      Position_Info & ": start of undefined negative exponent";
               else
                  Column := @ + 1;
               end if;
            elsif Line (Column) = '+' then
               if Column + 1 > Line'Last then
                  raise Invalid_Number
                    with
                      Position_Info & ": start of undefined positive exponent";
               else
                  Column := @ + 1;
               end if;
            end if;
            while Column <= Line'Last and then Line (Column) in Digit_Range
            loop
               Exponent :=
                 @ * 10 + Character'Pos (Line (Column)) - Character'Pos ('0');
               Column := @ + 1;
            end loop;
            if Negative_Exponent then
               Value := @ / 10.0 ** Exponent;
            else
               Value := @ * 10.0 ** Exponent;
            end if;
         end;
      end if;
      if Is_Negative then
         Value := -@;
      end if;
      return Jula.Literals.JSON_Number'(Value => Value);
   end Parse_Number;

   type Token_List is array (Positive range <>) of Character;

   procedure Move_Past
     (Lines       : String_Vector;
      Row, Column : in out Positive;
      Tokens      : Token_List;
      Found       : out Character)
   is
      Tokens_As_String : constant String (Tokens'Range) :=
        [for Token of Tokens => Token];
      Position_Info    : constant String :=
        "at line"
        & Row'Image
        & " column"
        & Column'Image
        & ": expecting one of"
        & Tokens_As_String;
      Position         : String_Vector_Position :=
        (Row => Row, Column => Column);
   begin
      while Row <= Lines.Last_Index loop
         Position := Position_After_Whitespace (Lines, Position);
         Row := Position.Row;
         Column := Position.Column;
         if Row > Lines.Last_Index then
            raise Unexpected_End_Of_File with Position_Info;
         end if;
         declare
            Line : constant String := Lines.Constant_Reference (Row);
         begin
            if (for some Token of Tokens => Line (Column) = Token) then
               Found := Line (Column);
               Column := @ + 1;
               if Column > Line'Last then
                  Column := 1;
                  Row := @ + 1;
               end if;
               return;
            else
               raise Unexpected_Symbol
                 with
                   "at line"
                   & Row'Image
                   & " column"
                   & Column'Image
                   & ": expecting "
                   & Tokens_As_String;
            end if;
         end;
      end loop;
      raise Unexpected_End_Of_File with Position_Info;
   end Move_Past;

   function Parse_Object
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class
   is
      Result        : JSON_Object;
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
      Token         : Character;
      Ended         : Boolean := False;
   begin
      while Row <= Lines.Last_Index loop
         Move_Past
           (Lines, Row, Column, Token_List'[1 => '"', 2 => '}'], Token);
         if Token = '}' then
            Column := @ + 1;
            Ended := True;
            exit;
         else
            --  at this point we must be in a string
            declare
               Line : constant String := Lines (Row);
               Name : constant String := Extract_String (Line, Row, Column);
            begin
               Move_Past (Lines, Row, Column, Token_List'[1 => ':'], Token);
               Result.Include (Name, Parse_Value (Lines, Row, Column));
               Move_Past
                 (Lines, Row, Column, Token_List'[1 => ',', 2 => '}'], Token);
               if Token = '}' then
                  Ended := True;
                  exit;
               end if;
            end;
         end if;
      end loop;
      if not Ended then
         raise Unexpected_End_Of_File
           with Position_Info & ": object never terminates!";
      end if;
      return Result;
   end Parse_Object;

   function Parse_Array
     (Lines : String_Vector; Row, Column : in out Positive) return JSON'Class
   is
      Result        : JSON_Array;
      Position      : String_Vector_Position;
      Position_Info : constant String :=
        "at line" & Row'Image & " column" & Column'Image;
      Token         : Character;
      Ended         : Boolean := False;
   begin
      while Row <= Lines.Last_Index loop
         Position := (Row => Row, Column => Column);
         Position := Position_After_Whitespace (Lines, Position);
         Row := Position.Row;
         Column := Position.Column;
         if Row > Lines.Last_Index then
            raise Unexpected_End_Of_File
              with
                "at line:"
                & Row'Image
                & " column"
                & Column'Image
                & ": expected a value for an array";
         end if;
         --  watch out for empty arrays
         if Lines (Row) (Column) = ']' then
            Column := @ + 1;
            Ended := True;
            exit;
         end if;
         Result.Append (JSON (Parse_Value (Lines, Row, Column)));
         Move_Past (Lines, Row, Column, Token_List'[']', ','], Token);
         if Token = ']' then
            Ended := True;
            exit;
         end if;
      end loop;
      if not Ended then
         raise Unexpected_End_Of_File
           with Position_Info & ": array never terminates!";
      end if;
      return Result;
   end Parse_Array;

end Jula.Parsing;
