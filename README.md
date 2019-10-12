# Fusuma::Plugin::Wmctrl

Window Manager plugin for [Fusuma](https://github.com/iberianpig/fusuma)

## Installation

Run following commands in your terminal

### Install wmctrl

for using wmctrl in this plugin

```
$ sudo apt install wmctrl
```
### Install fusuma-plugin-wmctrl

```sh
$ gem install fusuma-plugin-wmctrl
```

## Properties

Add `workspace:` property in `~/.config/fusuma/config.yml`

* Currently, following value are available for `workspace`
  * `prev`
  * `next`


## Example
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
