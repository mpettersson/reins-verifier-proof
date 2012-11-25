open Reinsverif;;

let read_byte (file : in_channel) : int option =
  try (Some (input_byte file)) with
    | End_of_file -> None;;

let rec read_bytes (n : int) (file : in_channel) : int list =
  match n with
  | 0 -> []
  | _ -> match (read_byte file) with
      | Some byte -> byte :: read_bytes (n-1) file
      | None -> [];;

let rec read_bin (n : int) (file : in_channel) : (int list) list =
  if (n-3072) <= 0 then
    [read_bytes 3072 file]
  else
    (read_bytes 3072 file) :: read_bin (n-3072) file;;

let rec print_list' (l : int list) =
  match l with
    | [] -> ()
    | x :: xs -> print_int x; print_string " "; print_list' xs;;

let print_list (l : int list) =
  print_string "["; print_list' l; print_string "]\n";;

let rec print_matr' (l : (int list) list) =
  match l with
    | [] -> ()
    | x :: xs -> print_list x; print_matr' xs;;

let print_matr (l : (int list) list) =
  print_string "["; print_matr' l; print_string "]\n";;

let main () =
  let file = open_in Sys.argv.(1) in
  let bin = read_bin (in_channel_length file) file in
  let zs = List.map (List.map z_of_nat) bin in
  let data = List.map (List.map (Word.repr 8)) zs in
    match checkProgram' data with
    | (b,_) -> if b then
                 print_string "Pass\n"
               else
                 print_string "Fail\n";;


main ();;
