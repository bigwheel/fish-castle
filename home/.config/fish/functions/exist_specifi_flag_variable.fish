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

    # https://github.com/fish-shell/fish-shell/blob/874fc439ddd884b965b99a475c248eec83a0b58a/src/builtin_set.cpp#L510-L514
    set result_line (set --show $variable_name | grep --color=never $scope)

    if test -z $result_line
        echo "not exist $scope scope variable `$variable_name`" 1>&2
        return 1
    else
        string match -rq '\A\$'$variable_name': set in '$scope' scope, (?<export_flag>(un)?exported),(?<path_flag>(| a path variable)) with \d+ elements\Z' -- $result_line
        if test $status -ne 0
            echo 'Illegal state.
Output of `set --show` command may be changed.' 1>&2
            return 1
        else
            echo $$flag_name
        end
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

    _get_flag $variable_name $scope export_flag
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

function _get_export_flag
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

    # https://github.com/fish-shell/fish-shell/blob/874fc439ddd884b965b99a475c248eec83a0b58a/src/builtin_set.cpp#L510-L514
    set result_line (set --show $variable_name | grep --color=never $scope)

    if test -z $result_line
        echo "not exist $scope scope variable `$variable_name`" 1>&2
        return 1
    else
        string match -rq '\A\$'$variable_name': set in '$scope' scope, (?<export_flag>(un)?exported),(?<path_flag>(| a path variable)) with \d+ elements\Z' -- $result_line
        if test $status -ne 0
            echo 'Illegal state.
Output of `set --show` command may be changed.' 1>&2
            return 1
        else
            echo $export_flag
        end
    end
end

function exist_specifi_flag_variable
    ##################################
    # argv check start
    ##################################
    if test (count $argv) -ne 4
        echo 'Please give 4 arguments:
  1. variable name
  2. `global` or `universal`
    `local` is not valid because local scope variable
    cannot be accessed from this function inside.
  3. `exported` or `unexported`
  4. `path` or `unpath`

  example:
    `variable_check hogehoge universal unpath exported`

  More details: https://fishshell.com/docs/current/language.html#shell-variables' 1>&2
        return 1
    end

    set -l variable_name $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]

    if not string match -q $argv[3] 'exported' 'unexported'
        echo '$argv[3] must be `exported` or `unexported`' 1>&2
        return 1
    end
    set -l export_flag $argv[3]

    if not string match -q $argv[4] 'path' 'unpath'
        echo '$argv[4] must be `path` or `unpath`' 1>&2
        return 1
    end
    set -l path_flag $argv[4]
    ##################################
    # argv check end
    ##################################

    set result_line (set --show $variable_name | grep --color=never $scope)
    test -n $result_line &&
        string match -q -e " $export_flag" $result_line &&
        eval (test $path_flag = 'path' && echo '' || echo 'not') string match -q -e \'a path variable\' \'$result_line\'
end
