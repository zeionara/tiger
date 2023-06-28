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

disable_interactive_check () {
  bashrc_path="$1"
  bashrc_path_tmp="$2"
  bashrc_path_cache="$3"

  inside_running_interactively_block=false
  
  while IFS= read -r line; do
    if [ -z "$line" ]; then
      inside_running_interactively_block=false
    fi
  
    if [ "$inside_running_interactively_block" = true ] && [[ "$line" != "#"* ]]; then
      echo "# $line"
    else
      if [[ "$line" == "# If not running interactively"* ]]; then
        inside_running_interactively_block=true
	if [[ "$line" == *"(disabled manually)" ]]; then
	  echo "$line"
	else
          echo "$line (disabled manually)"
	fi
      else
        echo "$line"
      fi
    fi
  
  done < "$bashrc_path" > "$bashrc_path_tmp"
  
  mv "$bashrc_path" "$bashrc_path_cache"
  mv "$bashrc_path_tmp" "$bashrc_path"
}

echop () {
    echo "🚩 $@"
}

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
    version=$2

    if test -z $(asdf plugin list | grep "$plugin"); then
        asdf plugin add "$plugin"
    else
        echop "Plugin $plugin is already installed"
    fi

    if test -z $(asdf list "$plugin" | grep "$version"); then
        asdf install "$plugin" "$version"
    else
        echop "Found required $plugin version $version"
    fi
}

# 0. Preparing .bashrc

echop "Preparing bashrc by disabling interactive check..."

if test ! -d "$bashrc_root"; then
    disable_interactive_check "$HOME/.bashrc" "$HOME/.bashrc.tmp" "$HOME/.bashrc.cache"
fi

# 1. Install asdf if it is not available

if test -z $(which asdf); then
    if test -d "$asdf_root"; then
        quit "Directory $asdf_root already exists. Cannot install asdf"
    else
        echop 'Installing asdf...'

        sudo apt-get update
        sudo apt-get install libncurses5-dev libssl-dev automake autoconf

        sudo git clone https://github.com/asdf-vm/asdf.git "$asdf_root"

        sudo chown $USER "$asdf_root"

        patch_bashrc "$bashrc_asdf_patch"

        # . $HOME/.bashrc

        echop "Checking that asdf is installed properly: $(which asdf)"
    fi
else
    echop 'Found existing asdf installation'
fi

# 2. Install erlang

echop "Installing erlang..."

erlang_version=$(cat .tool-versions | grep erlang | cut -d ' ' -f 2)

install_runtime erlang "$erlang_version"

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

echop "Installing elixir..."

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
    echop 'Found an existing elixir-ls installation'
else
    sudo git clone https://github.com/elixir-lsp/elixir-ls.git "$elixir_ls_root"
    sudo chown $USER "$elixir_ls_root"
fi

if test -d "$elixir_ls_root/$elixir_ls_build_dir"; then
    echop 'Found existing elixir-ls build'
else
    pushd "$elixir_ls_root"

    asdf local erlang "$erlang_version"
    asdf local elixir "$elixir_version"

    mix deps.get
    MIX_ENV=prod mix compile
    MIX_ENV=prod mix elixir_ls.release2 -o "$elixir_ls_build_dir"

    patch_bashrc "$bashrc_elixir_ls_patch"

    # . $HOME/.bashrc

    popd
fi

# 5. Pull dependencies

mix deps.get
