# Modown

Modown is CLI app for downloading 3D models from archive3D.net

## Installation

    $ gem install modown

## Usage

	$ modown OBJECT

where OBJECT is the name of the thing you want to download.

	$ modown maze
	$ modown boy
	$ modown guitar

Supports Options are
* `--count,-c` The number of different models you want
* `--format,-f` The file format you want, supported formats are `[3ds,max,gsm,mtl]` *Defaults to `*`*


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pulkitsharma07/modown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


