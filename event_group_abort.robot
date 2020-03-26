*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Round [0-9]+
...    Created\\s*[0-9]+\\s*event\\s*group\\(s\\)\\s*with\\s*count\\s*of\\s*[0-9]+
...    Abort\\s*group\\s*when\\s*received\\s*[0-9]+\\s*events
...    Evgrp\\s*events:\\s*Valid:[0-9]+\\s*Expired:[0-9]+
...    Evgrp\\s*increments:\\s*Valid:[0-9]+\\s*Failed:[0-9]+
...    Evgrp\\s*assigns:\\s*Valid:[0-9]+\\s*Failed:[0-9]+
...    Aborted\\s*[0-9]+\\s*event\\s*groups
...    Failed\\s*to\\s*abort\\s*[0-9]+\\s*times
...    Received\\s*[0-9]+\\s*notification\\s*events
...    Freed\\s*[0-9]+\\s*notification\\s*events
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}

*** Test Cases ***
Test Event Group Abort
    [Documentation]    event_group_abort -c ${core_mask} -${mode}
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    15s

    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    List Should Contain Value    ${rc_list}    ${output.rc}    Return Code: ${output.rc}

    :FOR    ${line}    IN    @{match}
    \    Should Match Regexp    ${output.stdout}    ${line}
    :FOR    ${line}    IN    @{do_not_match}
    \    Should Not Match Regexp    ${output.stdout}    ${line}
