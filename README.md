# Koreapi

This project provided a HTTP Endpoint for interacting with Balboa Metrics services
as well as provide a simple mechanism for pushing data directly into S3 buckets with respect.

## Installation

* Clone repository, git clone TODO place github repo.
* Make sure Ruby is installed on your machine. (Highly Suggested) Install [rbenv](https://github
.com/sstephenson/rbenv) to manage different ruby environments.
* Install bundler

```
$ gem install bundler
```

* Install dependencies with bundle

```
$ bundle install
```

### Dependencies

Currently, there exist a script that consolidates all the domain reports for a given environment.  This report
 is the pushed to Amazon s3.  This requires the '/etc/korea.properties' contain aws credentials.

## Usage

Start the service with.

```
bundle exec ruby koreapi.rb
```

### Config File

By default, the server uses the settings in (./koreapi.default.properties) unless the file "/etc/koreapi.properties" exists.

An example production configuration file is provided at (./koreapi.production.properties.example).

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

TODO: Continue history

## Credits

TODO: Write credits

## License

TODO: Write license
