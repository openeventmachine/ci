*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EO *
...    System has [1-9]+[0-9]* timer
...    resolution. [1-9]+[0-9]* ns
...    max_tmo. [1-9]+[0-9]* ms
...    num_tmo. [1-9]+[0-9]*
...    tick Hz. [1-9]+[0-9]* hz
...    EO local start
...    [1-9]+[0-9]*\. tick
...    tock
...    Meditation time. what can you do in [1-9]+[0-9]* ms\?

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Timer Hello
    [Documentation]    timer_hello -c ${core_mask} -${mode}

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
