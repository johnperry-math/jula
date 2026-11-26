pragma Ada_2022;

package body Jula is

   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON) is
   begin
      Buffer.Put (Value.To_String);
   end JSON_Image;

end Jula;
