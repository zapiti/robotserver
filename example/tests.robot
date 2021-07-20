*** Settings ***
Library           Remote    http://${ADDRESS}:${PORT}    WITH NAME    MyTest

*** Variables ***
${ADDRESS}        127.0.0.1
${PORT}           5001
${MESSAGE}        Hello, wold!
${isExist}        ${TRUE}
${variable1}      teste

*** Test Cases ***
Describe myTest
    ${myTest details} =    MyTest.describe
    Log    ${myTest details}
    Should Be True     "${variable1}" == "${myTest details}"


Another Test
    Should Be Equal   ${MESSAGE}    Hello, wold!
    Should Be Equal   ${MESSAGE}    Hello, wold!
    Run Keyword If     ${isExist} is ${FALSE}  ELSE  No Operation


Gherkin
    [Documentation]  This test case fails a dry-run
    Given Run Keyword If  3 == 4  Fatal Error  ELSE  No Operation
    When Run Keyword If  3 == 4  Fatal Error  ELSE  No Operation
    And Run Keyword If  3 == 4  Fatal Error  ELSE  No Operation
    Then Run Keyword If  3 == 4  Fatal Error  ELSE  No Operation

No Gherkin
    [Documentation]  This test case works just fine
    Run Keyword If  3 == 4  Fatal Error  ELSE  No Operation

