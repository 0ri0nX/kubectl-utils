# Kubernetes utils
## Copy data between pods
``./remote_copy.sh <source_pod1>:<source_path1> .. <source_podn>:<source_pathn> <target_pod>:<target_path>``
- similar to `kubectl cp` but you can specify both source and target pods 
- data are copied via localhost
- expect `tar`
