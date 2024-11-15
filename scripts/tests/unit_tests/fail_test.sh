#!/usr/bin/env false

# version 0.0.0

# A test failing on purpose.
#   - verify the error trace printing from our ERR trap
#   - verify what the test runner function does when a test fails
fail_test() {
  execute_test test_fail_helper
}

test_fail_helper() {
  false
}
