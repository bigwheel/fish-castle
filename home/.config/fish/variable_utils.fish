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

    set -l variable_name $argv[1]

    if not string match -q $argv[2] 'global' 'universal'
        echo '$argv[2] must be `global` or `universal`' 1>&2
        return 1
    end
    set -l scope $argv[2]
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

complete --no-files -c dump_variable -a (begin set -nU ; set -ng; end | sort | uniq | tr '\n' '\t')
