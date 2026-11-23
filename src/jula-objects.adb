pragma Ada_2022;

package body Jula.Objects is

   function Key (Cursor : JSON_Object_Cursor) return String
   is (JSON_Maps.Key (Cursor.Position));

   function Value (O : JSON_Object; Key : String) return JSON'Class
   is (O.Mapping (Key));

   function Value
     (O : JSON_Object; Cursor : JSON_Object_Cursor) return JSON'Class
   is (O.Mapping (Cursor.Position));

   overriding
   function To_String (Self : JSON_Object) return String is
      use all type UBStrings.Unbounded_String;
      Result : UBStrings.Unbounded_String := To_Unbounded_String ("{ ");
      Ith    : Natural := 0;
   begin
      for Cursor in Self.Mapping.Iterate loop
         UBStrings.Append
           (Result,
            """"
            & JSON_Maps.Key (Cursor)
            & """ : "
            & (Self.Mapping (Cursor).To_String));
         Ith := @ + 1;
         if Ith < Positive (Self.Mapping.Length) then
            Append (Result, ", ");
         end if;
      end loop;
      Append (Result, " }");
      return To_String (Result);
   end To_String;

   use all type JSON_Maps.Cursor;

   function Is_Valid (Cursor : JSON_Object_Cursor) return Boolean
   is (Cursor.Position /= JSON_Maps.No_Element);

   type Object_Iterator is new JSON_Object_Iterators.Forward_Iterator
   with record
      --  Self : JSON_Object;
      Cursor : JSON_Maps.Cursor;
   end record;

   overriding
   function First (Iterator : Object_Iterator) return JSON_Object_Cursor
   is (JSON_Object_Cursor'(Position => Iterator.Cursor));

   overriding
   function Next
     (Iterator : Object_Iterator; Cursor : JSON_Object_Cursor)
      return JSON_Object_Cursor
   is (Position => JSON_Maps.Next (Cursor.Position));

   function Iterate
     (O : JSON_Object) return JSON_Object_Iterators.Forward_Iterator'Class
   is (Object_Iterator'(Cursor => O.Mapping.First));

   function Contains (Self : JSON_Object; Key : String) return Boolean
   is (Self.Mapping.Contains (Key));

   function Is_Empty (Self : JSON_Object) return Boolean
   is (Self.Mapping.Is_Empty);

   function Length (Self : JSON_Object) return Ada.Containers.Count_Type
   is (Self.Mapping.Length);

   overriding
   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON_Object) is
   begin
      Buffer.Put (Value.To_String);
   end JSON_Image;

   function Empty_Object return JSON_Object
   is ((others => <>));

   procedure Insert
     (Self : in out JSON_Object; Key : String; Value : JSON'Class) is
   begin
      Self.Mapping.Insert (Key, Value);
   end Insert;

   procedure Remove (Self : in out JSON_Object; Key : String) is
   begin
      Self.Mapping.Delete (Key);
   end Remove;

   procedure Include
     (Self : in out JSON_Object; Key : String; Value : JSON'Class) is
   begin
      Self.Mapping.Include (Key, Value);
   end Include;

end Jula.Objects;
