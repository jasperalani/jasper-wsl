# jasper-wsl
This repo contains custom scripts for WSL (Windows Subsystem for Linux) and adds quality of life changes and things like that.

## Installation

1. Clone this repo:
```bash
cd ~/jasper-wsl && git clone --depth 1 https://github.com/jasperalani/jasper-wsl.git .
```

2. Rename the sample .env file:
```bash
mv jwsl.env.sample jwsl.env
```

3. Configure your hugo project path for custom command line aliases (it will ask for path to hugo.toml):
```bash
./config-hugo-project.sh
```

4. Backup your .bashrc file:
```bash
mv ~/.bashrc ~/.bashrc.bak
```

5. Create a symlink from [.bashrc](.bashrc) in this repo to your home directory:
```bash
ln -s ~/jasper-wsl/.bashrc ~/.bashrc
```

6. Reload your .bashrc:
```bash
source ~/.bashrc
```

## View available commands
```bash
helpc
```

## To do
- Check if git account vars are already set and if they have to be replaced
- Add support for multiple hugo projects
- Refactor project out of .bashrc and into its own directory
- Maybe this is a development project manager, look up existing project managers