module type S_base = sig
  type +'a t
  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module type S = sig
  include S_base
  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  val (=<<) : ('a -> 'b t) -> 'a t -> 'b t
  val (>>) : 'a t -> 'b t Lazy.t -> 'b t
  val fmap : ('a -> 'b) -> 'a t -> 'b t
  val (>|=) : 'a t -> ('a -> 'b) -> 'b t
  val seq : 'a t list -> 'a list t
end

module Make(M : S_base) : S with type 'a t = 'a M.t = struct
  include M
  let (>>=) = M.bind
  let (=<<) f m = M.bind m f
  let (>>) m1 m2 = M.bind m1 (fun _ -> Lazy.force m2)
  let fmap f m = M.bind m (fun x -> x |> f |> M.return)
  let (>|=) m f = fmap f m
  let seq ms = List.fold_right (fun m acc -> acc >>= fun l -> m >>= fun x -> return (x::l)) ms (return [])
end

module type ErrorType = sig
  type t
  val of_exn : exn -> t
(*  val of_string : string -> t *)
end

(*module Make_result(E : ErrorType)(M : S) = struct
  let fail x = Error x |> M.return
  let lift m = M.bind m (fun x -> Ok x |> M.return)
  let lift_opt e m = M.bind m (function
    | Some x -> Ok x |> M.return
    | None -> e |> M.return)
  include Make(struct
    type +'a t = ('a, E.t) result M.t
    let return x = Ok x |> M.return
    let bind m f = M.bind m (function
      | Ok x ->
        (try
          f x
        with e ->
          e |> E.of_exn |> fail)
      | Error x -> fail x)
  end)
end
*)
