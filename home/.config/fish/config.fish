if status is-interactive
    # 以下は期待通りに動いていない気がする
    # # https://qiita.com/yoshiori/items/f1c01dd94bb5f0489cf6
    # function history-merge --on-event fish_preexec
    #     history --save
    #     history --merge
    # end

    set HOMEBREW_PREFIX /opt/homebrew
    fish_add_path $HOMEBREW_PREFIX/bin
    fish_add_path $HOME/bin
    fish_add_path $HOME/.local/bin

    fish_add_path $HOME/.tfenv/bin

    # fisherのインストールを自動化
    if not test -e $__fish_config_dir/fish_plugins
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end

    # asdfのセットアップだけ自動化した。インストールは自動化されていない
    if not [ (uname) = 'Darwin' ]
      if test -e ~/.asdf
          source ~/.asdf/asdf.fish
          if not test -e ~/.config/fish/completions/asdf.fish
              mkdir -p ~/.config/fish/completions
              ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
          end
      end
    end

    fish_add_path $HOME/.krew/bin

    # https://fishshell.com/docs/current/tutorial.html#path
    # http://qiita.com/takyam/items/d6afacc7934de9b0e85e
    if [ (uname) = 'Darwin' ]
        set -gx RUBY_CONFIGURE_OPTS "--with-openssl-dir=(brew --prefix openssl@1.1)"
        # 実験中。
        # https://github.com/rbenv/ruby-build/issues/1699#issuecomment-762122911
        # だけで動くなら以下は削除すること。
        # M1 macにRuby 2.6 / 2.7をインストールするための設定
        # https://stackoverflow.com/a/69012677
        # イコールを消したりbrewpath変数を使うようにしたりで、ちゃんと使うならもうちょい手直し必要
        # set -gx RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
        # set -gx LDFLAGS="-L/opt/homebrew/opt/readline/lib:$LDFLAGS"
        # set -gx CPPFLAGS="-I/opt/homebrew/opt/readline/include:$CPPFLAGS"
        # set -gx PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig:$PKG_CONFIG_PATH"
        # set -gx optflags="-Wno-error=implicit-function-declaration"
        # set -gx LDFLAGS="-L/opt/homebrew/opt/libffi/lib:$LDFLAGS"
        # set -gx CPPFLAGS="-I/opt/homebrew/opt/libffi/include:$CPPFLAGS"
        # set -gx PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"

        fish_add_path $HOMEBREW_PREFIX/share/git-core/contrib/diff-highlight # mac
        fish_add_path $HOMEBREW_PREFIX/opt/mysql-client/bin
        fish_add_path $HOMEBREW_PREFIX/opt/findutils/libexec/gnubin
        fish_add_path $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
        fish_add_path $HOMEBREW_PREFIX/opt/grep/libexec/gnubin
        source $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.fish
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

    if test -e $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
    end

    if set -q WSLENV
        set -x BROWSER "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
        set -x GH_BROWSER "/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
        set -x EDITOR vim
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    end

    if which direnv > /dev/null 2>&1
        direnv hook fish | source
    end
end
