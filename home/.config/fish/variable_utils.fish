# GNU sedとBSD sedの違いを吸収する
if [ (uname) = 'Darwin' ]
    set sed_cmd gsed
else
    set sed_cmd sed
end

function check_variable_existence
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 2
        return 1
    end

    set -l variable_name $argv[1]
    set -l scope $argv[2]
    ##################################
    # argv check end
    ##################################

    eval (echo "set --$scope --names") | grep --color=never -E '^'$variable_name'$' > /dev/null
end

function _get_flag
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 3
        return 1
    end

    set -l variable_name $argv[1]
    set -l scope $argv[2]
    set -l flag_name $argv[3] # export_flag or path_flag
    ##################################
    # argv check end
    ##################################

    check_variable_existence $variable_name $scope
    if test $status -ne 0
        echo "not exist $scope scope variable `$variable_name`" 1>&2
        return 1
    end

    # https://github.com/fish-shell/fish-shell/blob/874fc439ddd884b965b99a475c248eec83a0b58a/src/builtin_set.cpp#L510-L514
    string match -rq '\A\$'$variable_name': set in '$scope' scope, (?<export_flag>(un)?exported),(?<path_flag>(| a path variable)) with \d+ elements\Z' -- (set --show $variable_name)
    if test $status -ne 0
        echo 'Illegal state.
ut of `set --show` command may be changed.' 1>&2
        return 1
    else
        echo $$flag_name
    end
end

function get_export_flag
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 2
        return 1
    end

    set -l variable_name $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]
    ##################################
    # argv check end
    ##################################

    set -l export_message (_get_flag $variable_name $scope export_flag)
    switch $export_message
        case 'exported'
            echo 'export'
        case 'unexported'
            echo 'unexport'
        case '*'
            echo 'Illegal state' 1>&2
            return 1
    end
end

function get_path_flag
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 2
        return 1
    end

    set -l variable_name $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]
    ##################################
    # argv check end
    ##################################

    set -l path_message (_get_flag $variable_name $scope path_flag)
    switch $path_message
        case ''
            echo 'unpath'
        case ' a path variable'
            echo 'path'
        case '*'
            echo 'Illegal state' 1>&2
            return 1
    end
end

function dump_variable
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 2
        return 1
    end

    if not string match -q $argv[1] 'global' 'universal'
        echo '$argv[1] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[1]

    set -l variable_name $argv[2]
    ##################################
    # argv check end
    ##################################

    check_variable_existence $variable_name $scope
    if test $status -ne 0
        echo "not exist $scope scope variable `$variable_name`" 1>&2
        return 1
    end

    set -l path_flag (get_path_flag $variable_name $scope)
    set -l export_flag (get_export_flag $variable_name $scope)
    set -l values (echo "'"$$variable_name"'")
    echo "set --$scope --$path_flag --$export_flag $variable_name $values"
end

complete -c dump_variable -n __fish_is_first_arg -xa "(string unescape 'universal\tuniversal scope\nglobal\tglobal scope')"

complete -c dump_variable -n "__fish_prev_arg_in global" -xa "(set -g | sed -e 's/ /\t/')"
complete -c dump_variable -n "__fish_prev_arg_in universal" -xa "(set -U | sed -e 's/ /\t/')"

function dump_variables
    ##################################
    # argv check start
    ##################################
    if not test (count $argv) -ge 2
        return 1
    end

    if not string match -q $argv[1] 'global' 'universal'
        echo '$argv[1] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[1]

    set -l variable_names $argv[2..-1]
    ##################################
    # argv check end
    ##################################

    for variable_name in $variable_names
        check_variable_existence $variable_name $scope
        if test $status -ne 0
            echo "not exist $scope scope variable `$variable_name`" 1>&2
            return 1
        end
    end

    for variable_name in $variable_names
        set -l path_flag (get_path_flag $variable_name $scope)
        set -l export_flag (get_export_flag $variable_name $scope)
        set -l values (echo "'"$$variable_name"'")
        echo "set --$scope --$path_flag --$export_flag $variable_name $values"
    end
end

complete -c dump_variables -n __fish_is_first_arg -xa "(string unescape 'universal\tuniversal scope\nglobal\tglobal scope')"


