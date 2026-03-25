import caldav/auth

/// Stores the connection settings used by the CalDAV client.
pub type Config {
  Config(base_url: String, auth: auth.Auth, user_agent: String, timeout_ms: Int)
}

const default_user_agent = "caldav_gleam/1.0.0"

const default_timeout_ms = 10_000

/// Creates a config with the required base URL and authentication settings.
pub fn new(base_url: String, auth: auth.Auth) -> Config {
  Config(
    base_url: base_url,
    auth: auth,
    user_agent: default_user_agent,
    timeout_ms: default_timeout_ms,
  )
}

/// Returns a copy of the config with a custom user agent.
pub fn with_user_agent(config: Config, user_agent: String) -> Config {
  Config(
    base_url: config.base_url,
    auth: config.auth,
    user_agent: user_agent,
    timeout_ms: config.timeout_ms,
  )
}

/// Returns a copy of the config with a custom timeout in milliseconds.
pub fn with_timeout(config: Config, timeout_ms: Int) -> Config {
  Config(
    base_url: config.base_url,
    auth: config.auth,
    user_agent: config.user_agent,
    timeout_ms: timeout_ms,
  )
}
