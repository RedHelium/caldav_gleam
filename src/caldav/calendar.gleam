import caldav/error
import caldav/types

/// Lists calendars available under the discovered calendar home set.
pub fn list_calendars(
  client: types.Client,
  discovery: types.DiscoveryInfo,
) -> Result(List(types.Calendar), error.Error) {
  todo
}