# 参考: https://github.com/fish-shell/fish-shell/blob/4ec06f025c451c24ddc5d2532a7ead38a0005f9e/share/functions/__fish_prev_arg_in.fish
# returns 0 only if first argument is one of the supplied arguments
function __fish_first_arg_in
    set -l tokens (commandline -co)
    set -l tokenCount (count $tokens)
    if test $tokenCount -lt 2
        # need at least cmd and first argument
        return 1
    end
    for arg in $argv
        if string match -q -- $tokens[2] $arg
            return 0
        end
    end

    return 1
end

complete -c dump_variables -n "not __fish_is_first_arg; and __fish_first_arg_in global" -xa "(set -g | sed -e 's/ /\t/')"
complete -c dump_variables -n "not __fish_is_first_arg; and __fish_first_arg_in universal" -xa "(set -U | sed -e 's/ /\t/')"

function backup_variables
    ##################################
    # argv check start
    ##################################
    if not test (count $argv) -ge 3
        return 1
    end

    set -l filepath $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]

    set -l variable_names $argv[3..-1]

    ##################################
    # argv check end
    ##################################

    dump_variables $scope $variable_names > $filepath
end

# 参考: https://github.com/fish-shell/fish-shell/blob/4ec06f025c451c24ddc5d2532a7ead38a0005f9e/share/functions/__fish_is_first_arg.fish
# determine if this is the very second argument (regardless if switch or not)
function __fish_is_second_arg
    set -l tokens (commandline -poc)
    test (count $tokens) -eq 2
end

# 参考: https://github.com/fish-shell/fish-shell/blob/4ec06f025c451c24ddc5d2532a7ead38a0005f9e/share/functions/__fish_prev_arg_in.fish
# returns 0 only if second argument is one of the supplied arguments
function __fish_second_arg_in
    set -l tokens (commandline -co)
    set -l tokenCount (count $tokens)
    if test $tokenCount -lt 3
        # need at least cmd and second argument
        return 1
    end
    for arg in $argv
        if string match -q -- $tokens[3] $arg
            return 0
        end
    end

    return 1
end


complete -c backup_variables -n __fish_is_first_arg --force-files
complete -c backup_variables -n __fish_is_second_arg -xa "(string unescape 'universal\tuniversal scope\nglobal\tglobal scope')"
complete -c backup_variables -n "not __fish_is_first_arg; and not __fish_is_second_arg; and __fish_second_arg_in global" -xa "(set -g | sed -e 's/ /\t/')"
complete -c backup_variables -n "not __fish_is_first_arg; and not __fish_is_second_arg; and __fish_second_arg_in universal" -xa "(set -U | sed -e 's/ /\t/')"


function backup_variable_dialog
    ##################################
    # argv check start
    ##################################
    if not test (count $argv) -eq 2
        return 1
    end

    set -l filepath $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]

    ##################################
    # argv check end
    ##################################

    set -l variable_names
    switch $scope
        case global
            set variable_names (set -gn)
        case universal
            set variable_names (set -Un)
        case '*'
            echo 'Illegal state' 1>&2
            return 1
    end

    set -l vars_in_file
    if test -f $filepath
        set vars_in_file (cat $filepath | $sed_cmd -E 's/^set --(universal|global) --(|un)path --(|un)export (\S+) .*$/\4/')
    end

    set -l items
    for variable_name in $variable_names
        set -a items $variable_name
        set -a items (string escape -- "$$variable_name")
        if contains $variable_name $vars_in_file
            set -a items ON
        else
            set -a items OFF
        end
    end
    # http://manpages.ubuntu.com/manpages/xenial/man1/whiptail.1.html
    set -l selected_vars_with_dq (dialog --checklist text 0 0 0 -- $items 3>&1 1>&2 2>&3)
    if test $status -ne 0
        echo 'dialogでエラー発生' 1>&2
        echo $selected_vars
        return 1
    end

    set -l selected_vars (echo $selected_vars_with_dq | string split ' ' | string trim --chars='"')
    backup_variables $filepath $scope $selected_vars
end

complete -c backup_variable_dialog -n __fish_is_first_arg --force-files
complete -c backup_variable_dialog -n __fish_is_second_arg -xa "(string unescape 'universal\tuniversal scope\nglobal\tglobal scope')"
