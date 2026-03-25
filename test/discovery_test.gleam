import caldav/error
import caldav/internal/xml_response

pub fn parse_current_user_principal_test() {
  let assert Ok(principal) =
    xml_response.parse_current_user_principal(principal_fixture())

  assert principal == "/dav/principals/users/demo/"
}

pub fn parse_calendar_home_set_test() {
  let assert Ok(home_set) =
    xml_response.parse_calendar_home_set(calendar_home_set_fixture())

  assert home_set == "/dav/calendars/demo/"
}

pub fn parse_current_user_principal_returns_error_for_invalid_xml_test() {
  let assert Error(error.XmlError(_)) =
    xml_response.parse_current_user_principal(
      "<d:multistatus xmlns:d=\"DAV:\" />",
    )
}

fn principal_fixture() -> String {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<d:multistatus xmlns:d=\"DAV:\">\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:current-user-principal>\n"
  <> "          <d:href>/dav/principals/users/demo/</d:href>\n"
  <> "        </d:current-user-principal>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "</d:multistatus>\n"
}

fn calendar_home_set_fixture() -> String {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<d:multistatus xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/principals/users/demo/</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <c:calendar-home-set>\n"
  <> "          <d:href>/dav/calendars/demo/</d:href>\n"
  <> "        </c:calendar-home-set>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "</d:multistatus>\n"
}
