pragma Ada_2022;

with Ada.Text_IO;

package body Jula is

   package IO renames Ada.Text_IO;

   procedure JSON_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Value  : JSON) is
   begin
      Buffer.Put (Value.To_String);
   end JSON_Image;

end Jula;
