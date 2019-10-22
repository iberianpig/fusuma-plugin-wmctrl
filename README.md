# Fusuma::Plugin::Wmctrl [![Gem Version](https://badge.fury.io/rb/fusuma-plugin-wmctrl.svg)](https://badge.fury.io/rb/fusuma-plugin-wmctrl) [![Build Status](https://travis-ci.com/iberianpig/fusuma-plugin-wmctrl.svg?branch=master)](https://travis-ci.com/iberianpig/fusuma-plugin-wmctrl)


Window Manager plugin for [Fusuma](https://github.com/iberianpig/fusuma)

## Installation

Run the following code in your terminal.

### Install wmctrl

```
$ sudo apt install wmctrl
```
### Install fusuma-plugin-wmctrl

This plugin requires [Fusuma](https://github.com/iberianpig/fusuma#update) version 1.0 or later.

```sh
$ gem install fusuma-plugin-wmctrl
```

## Properties

Add `workspace:` property in `~/.config/fusuma/config.yml`.

Currently, values following are available for `workspace`.
  * `prev`
  * `next`


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
