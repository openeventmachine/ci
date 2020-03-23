*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Start\\s*event\\s*group
...    Start\\s*assigned\\s*event\\s*group\\s*
...    Assigned\\s*event\\s*group\\s*notification\\s*event\\s*received\\s*after\\s*[0-9]+\\s*data\\s*events\\.
...    Cycles\\s*curr:[0-9]+,\\s*ave:[0-9]+
...    "Normal"\\s*event\\s*group\\s*notification\\s*event\\s*received\\s*after\\s*2048\\s*data\\s*events\\.
...    Cycles\\s*curr:[0-9]+,\\s*ave:[0-9]+
...    Chained\\s*event\\s*group\\s*done
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Event Group Assign End
    [Documentation]    event_group_assign_end -c ${core_mask} -${mode}
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    15s

    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    Should Be Equal As Integers    ${output.rc}   -2    Return Code: ${output.rc}

    :FOR    ${line}    IN    @{match}
    \    Should Match Regexp    ${output.stdout}    ${line}
    :FOR    ${line}    IN    @{do_not_match}
    \    Should Not Match Regexp    ${output.stdout}    ${line}
