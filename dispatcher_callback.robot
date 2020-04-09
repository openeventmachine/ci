*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Dispatcher\\s*enter\\s*callback\\s*[1-2]+\\s*for\\s*EO:\\s*0x[a-fA-F0-9]+\\s*\\(EO\\s*[a-fA-F0-9]+\\)\\s*Queue:\\s*0x[a-fA-F0-9]+\\s*on\\s*core\\s*[0-9]+\\.\\s*Event\\s*seq:\\s*0\\.
...    Dispatcher\\s*enter\\s*callback\\s*[1-2]+\\s*for\\s*EO:\\s*0x[a-fA-F0-9]+\\s*\\(EO\\s*[a-fA-F0-9]+\\)\\s*Queue:\\s*0x[a-fA-F0-9]+\\s*on\\s*core\\s*[0-9]+\\.\\s*Event\\s*seq:\\s*[0-9]+\\.
...    Ping\\s*from\\s*EO\\s*[a-fA-F]+!\\s*Queue:\\s*0x[a-fA-f0-9]+\\s*on\\s*core\\s*[0-9]+\\.\\s*Event\\s*seq:\\s*[0-9]+\\.
...    Ping\\s*from\\s*EO\\s*[a-fA-F]+!\\s*Queue:\\s*0x[a-fA-f0-9]+\\s*on\\s*core\\s*[0-9]+\\.\\s*Event\\s*seq:\\s*[1-9]+\\.
...    Dispatcher\\s*exit\\s*callback\\s*[1-2]+\\s*for\\s*EO:\\s*0x[a-fA-f0-9]+

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}    ${-9}

*** Test Cases ***
Test Dispatcher Callback
    [Documentation]    dispatcher_callback -c ${core_mask} -${mode}
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    25s

    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    List Should Contain Value    ${rc_list}    ${output.rc}    Return Code: ${output.rc}

    :FOR    ${line}    IN    @{match}
    \    Should Match Regexp    ${output.stdout}    ${line}
    :FOR    ${line}    IN    @{do_not_match}
    \    Should Not Match Regexp    ${output.stdout}    ${line}
