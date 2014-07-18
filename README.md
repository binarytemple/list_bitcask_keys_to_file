
```
 ./rebar get-deps compile escriptize
```

 This will pull down the script's dependencies, compile it, and then package it into a shell script. The script's usage is as follows:

```
./list_bitcask_keys_to_file -r <riak_dir> -b <bitcask_dir> -o <output_file>
```

