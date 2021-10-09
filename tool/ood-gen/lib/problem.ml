type metadata =
  { title : string
  ; number : string
  ; difficulty : string
  ; tags : string list
  }
[@@deriving yaml]

let path = Fpath.v "data/problems/en"

let parse content =
  let metadata, _ = Utils.extract_metadata_body content in
  metadata_of_yaml metadata

let split_statement_statement (blocks : _ Omd.block list) =
  let rec blocks_until_heading acc = function
    | [] ->
      List.rev acc, []
    | Omd.Heading (_, 1, _) :: _ as l ->
      List.rev acc, l
    | el :: rest ->
      blocks_until_heading (el :: acc) rest
  in
  let rec skip_non_heading_blocks = function
    | [] ->
      []
    | Omd.Heading (_, 1, _) :: _ as l ->
      l
    | _ :: rest ->
      skip_non_heading_blocks rest
  in
  let err =
    "The format of the statement file is not valid. Expected exactly two \
     top-level headings: \"Solution\" and \"Statement\""
  in
  match skip_non_heading_blocks blocks with
  | Omd.Heading (_, 1, Omd.Text (_, "Solution")) :: rest ->
    let solution_blocks, rest = blocks_until_heading [] rest in
    (match rest with
    | Omd.Heading (_, 1, Omd.Text (_, "Statement")) :: rest ->
      let statements_blocks, rest = blocks_until_heading [] rest in
      (match rest with
      | [] ->
        statements_blocks, solution_blocks
      | _ ->
        raise (Exn.Decode_error err))
    | _ ->
      raise (Exn.Decode_error err))
  | _ ->
    raise (Exn.Decode_error err)

type t =
  { title : string
  ; number : string
  ; difficulty : Meta.Proficiency.t
  ; tags : string list
  ; statement : string
  ; solution : string
  }

let to_plain_text t =
  let buf = Buffer.create 1024 in
  let rec go : _ Omd.inline -> unit = function
    | Concat (_, l) ->
      List.iter go l
    | Text (_, t) | Code (_, t) ->
      Buffer.add_string buf t
    | Emph (_, i)
    | Strong (_, i)
    | Link (_, { label = i; _ })
    | Image (_, { label = i; _ }) ->
      go i
    | Hard_break _ | Soft_break _ ->
      Buffer.add_char buf ' '
    | Html _ ->
      ()
  in
  go t;
  Buffer.contents buf

let doc_with_ids doc =
  let open Omd in
  List.map
    (function
      | Heading (attr, level, inline) ->
        let attr =
          match List.assoc_opt "id" attr with
          | Some _ ->
            attr
          | None ->
            ("id", Utils.slugify (to_plain_text inline)) :: attr
        in
        Heading (attr, level, inline)
      | el ->
        el)
    doc

let all () =
  Utils.map_files
    (fun content ->
      let metadata, body = Utils.extract_metadata_body content in
      let metadata = Utils.decode_or_raise metadata_of_yaml metadata in
      let statement_blocks, solution_blocks =
        split_statement_statement (Omd.of_string body)
      in
      let statement = Omd.to_html (Hilite.Md.transform statement_blocks) in
      let solution = Omd.to_html (Hilite.Md.transform solution_blocks) in
      { title = metadata.title
      ; number = metadata.number
      ; difficulty =
          Meta.Proficiency.of_string metadata.difficulty |> Result.get_ok
      ; tags = metadata.tags
      ; statement
      ; solution
      })
    "problems/en/*.md"

let pp_proficiency ppf v =
  Fmt.pf
    ppf
    "%s"
    (match v with
    | `Beginner ->
      "`Beginner"
    | `Intermediate ->
      "`Intermediate"
    | `Advanced ->
      "`Advanced")

let pp ppf v =
  Fmt.pf
    ppf
    {|
  { title = %a
  ; number = %a
  ; difficulty = %a
  ; tags = %a
  ; statement = %a
  ; solution = %a
  }|}
    Pp.string
    v.title
    Pp.string
    v.number
    pp_proficiency
    v.difficulty
    Pp.string_list
    v.tags
    Pp.string
    v.statement
    Pp.string
    v.solution

let pp_list = Pp.list pp

let template () =
  Format.asprintf
    {|
type difficulty =
  [ `Beginner
  | `Intermediate
  | `Advanced
  ]

type t =
  { title : string
  ; number : string
  ; difficulty : difficulty
  ; tags : string list
  ; statement : string
  ; solution : string
  }
  
let all = %a
|}
    pp_list
    (all ())