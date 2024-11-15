# Tests

> [!NOTE]
> Tests are not very comprehensive at the moment

- Test our bash code
- Test assumptions
  - Available binaries
  - Features of binaries
  - Behaviour of bash version

```text
dotfiles
├── scripts/
│   ├── *.sh
│   └── tests/
│       ├── log/
│       │   ├── *.log
│       │   └── test.log
│       ├── run.sh
│       ├── tests.sh
│       └── unit_tests/
│           └── *_test.sh
└── shellcheck.txt
```

## Runscript

The runscript `run.sh` is used to start tests.

```bash
./run.sh test --all
./run.sh test --automated
./run.sh test --shellcheck
./run.sh test --colour
```

The runscript includes helper functions implementing the execution and logging
of individual test functions. It does not contain any tests itself.

## Tests script

The test script `tests.sh` implements all available test functions. A script
*name*.sh has one associated test function *name*_test(). Test functions exit
`0` when the test is passed, else `1`. The output of test functions may be as
verbose as required on both stdout and stderr. The runscript will silence as
appropriate.

If a test function needs to be large, it is moved into its own [unit
test](#unit-tests) file.

## Unit tests

- Files in `unit_tests/`
- Naming convention
  - Implementation: *name*.sh
  - Test file: *name*_test.sh
  - Test function: *name*_test()
  - Individual unit test: test_*()
