*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EO *
...    Timer\: Creating [0-9]+ timeouts took [0-9]+ ns \\([0-9]+ ns each\\)
...    Linux\: Creating [0-9]+ timeouts took [0-9]+ ns \\([0-9]+ ns each\\)
...    Running
...    Heartbeat count [0-9]+
...    ONESHOT\:
...    Received: [0-9]+
...    Cancelled\: [0-9]+
...    Cancel failed \\(too late\\)\: [0-9]+
...    SUMMARY/TICKS: min [0-9]+, max [0-9]+, avg [0-9]+
...    /[A-Z]S: min [0-9]+, max [0-9]+, avg [0-9]+
...    SUMMARY/LINUX [A-Z]S: min -?[0-9]+, max -?[0-9]+, avg -?[0-9]+
...    PERIODIC\:
...    Received\: [0-9]+
...    Cancelled\: [0-9]+
...    Cancel failed \\(too late\\)\: [0-9]+
...    Errors\: [0-9]+
...    TOTAL RUNTIME/[A-Z]S\: min [0-9]+, max [0-9]+
...    Cleaning up
...    Timer\: Deleting [0-9]+ timeouts took [0-9]+ ns \\([0-9]+ ns each\\)
...    Linux\: Deleting [0-9]+ timeouts took [0-9]+ ns \\([0-9]+ ns each\\)
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Timer
    [Documentation]    timer_test -c ${core_mask} -${mode}
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    90s

    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    Should Be Equal As Integers    ${output.rc}   -2    Return Code: ${output.rc}

    :FOR    ${line}    IN    @{match}
    \    Should Match Regexp    ${output.stdout}    ${line}
    :FOR    ${line}    IN    @{do_not_match}
    \    Should Not Match Regexp    ${output.stdout}    ${line}

