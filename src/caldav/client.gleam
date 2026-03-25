import caldav/config
import caldav/types

/// Creates a client wrapper from a configuration value.
pub fn new(config: config.Config) -> types.Client {
  types.Client(config: config)
}

/// Returns the configuration stored in the client.
pub fn config(client: types.Client) -> config.Config {
  client.config
}
