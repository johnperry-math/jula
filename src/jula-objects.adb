pragma Ada_2022;

package body Jula.Objects is

   function Value_At_Key (O : JSON_Object; Key : String) return JSON'Class
   is (O.Mapping (Key));

   function Value_At_Key
     (O : JSON_Object; Cursor : JSON_Object_Cursor) return JSON'Class
   is (O.Mapping (Cursor.Position));

   overriding
   function To_String (Object : JSON_Object) return String is
      use all type UBStrings.Unbounded_String;
      Result : UBStrings.Unbounded_String := To_Unbounded_String ("{ ");
      Ith    : Natural := 0;
   begin
      for Cursor in Object.Mapping.Iterate loop
         UBStrings.Append
           (Result,
            """"
            & JSON_Maps.Key (Cursor)
            & """ : "
            & (Object.Mapping (Cursor).To_String));
         Ith := @ + 1;
         if Ith < Positive (Object.Mapping.Length) then
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
      --  Object : JSON_Object;
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

   function Has_Key (O : JSON_Object; Key : String) return Boolean
   is (O.Mapping.Contains (Key));

end Jula.Objects;
