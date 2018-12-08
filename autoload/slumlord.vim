" PlantUML Live Preview for ascii/unicode art
" @Author: Martin Grenfell <martin.grenfell@gmail.com>
" @Date: 2018-12-07 13:00:22
" @Last Modified by: Tsuyoshi CHO <Tsuyoshi.CHO@Gmail.com>
" @Last Modified time: 2018-12-08 14:06:32
" @License: WTFPL
" PlantUML preview plugin core

" Intro  {{{1
scriptencoding utf-8

if exists("g:autoloaded_slumlord")
  finish
endif
let g:autoloaded_slumlord = 1

let s:save_cpo = &cpo
set cpo&vim

" variable {{{1
let g:slumlord_plantuml_jar_path = get(g:, 'slumlord_plantuml_jar_path', expand("<sfile>:p:h") . "/../plantuml.jar")
let g:slumlord_asciiart_utf = get(g:, 'slumlord_asciiart_utf', 1)

" function {{{1
function! slumlord#updatePreview(args) abort
    if !slumlord#util#shouldInsertPreview()
        return
    end

    let charset = 'UTF-8'

    let type = 'utxt'
    let ext  = 'utxt'
    if !g:slumlord_asciiart_utf
      let type = 'txt'
      let ext  = 'atxt'
    endif

    let tmpfname = tempname()
    call slumlord#util#mungeDiagramInTmpFile(tmpfname)
    let b:slumlord_preview_fname = fnamemodify(tmpfname,  ':r') . '.' . ext

    let a:args["bufnr"] = bufnr("")

    let cmd = ["java", "-Dapple.awt.UIElement=true", "-splash:", "-jar", g:slumlord_plantuml_jar_path, "-charset", charset, "-t" . type, tmpfname]

    let s:Job = vital#slumlord#import('System.Job')

    if s:Job.is_available()
      let job = s:Job.start(cmd, {
            \ 'stdout': [''],
            \ 'stderr': [''],
            \ 'on_exit': funcref("s:on_exit",[a:args]),
            \})
    else
      call system(join(cmd))
      if v:shell_error == 0
        call s:updater.update(a:args)
      endif
    endif
endfunction

function! s:on_exit(args, exitval) abort
    if bufnr("") != a:args.bufnr
        return 0
    endif

    if a:exitval is# 0
      call s:updater.update(a:args)
    else
      echo "plantuml has error:".a:exitval
    endif
endfunction

" other shit {{{1
if exists("g:slumlord_separate_win") && g:slumlord_separate_win
    let s:updater = slumlord#WinUpdater#new()
else
    let s:updater = slumlord#InPlaceUpdater#new()
endif

" Outro {{{1
let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set fdm=marker:
