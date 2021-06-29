if status is-interactive
    # Commands to run in interactive sessions can go here

    # asdfのセットアップだけ自動化した。インストールは自動化されていない
    if test -e ~/.asdf
        source ~/.asdf/asdf.fish
        if not test -e ~/.config/fish/completions/asdf.fish
            mkdir -p ~/.config/fish/completions
            ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
        end
    end
end
