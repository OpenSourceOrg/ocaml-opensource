<a href="https://opensource.org/licenses"><img align="right" width="150" height="200" src="https://opensource.org/files/OSIApproved.png"></a>
ocaml-opensource
================

`ocaml-opensource` is an API Wrapper that allows you to query the
Open Source License API with OCaml.

Example
-------

```ocaml
open Yojson.Basic.Util

[ Opensource.get_licenses () ]
  |> flatten
  |> filter_member "name"
```

Building
----------

```
make configure
make build
```
