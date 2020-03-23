*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    normal atomic processing:\\s*[0-9]+\\s*cycles/event\\s*events/s:[0-9]+\\.[0-9]+\\s*M\\s*@[0-9]+\\.[0-9]+\\s*MHz\\s*\\(core-[0-9]+\\s*[0-9]+\\)
...    em_atomic_processing_end\\(\\):\\s*[0-9]+\\s*cycles/event\\s*events/s:[0-9]+\\.[0-9]+\\s*M\\s*@[0-9]+.[0-9]+\\s*MHz\\s*\\(core-[0-9]+\\s*[0-9]+\\)
...    Done\\s*-\\s*exit

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Atomic Processing End
    [Documentation]    atomic_processing_end -c ${core_mask} -${mode}
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    30s

    Send Signal To Process    SIGINT    app    group=true
    ${output} =    Wait For Process    app    timeout=5s    on_timeout=kill
    Log    ${output.stdout}    console=yes
    Process Should Be Stopped    app
    Should Be Equal As Integers    ${output.rc}   -2    Return Code: ${output.rc}

    :FOR    ${line}    IN    @{match}
    \    Should Match Regexp    ${output.stdout}    ${line}
    :FOR    ${line}    IN    @{do_not_match}
    \    Should Not Match Regexp    ${output.stdout}    ${line}
