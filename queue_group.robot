*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Created\\s*test\\s*queue:0x[a-fA-F0-9]+\\s*type:[A-Z]+\\([0-9]+\\)\\s*queue\\s*group:0x[a-fA-F0-9]+\\s*\\(name:"[a-zA-Z0-9]+"\\)
...    Received\\s*[0-9]+\\s*events\\s*on\\s*Q:0x[a-fA-F0-9]+:
...    QueueGroup:0x[a-fA-F0-9]+,\\s*Curr\\s*Coremask:0x[a-fA-F0-9]+
...    Now\\s*Modifying:
...    QueueGroup:0x[a-fA-F0-9]+,\\s*New\\s*Coremask:0x[a-fA-F0-9]+
...    All\\s*cores\\s*removed\\s*from\\s*QueueGroup!
...    Deleting\\s*test\\s*queue:0x[a-fA-F0-9]+,\\s*Qgrp\\s*ID:0x[a-fA-F0-9]+\\s*\\(name:"[a-zA-Z0-9]+"\\)
...    !!!\\s*Restarting\\s*test\\s*!!!
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}

*** Test Cases ***
Test Queue Group
    [Documentation]    queue_group -c ${core_mask} -${mode}
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
