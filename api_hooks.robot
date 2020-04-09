*** Comments ***
Copyright (c) 2020, Nokia Solutions and Networks. All rights reserved.
SPDX-License-Identifier: BSD-3-Clause

*** Settings ***
Library    Process
Library    Collections
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
@{match} =
...    Dispatch enter callback\\s+EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\)\\s+Queue\:0x[0-9|A-F|a-f]+ on core[0-9]+\\s+Event\:0x[0-9|A-F|a-f]+\\s+Event-seq:[0-9]+
...    EO\-rcv\: Ping from EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\) on core[0-9]+!\\s+Queue\:0x[0-9|A-F|a-f]+\\s+Event\:0x[0-9|A-F|a-f]+\\s+Event\-seq\:[0-9]+
...    EO\-rcv\: Ping from EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\) on core[0-9]+!\\s+Queue\:0x[0-9|A-F|a-f]+\\s+Event\:0x[0-9|A-F|a-f]+\\s+Event\-seq\:[1-9]+
...    Alloc-hook\\s+EO\:\'EO [AB]'\\(0x[0-9|A-F|a-f]+\\)\\s+sz\:[0-9]+\\s+type\:0x[0-9|A-F|a-f]+\\s+pool\:0x[0-9|A-F|a-f]+\\s+Event\:0x[0-9|A-F|a-f]+
...    Free-hook\\s+EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\)\\s+Event\:0x[0-9|A-F|a-f]+
...    Send-hook\\s+EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\)\\s+[1-9]+\\s+event\\(s\\)\\s+Queue\:0x[0-9|A-F|a-f]+\\s+\=\=\>\\s+0x[0-9|A-F|a-f]+\\s+Event\:0x[0-9|A-F|a-f]+
...    Dispatch exit callback\\s+EO\:\'EO [AB]\'\\(0x[0-9|A-F|a-f]+\\)

@{do_not_match} =
...    EM ERROR

@{rc_list} =    ${0}    ${-2}    ${-9}

*** Test Cases ***
Test API Hooks
    [Documentation]    api-hooks -c ${core_mask} -${mode}
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
