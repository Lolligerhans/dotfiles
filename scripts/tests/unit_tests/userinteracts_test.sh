#!/usr/bin/env false

# version 0.0.0

test_user_prompts()
{
  declare res;
  boolean_prompt "Dummy prompt" res <<< "y";
  assert_eq "$res" "y" "Basic y";

  res="";
  boolean_prompt "Dummy prompt" res <<< "Y";
  assert_eq "$res" "y" "Capital y";

  res="";
  boolean_prompt "Dummy prompt" res <<< "ye";
  assert_eq "$res" "n" "'ye' is rejected";

  res="";
  boolean_prompt "Dummy prompt" res <<< "yes";
  assert_eq "$res" "y" "'yes' is accepted";

  res="";
  boolean_prompt "Dummy prompt" res <<< "yEs";
  assert_eq "$res" "y" "case is ignored";

  res="";
  boolean_prompt "Dummy prompt" res <<< "n";
  assert_eq "$res" "n" "'n' is rejected";

  res="";
  boolean_prompt "Dummy prompt" res <<< "N";
  assert_eq "$res" "n" "'N' is rejected";

  res="";
  declare in="$RANDOM";
  boolean_prompt "Dummy prompt" res <<< "$in";
  assert_eq "$res" "n" "random input '$in' is rejected";

  res="";
  boolean_prompt "Dummy prompt" res <<< "yno";
  assert_eq "$res" "n" "not only the first letter is processed";

  errchos "No tests for the other two user input functions";
}
