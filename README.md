[![Maintainability](https://api.codeclimate.com/v1/badges/030196c789926bb3382f/maintainability)](https://codeclimate.com/github/ministryofjustice/prison-visits-public/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/030196c789926bb3382f/test_coverage)](https://codeclimate.com/github/ministryofjustice/prison-visits-public/test_coverage)

# Visit someone in prison

A service for requesting a social visit to a prisoner in England or Wales.


## Live application

Production application is made available through GOV.UK and can be found at [https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits)


## Technical Information

This a Ruby on Rails application that contains the public interface for booking a prison visit.

It is *stateless* and relies entirely on the prison visits booking API exposed by [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2).

The codebase was split from [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2), which previously was also responsible for serving the public interface.


### Dependencies

- [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2). This a separate Ruby on Rails application that exposes prison information, slot availability, and allows booking and managing a visit. Details of the API methods consumed can be found in [api.rb](app/services/prison_visits/api.rb).
- **If on a Mac install Xcode from the App Store**
- [direnv](https://direnv.net/) - for managing environment variables and storing credentials.
- (Optional) Transifex Client. [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) - for managing site translation. See [additional documentation](docs/welsh_translation.md) for setup and updating translations.     


### Ruby version

This application uses Ruby v3.2.2. Use [RVM](https://rvm.io/) or similar to manage your ruby environment and sets of dependencies.

### Running the application

*Note* - You will need to spin up both [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) and [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2)

1. Install gems (dependencies) locally. To do this you will need to first install [Bundler](http://bundler.io/)

2. Install the `direnv` package
    ```sh
    pvb2 $ brew install direnv
    ```

3. Enable **direnv** for you shell

    ##### BASH
    Add the following line at the end of the `~/.bashrc` file:

    ```sh
    eval "$(direnv hook bash)"
    ```
    Make sure it appears even after rvm, git-prompt and other shell extensions that manipulate the prompt.

    ##### ZSH
    Add the following line at the end of the `~/.zshrc` file:

    ```sh
    eval "$(direnv hook zsh)"
    ```
    ##### FISH

    Add the following line at the end of the `~/.config/fish/config.fish` file:

    ```sh
    direnv hook fish | source
    ```

4. Create a .env file in the root of the folder and add any necessary environment variables. Load your environment variables into your current session ...
    ```sh
    pvb-public $ direnv allow .
    ```

7. In separate terminal windows start up [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2) and [Sidekiq](https://sidekiq.org/). The latter processes jobs in the background.

    ```sh
    pvb-public $ bundle exec sidekiq
    pvb-public $ rails server
    ```
8. In another terminal window start up [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) on port 4000

    ```sh
    pvb-public $ rails server -p 4000
    ```

### Running the test suite

```sh
pvb-public $ rspec spec
```    

### Testing approach

During testing, the approach is to stub/mock API calls at the level of the API client, rather than at the HTTP level, since this is considerably cleaner, and decouples API changes. An example of this approach can be seen in [prisoner_step_spec.rb](spec/models/prisoner_step_spec.rb).

The API client is then tested by recording real API interactions using VCR. The only tests recording VCR cassettes should be defined in [api_spec.rb](spec/services/prison_visits/api_spec.rb). If the API changes the appropriate cassettes should be deleted and re-recorded.


### Further Technical Information

More information can be found in the [GitHub Wiki.](https://github.com/ministryofjustice/prison-visits-public/wiki)

## Licence
[MIT Licence (MIT)](LICENCE)

