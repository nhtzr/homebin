def get_owner: try (
  .metadata.ownerReferences[].name
  | sub("-\\w+$"; "")
) catch null;

def to_npo:  map(
  ( .spec.nodeName ) as $node_name |
  ( .metadata.name ) as $pod_name  |
  ( get_owner      ) as $owner     |
  select($pod_name | contains("connector")) |
  {
    $node_name ,
    $pod_name  ,
    $owner
  }
);

def grouped_tsv(tsv_paths): map(  #  input is grouped array
  map([tsv_paths]|@tsv)[],        #  Fields to tsv
  ""                              #  Group separator
);

.items | to_npo | group_by(.node_name) | sort_by(-length)
# # Simple tsv
# | map([.[0].node_name, length] | @tsv)[]
# # Spaced tsv
# | grouped_tsv(.node_name, .owner, .pod_name)[]
# # tagged arrays
# | map({
#     node_name: ( .[0].node_name  ),
#     length:    ( length          ),
#     row:       ( sort_by(.owner) )
#   })
