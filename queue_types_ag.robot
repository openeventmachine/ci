*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Stat\\s*Core-[0-9]+:\\s*Count/PairType\\s*A-A:\\s*[1-9]+[0-9]*\\s*P-P:\\s*[1-9]+[0-9]*\\s*PO-PO:\\s*[1-9]+[0-9]*\\s*P-A:\\s*[1-9]+[0-9]*\\s*PO-A:\\s*[1-9]+[0-9]*\\s*PO-P:\\s*[1-9]+[0-9]*\\s*AG-AG:\\s*[1-9]+[0-9]*\\s*AG-A:\\s*[1-9]+[0-9]*\\s*AG-P:\\s*[1-9]+[0-9]*\\s*AG-PO:\\s*[1-9]+[0-9]*\\s*cycles/event:[1-9]+[0-9]*\\s*@[1-9]+[0-9]*MHz\\s*[0-9]+

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Queue Types AG
    [Documentation]    queue_types_ag -c ${core_mask} -${mode}

    # Run application
    Start Process    ${application} ${SPACE} -c ${SPACE} ${core_mask} ${SPACE} -${mode}    stderr=STDOUT    shell=True    alias=app
    Sleep    60s

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
