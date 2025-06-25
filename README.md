# NeoVim Config

NeoVim config for C++ and Python without package managers or Node.js.
See [pack/nvim/start](https://github.com/choll/nvim/tree/main/pack/nvim/start) for installed plugins.

## Installation

```
git clone --recurse-submodules https://github.com/choll/nvim.git ~/.config/nvim
```

## Requirements

### C++

```
apt install clangd clang-format
```

### Python

```
apt install python3-pylsp python3-pylsp-black python3-pylsp-rope black python3-pyflakes python3-jedi python3-rope
```

or:

```
pip install python-lsp-server python-lsp-black pylsp-rope black pyflakes jedi rope
```
