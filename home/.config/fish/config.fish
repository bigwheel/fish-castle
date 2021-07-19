if status is-interactive
    # Commands to run in interactive sessions can go here

    # fisherのインストールを自動化
    if not test -e $__fish_config_dir/fish_plugins
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end

    # asdfのセットアップだけ自動化した。インストールは自動化されていない
    if test -e ~/.asdf
        source ~/.asdf/asdf.fish
        if not test -e ~/.config/fish/completions/asdf.fish
            mkdir -p ~/.config/fish/completions
            ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
        end
    end


    # https://fishshell.com/docs/current/tutorial.html#path
    # http://qiita.com/takyam/items/d6afacc7934de9b0e85e
    if [ "(uname)" = 'Darwin' ]; then
        fish_add_path /usr/local/share/git-core/contrib/diff-highlight # mac
    else
        fish_add_path /usr/share/doc/git/contrib/diff-highlight # ubuntu
    end

    source $__fish_config_dir/variable_utils.fish
    if test -e $HOME/.cargo/bin
        fish_add_path $HOME/.cargo/bin
    end
    starship init fish | source

    if test -e $HOME/.homesick/repos/homeshick/homeshick.fish
        source "$HOME/.homesick/repos/homeshick/homeshick.fish"
    end
end
