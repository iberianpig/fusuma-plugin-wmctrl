# Fusuma::Plugin::Wmctrl [![Gem Version](https://badge.fury.io/rb/fusuma-plugin-wmctrl.svg)](https://badge.fury.io/rb/fusuma-plugin-wmctrl) [![Build Status](https://travis-ci.com/iberianpig/fusuma-plugin-wmctrl.svg?branch=master)](https://travis-ci.com/iberianpig/fusuma-plugin-wmctrl)


Window Manager plugin for [Fusuma](https://github.com/iberianpig/fusuma)

* Move window or workspace instead of xdotool
* Works on Wayland(Not depends on xdotool)

## Installation

Run the following code in your terminal.

### 1.Install wmctrl

#### For Debian Based Distros (Ubuntu, Debian, Mint, Pop!_OS)

```
$ sudo apt install wmctrl -y
```

#### For Arch Based Distros (Manjaro, Arch)

```
sudo pacman -S wmctrl
```

### 2. Install fusuma-plugin-wmctrl

This plugin requires [Fusuma](https://github.com/iberianpig/fusuma#update) version 1.0 or later.


**Note For Arch Based Distros:** By default in Arch Linux, when running ```gem```, gems are installed per-user (into ```~/.gem/ruby/```), instead of system-wide (into ```/usr/lib/ruby/gems/```). This is considered the best way to manage gems on Arch, because otherwise they might interfere with gems installed by Pacman. (From Arch Wiki)

To install gems system-wide, see any of the methods listed on [Arch Wiki](https://wiki.archlinux.org/index.php/ruby#Installing_gems_system-wide)

```sh
$ sudo gem install fusuma-plugin-wmctrl
```

## Properties

### `workspace:` property
Add `workspace:` property in `~/.config/fusuma/config.yml`.

Values following are available for `workspace`.

  * `prev` is value to switch current workspace to previous workspace.
  * `next` is value to switch current workspace to next workspace.

### `window:` property
Add `window:` property in `~/.config/fusuma/config.yml`.

Values following are available for `window`.

  * `prev` is value to move active window to previous workspace.
  * `next` is value to move active window to next workspace.
  * `fullscreen` is value to toggle fullscreen
    * `fullscreen: toggle` toggles the active window to fullscreen.
      ```yml
        window: fullscreen
        # ↑ same ↓
        window: 
          fullscreen: toggle
      ```

    * `fullscreen: add` changes the active window to a fullscreen.
      ```yml
        window: 
          fullscreen: add
      ``` 

    * `fullscreen: remove` restores the active window from fullscreen.
      ```yml
        window: 
          fullscreen: remove
      ```
  * `maximized` is value to toggle maximized
    * `maximized: toggle` toggles the active window to maximized.
      ```yml
        window: maximized
        # ↑ same ↓
        window: 
          maximized: toggle
      ```

    * `maximized: add` changes the active window to a maximized.
      ```yml
        window: 
          maximized: add
      ``` 

    * `maximized: remove` restores the active window from maximized.
      ```yml
        window: 
          maximized: remove
      ```


## Example

Set `workspace:` property and values in `~/.config/fusuma/config.yml`.

```yaml
swipe:
  4:
    left: 
      workspace: 'next'
    right: 
      workspace: 'prev'
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iberianpig/fusuma-plugin-wmctrl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fusuma::Plugin::Wmctrl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/iberianpig/fusuma-plugin-wmctrl/blob/master/CODE_OF_CONDUCT.md).
