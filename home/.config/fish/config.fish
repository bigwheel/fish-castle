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

    fish_add_path $HOME/.krew/bin

    # https://fishshell.com/docs/current/tutorial.html#path
    # http://qiita.com/takyam/items/d6afacc7934de9b0e85e
    if [ (uname) = 'Darwin' ]
        fish_add_path /usr/local/share/git-core/contrib/diff-highlight # mac
        fish_add_path /usr/local/opt/mysql-client/bin
        source /usr/local/opt/asdf/libexec/asdf.fish
    else
        fish_add_path /usr/share/doc/git/contrib/diff-highlight # ubuntu
    end

    source $__fish_config_dir/variable_utils.fish
    if test -e $HOME/.cargo/bin
        fish_add_path $HOME/.cargo/bin
    end
    if not which starship > /dev/null 2>&1
        # この下がfishで意図通り動いてくれない。今度直すこと
        sh -c "(curl -fsSL https://starship.rs/install.sh)"
    end
    starship init fish | source

    if test -e $HOME/.homesick/repos/homeshick/homeshick.fish
        source "$HOME/.homesick/repos/homeshick/homeshick.fish"
    end

    if test -e /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
    end
end
