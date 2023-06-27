#!/bin/bash

bashrc_root=$HOME/bashrc
asdf_root=/usr/local/asdf

elixir_ls_root=/usr/local/elixir-ls
elixir_ls_build_dir=build

bashrc_asdf_patch="
__ASDF_ROOT='$asdf_root'

if test -d "'"'"\$__ASDF_ROOT"'"'"; then
    . "'"'"\$__ASDF_ROOT/asdf.sh"'"'"
    . "'"'"\$__ASDF_ROOT/completions/asdf.bash"'"'"
fi
"

bashrc_elixir_ls_patch="
export ELIXIR_LS_ROOT='$elixir_ls_root/$elixir_ls_build_dir'
"

quit () {
    if test ! -z "$1"; then
        echo "Error: $1"
    else
        echo "Error"
    fi

    exit ${2:-1}
}

patch_bashrc () {
    if test -d "$bashrc_root"; then
        echo -e "$1" | head -n -1 >> $bashrc_root/etc/main.sh
    else
        echo -e "$1" | head -n -1 >> $HOME/.bashrc
    fi

    . $HOME/.bashrc
}

install_runtime () {
    plugin=$1
    verions=$2

    if test -z $(asdf plugin list | grep "$plugin"); then
        asdf plugin add "$plugin"
    else
        echo "plugin $plugin is already installed"
    fi

    if test -z $(asdf list "$plugin" | grep "$version"); then
        asdf install "$plugin" "$version"
    else
        echo "found required $plugin version $version"
    fi
}

# 1. Install asdf if it is not available

if test -z $(which asdf); then
    if test -d "$asdf_root"; then
        quit "Directory $asdf_root already exists. Cannot install asdf"
    else
        echo 'installing asdf...'

        sudo apt-get update
        sudo apt-get install libncurses5-dev libssl-dev automake autoconf

        sudo git clone https://github.com/asdf-vm/asdf.git $asdf_root

        patch_bashrc "$bashrc_asdf_patch"
    fi
else
    echo 'found existing asdf installation'
fi

# 2. Install erlang

erlang_version=$(cat .tool-versions | grep erlang | cut -d ' ' -f 2)

install_runtime erlang "$elixir_version"

# if test -z $(asdf plugin list | grep erlang); then
#     asdf plugin add erlang
# else
#     echo 'plugin erlang is already installed'
# fi
# 
# if test -z $(asdf list erlang | grep $erlang_version); then
#     asdf install erlang $erlang_version
# else
#     echo "found required erlang version $erlang_version"
# fi

# 3. Install elixir

elixir_version=$(cat .tool-versions | grep elixir | cut -d ' ' -f 2)

install_runtime elixir "$elixir_version"

# if test -z $(asdf plugin list | grep elixir); then
#     asdf plugin add elixir
# else
#     echo 'plugin elixir is already installed'
# fi
# 
# if test -z $(asdf list elixir | grep $elixir_version); then
#     asdf install elixir $elixir_version
# else
#     echo "found required elixir version $elixir_version"
# fi

# 4. Set up the language server

if test -d "$elixir_ls_root"; then
    echo 'found existing elixir-ls installation'
else
    sudo git clone https://github.com/elixir-lsp/elixir-ls.git "$elixir_ls_root"
    sudo chown $USER "$elixir_ls_root"
fi

if test -d "$elixir_ls_root/$elixir_ls_build_dir"; then
    echo 'found existing elixir-ls build'
else
    pushd "$elixir_ls_root"

    asdf local erlang $erlang_version
    asdf local elixir $elixir_version

    mix deps.get
    MIX_ENV=prod mix compile
    MIX_ENV=prod mix elixir_ls.release2 -o "$elixir_ls_build_dir"

    patch_bashrc "$bashrc_elixir_ls_patch"

    popd
fi

# 5. Pull dependencies

mix deps.get
