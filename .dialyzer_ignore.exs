# to get the proper short format:
#
# $ MIX_ENV=test mix dialyzer --format short
#
[
  # Ignore dialyzer warnings for test fixtures and support files
  {"test/support/fixtures/accounts_fixtures.ex"},
  {"test/support/channel_case.ex"},
  {"test/support/conn_case.ex"},
  {"test/support/data_case.ex"}
]
