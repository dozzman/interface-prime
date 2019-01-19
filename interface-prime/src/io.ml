module type S_base = sig
  module M : Monad.S
  type in_channel
  type out_channel
  val read_exactly : in_channel -> int -> string option M.t
  val read_available : in_channel -> string M.t
  val write : out_channel -> string -> unit M.t
  val close_in : in_channel -> unit M.t
  val close_out : out_channel -> unit M.t
end

module type S = sig
  include S_base
  val read_byte : in_channel -> char option M.t
  val read_int32 : in_channel -> int32 option M.t
  val read_int64 : in_channel -> int64 option M.t
  val write : out_channel -> string -> unit M.t
end
