*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Start\\s*event\\s*group
...    Event\\s*group\\s*notification\\s*event\\s*received\\s*after\\s*[1-9]+[0-9]*\\s*data\\s*events\\.
...    Cycles\\s*curr:[1-9]+[0-9]*,\\s*ave:[0-9]+
...    Chained\\s*event\\s*group\\s*done
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}

*** Test Cases ***
Test Event Group Chaining
    [Documentation]    event_group_chaining -c ${core_mask} -${mode}
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
