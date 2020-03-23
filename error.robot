*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EM\\s*ERROR:0x[a-fA-Z0-9]+\\s*ESCOPE:0x[a-fA-Z0-9]+\\s*EO:0x[a-fA-Z0-9]+-"EO\\s*[A-fA-F]+"
...    core:[0-9]+\\s*ecount:[0-9]+\\([0-9]+\\)\\s*event_machine_event.c:[0-9]+\\s*em_free\\(\\)
...    Error\\s*log\\s*from\\s*EO\\s*[a-fA-Z]+\\s*\\[[0-9]+\\]\\s*on\\s*core\\s*[0-9]+!
...    Appl\\s*EO\\s*specific\\s*error\\s*handler:\\s*EO\\s*0x[0-9]+\\s*error\\s*0x[a-fA-Z0-9]+\\s*escope\\s*0x[a-fA-Z0-9]+
...    Done\\s*-\\s*exit

@{do_not_match} =
...    NO ERROR

*** Test Cases ***
Test Error
    [Documentation]    error -c ${core_mask} -${mode}
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
