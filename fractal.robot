*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Started\\s*Pixel\\s*handler\\s*-\\s*EO:0x[a-fA-F0-9]+\\.\\s*Q:0x[a-fA-F0-9]+\\.
...    Started\\s*Worker\\s*-\\s*EO:0x[a-fA-f0-9]+\\.\\s*Q:0x[a-fA-F0-9]+\\.
...    Started\\s*Imager\\s*-\\s*EO:0x[a-fA-f0-9]+\\.\\s*Q:0x[a-fA-f0-9]+\\.
...    Frames\\s*per\\s*second:\\s*[0-9]+\\s*|\\s*frames\\s*[0-9]+\\s*-\\s*[0-9]+
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}

*** Test Cases ***
Test Fractal
    [Documentation]    fractal -c ${core_mask} -${mode}
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
