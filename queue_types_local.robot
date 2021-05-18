*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Resource    common.robot
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    EO\\s*0x[a-fA-F0-9]+\\s*starting\\s*EO-locq\\s*0x[0-9]+\\s*starting\\s*New\\s*atomic\\s*group:group_[a-zA-Z]+\\s*for\\s*EO:\\s*0x[a-fA-F0-9]+
...    EO-locq\\s*0x[a-fA-F0-9]+\\s*starting\\s*New\\s*atomic\\s*group:group_[a-zA-Z]+\\s*for\\s*EO:\\s*0x[a-fA-F0-9]+
...    EO\\s*0x[a-fA-F0-9]+\\s*starting\\s*EO-locq\\s*0x[a-fA-F0-9]+\\s*starting\\s*EO\\s*0x[a-fA-F0-9]+\\s*starting
...    Core-[0-9]+:\\s*A-L-A-L:\\s*[1-9]+[0-9]*\\s*P-L-P-L:\\s*[1-9]+[0-9]*\\s*PO-L-PO-L:\\s*[1-9]+[0-9]*\\s*P-L-A-L:\\s*[1-9]+[0-9]*\\s*PO-L-A-L:\\s*[1-9]+[0-9]*\\s*PO-L-P-L:\\s*[1-9]+[0-9]*\\s*AG-L-AG-L:\\s*[1-9]+[0-9]*\\s*AG-L-A-L:\\s*[1-9]+[0-9]*\\s*AG-L-P-L:\\s*[1-9]+[0-9]*\\s*AG-L-PO-L:\\s*[1-9]+[0-9]*\\s*cycles/event:[1-9]+[0-9]*\\s*@[1-9]+[0-9]*MHz\\s*[0-9]+

@{do_not_match} =
...    EM ERROR

*** Test Cases ***
Test Queue Types Local
    [Documentation]    queue_types_local -c ${core_mask} -${mode}

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
