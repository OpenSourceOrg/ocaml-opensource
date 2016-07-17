(****************************************************************************)
(*  Copyright (C) Mehdi Dogguy <mehdi@dogguy.org>, 2016                     *)
(*                                                                          *)
(*  Permission is hereby granted, free of charge, to any person obtaining   *)
(*  a copy of this software and associated documentation files (the         *)
(*  "Software"), to deal in the Software without restriction, including     *)
(*  without limitation the rights to use, copy, modify, merge, publish,     *)
(*  distribute, sublicense, and/or sell copies of the Software, and to      *)
(*  permit persons to whom the Software is furnished to do so, subject to   *)
(*  the following conditions:                                               *)
(*                                                                          *)
(*  The above copyright notice and this permission notice shall be          *)
(*  included in all copies or substantial portions of the Software.         *)
(*                                                                          *)
(*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,         *)
(*  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF      *)
(*  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                   *)
(*  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE  *)
(*  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  *)
(*  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION   *)
(*  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.         *)
(****************************************************************************)

let () =
  Nettls_gnutls.init ()

exception Error of string

(** Generic function to request JSon data from API server *)
let get_data url keywords =
  let request = String.concat "/" (url :: keywords) in
  let call = new Nethttp_client.get request in
  let pipeline = new Nethttp_client.pipeline in
  let () = pipeline#set_proxy_from_environment ~insecure:false () in
  let () = pipeline#add call in
  let () = pipeline#run () in
  match call#status with
  | `Successful ->
     let content = call#get_resp_body () in
     Yojson.Basic.from_string content
  | `Client_error ->
     let status_code = call#response_status_code in
     if status_code = 404 then
       raise Not_found
     else
       raise (Error ("client error "
                     ^ (string_of_int status_code)
                     ^ " "
                     ^ call#response_status_text))
  | `Http_protocol_error e ->
     raise (Error ("http protocol error"))
  | `Redirection ->
     raise (Error ("redirected"))
  | `Server_error ->
     raise (Error ("server error"))
  | `Unserved ->
     assert false

(** Retrieve all licenses that are tagged with a given [tag] *)
let get_licenses tag =
  get_data "https://api.opensource.org/licenses" [tag]

(** Retrieve a license for a given [id] *)
let get_license_by_id id =
  get_data "https://api.opensource.org/license" [id]

(** Retrieve a license for a given [scheme] and [identifier] *)
let get_license_by_scheme_and_identifier scheme identifier =
  get_data "https://api.opensource.org/license" [scheme; identifier]

(** Retrieve all licenses *)
let all_licenses () =
  get_licenses ""
