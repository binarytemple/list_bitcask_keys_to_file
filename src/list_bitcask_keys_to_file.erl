-module(list_bitcask_keys_to_file).

-export([main/1]).

main(Args) ->
    application:start(lager),
    Opts = get_opts(Args),
    add_riak_lib_to_path(proplists:get_value(riak_dir, Opts, "/opt/riak")),
    list_bitcask_keys_to_file(proplists:get_value(bitcask_dir, Opts,
                                                  "/data/bitcask"),
                              proplists:get_value(output_file, Opts)).

get_opts(Args) ->
    get_opts(Args, []).

get_opts(["-r", RiakDir|Args], Opts) ->
    [{riak_dir, RiakDir} | get_opts(Args, Opts)];
get_opts(["-b", BitcaskDir|Args], Opts) ->
    [{bitcask_dir, BitcaskDir} | get_opts(Args, Opts)];
get_opts(["-o", OutputFile|Args], Opts) ->
    [{output_file, OutputFile} | get_opts(Args, Opts)];
get_opts([_Arg|Args], Opts) ->
    get_opts(Args, Opts);
get_opts([], Opts) ->
    Opts.

list_bitcask_keys_to_file(BitcaskDir, File) ->
    {ok, Dirs} = file:list_dir(BitcaskDir),

    lager:info("Listing keys in ~s to ~s", [BitcaskDir, File]),

    {ok, IO} = file:open(File, [append,raw,delayed_write]),

    Count = lists:foldl(fun(Dir, Acc) ->
        Ref = bitcask:open(BitcaskDir ++ "/" ++ Dir),
        bitcask:fold_keys(Ref, fun(BitcaskKey, Acc1) ->
            {Bucket, Key} = binary_to_term(element(2, BitcaskKey)),
            file:write(IO, [Bucket, $,, Key, $\n]),
            Acc1 + 1
        end, Acc)
    end, 0, Dirs),

    file:close(IO),

    lager:info("~p keys written to disk", [Count]).

add_riak_lib_to_path(RiakDir) ->
    lists:foreach(fun(EBin) ->
    code:add_path(EBin)
    end, filelib:wildcard(RiakDir ++ "/lib/*/ebin/")).
