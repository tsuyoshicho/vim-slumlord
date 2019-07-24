" PlantUML Live Preview for ascii/unicode art
" @Author: Martin Grenfell <martin.grenfell@gmail.com>
" @Date: 2018-12-07 13:00:22
" @Last Modified by: Tsuyoshi CHO <Tsuyoshi.CHO@Gmail.com>
" @Last Modified time: 2019-07-24 12:21:38
" @License: WTFPL
" PlantUML preview plugin NeoVim Float Window Updater

" WIP!! copy from WinUpdater.vim

" Intro  {{{1
scriptencoding utf-8

" WinUpdater object {{{1
let s:WinUpdater = {}

" Vital
let s:Opener = vital#slumlord#import('Vim.Buffer.Opener')
let s:Writer = vital#slumlord#import('Vim.Buffer.Writer')

function! slumlord#FloatUpdater#new() abort
  return deepcopy(s:WinUpdater)
endfunction

function! s:WinUpdater.update(args) abort dict
    let fname = b:slumlord_preview_fname
    let title = slumlord#util#getTitle()
    let context = self.__moveToWin()

    " remove all old content
    call s:Writer.replace('%', 0, -1, [])

    " inert 2 line at top
    call s:Writer.replace('%', 0, 0, [''])
    call s:Writer.replace('%', 0, 0, [''])

    " write start at top
    call cursor(1,1)

    call slumlord#util#readWithoutStoringAsAltFile(fname)

    "fix trailing whitespace
    %s/\s\+$//e

    call slumlord#util#removeLeadingWhitespace()
    call slumlord#util#addTitle(title)

    " all buffer set as preview region
    syn region plantumlPreview start=#\%^# end=#\%$#

    " return old buffer
    call context.end()
endfunction

function s:WinUpdater.__moveToWin() abort dict
    let bufname = printf('slumlord://%s', expand('%:p'))
    let options =  {
          \ "opener" : "pedit",
          \ "force"  : 1,
          \}

    let context = s:Opener.open(bufname, options)

    call self.__setupWinOpts()
    return context
endfunction

function s:WinUpdater.__setupWinOpts() abort dict
    setlocal nowrap
    setlocal buftype=nofile bufhidden=wipe

    " setup preview filetype as plantuml
    set filetype=plantuml
endfunction

" vim:set fdm=marker:
