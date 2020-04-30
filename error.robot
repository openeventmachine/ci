*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EM\\s*ERROR:0x[a-fA-Z0-9]+\\s*ESCOPE:0x[a-fA-Z0-9]+\\s*EO:0x[a-fA-Z0-9]+-"EO\\s*[A-fA-F]+"
...    core:[0-9]+\\s*ecount:[1-9]+[0-9]*\\([1-9]+[0-9]*\\)\\s*event_machine_event.c:[0-9]+\\s*em_free\\(\\)
...    Error\\s*log\\s*from\\s*EO\\s*[a-fA-Z]+\\s*\\[[0-9]+\\]\\s*on\\s*core\\s*[0-9]+!
...    Appl\\s*EO\\s*specific\\s*error\\s*handler:\\s*EO\\s*0x[a-fA-Z0-9]+\\s*error\\s*0x[a-fA-Z0-9]+\\s*escope\\s*0x[a-fA-Z0-9]+

@{do_not_match} =
...    NO ERROR

*** Test Cases ***
Test Error
    [Documentation]    error -c ${core_mask} -${mode}

    # Run application
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    25s

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
