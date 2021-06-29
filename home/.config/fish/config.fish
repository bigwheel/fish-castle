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
end
