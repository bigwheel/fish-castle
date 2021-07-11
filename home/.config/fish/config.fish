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


    # universal variableを使うべきだがどう書いたらいいかわからない。
    # universal variable、複数の環境で定義できなくない？
    # http://qiita.com/takyam/items/d6afacc7934de9b0e85e
    # if [ "$(uname)" = 'Darwin' ]; then
    #     export PATH=$PATH:/usr/local/share/git-core/contrib/diff-highlight # mac
    # else
    #     export PATH=$PATH:/usr/share/doc/git/contrib/diff-highlight # ubuntu
    # end

    source $__fish_config_dir/variable_utils.fish
end
