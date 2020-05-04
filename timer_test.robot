*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EO *
...    Timer\: Creating [1-9]+[0-9]* timeouts took [1-9]+[0-9]* ns \\([1-9]+[0-9]* ns each\\)
...    Linux\: Creating [1-9]+[0-9]* timeouts took [1-9]+[0-9]* ns \\([1-9]+[0-9]* ns each\\)
...    Running
...    Heartbeat count [1-9]+[0-9]*
...    ONESHOT\:
...    Received: [1-9]+[0-9]*
...    Cancelled\: [0-9]+
...    Cancel failed \\(too late\\)\: [0-9]+
...    SUMMARY/TICKS: min [0-9]+, max [0-9]+, avg [0-9]+
...    /[A-Z]S: min [0-9]+, max [0-9]+, avg [0-9]+
...    PERIODIC\:
...    Cancel failed \\(too late\\)\: [0-9]+
...    Errors\: [0-9]+
...    Cleaning up
...    Timer\: Deleting [1-9]+[0-9]* timeouts took [1-9]+[0-9]* ns \\([1-9]+[0-9]* ns each\\)
...    Linux\: Deleting [1-9]+[0-9]* timeouts took [1-9]+[0-9]* ns \\([1-9]+[0-9]* ns each\\)

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Timer
    [Documentation]    timer_test -c ${core_mask} -${mode}

    # Run application
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    85s

    # Terminate application
    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    List Should Contain Value    ${rc_list}    ${output.rc}    Return Code: ${output.rc}

    # Match terminal output
    FOR    ${line}    IN    @{match}
        Should Match Regexp    ${output.stdout}    ${line}
    END
    FOR    ${line}    IN    @{do_not_match}
        Should Not Match Regexp    ${output.stdout}    ${line}
    END

    # Match pool statistics
    FOR    ${line}    IN    @{pool_statistics_match}
        Should Match Regexp    ${output.stdout}    ${line}
    END
