" PlantUML Live Preview for ascii/unicode art
" @Author: Martin Grenfell <martin.grenfell@gmail.com>
" @Date: 2018-12-07 13:00:22
" @Last Modified by: Tsuyoshi CHO <Tsuyoshi.CHO@Gmail.com>
" @Last Modified time: 2018-12-08 23:02:11
" @License: WTFPL
" PlantUML preview plugin util

" Intro  {{{1
scriptencoding utf-8

" function {{{1
function! slumlord#util#shouldInsertPreview() abort
    "check for 'no-preview flag
    if search('^\s*''no-preview', 'wn') > 0
        return
    endif

    "check for state diagram
    if search('^\s*\[\*\]', 'wn') > 0
        return
    endif

    "check for use cases
    if search('^\s*\%((.*)\|:.*:\)', 'wn') > 0
        return
    endif

    "check for class diagrams
    if search('^\s*class\>', 'wn') > 0
        return
    endif

    "check for activity diagrams
    if search('^\s*:.*;', 'wn') > 0
        return
    endif

    return 1
endfunction

function! slumlord#util#readWithoutStoringAsAltFile(fname) abort
    let oldcpoptions = &cpoptions
    set cpoptions-=a
    exec 'read' a:fname
    let &cpoptions = oldcpoptions
endfunction

function! slumlord#util#mungeDiagramInTmpFile(fname) abort
    call writefile(getline(1, '$'), a:fname)
    call slumlord#util#convertNonAsciiSupportedSyntax(a:fname)
endfunction

function! slumlord#util#convertNonAsciiSupportedSyntax(fname) abort
    exec 'sp' a:fname

    " write start top
    call cursor(1,1)

    /@startuml/,/@enduml/s/^\s*\(boundary\|database\|entity\|control\)/participant/e
    /@startuml/,/@enduml/s/^\s*\(end \)\?\zsref\>/note/e
    /@startuml/,/@enduml/s/^\s*ref\>/note/e
    /@startuml/,/@enduml/s/|||/||4||/e
    /@startuml/,/@enduml/s/\.\.\.\([^.]*\)\.\.\./==\1==/e
    write

    bwipe!
endfunction

function! slumlord#util#removeLeadingWhitespace(...) abort
    let opts = a:0 ? a:1 : {}

    let diagramEnd = get(opts, 'diagramEnd', line('$'))

    let smallestLead = 100

    for i in range(1, diagramEnd-1)
        let lead = match(getline(i), '\S')
        if lead >= 0 && lead < smallestLead
            let smallestLead = lead
        endif
    endfor

    exec '1,' . diagramEnd . 's/^ \{'.smallestLead.'}//e'
endfunction

function! slumlord#util#getTitle() abort
    let lnum = search('^title ', 'n')
    if !lnum
        return ''
    endif

    let title = substitute(getline(lnum), '^title \(.*\)', '\1', '')
    return title
endfunction

function! slumlord#util#addTitle(title) abort
  if a:title !=# ''
    call append(0, "")
    call append(0, repeat("^", strdisplaywidth(a:title)+6))
    call append(0, "   " . a:title)
  endif
endfunction

" vim:set fdm=marker:
