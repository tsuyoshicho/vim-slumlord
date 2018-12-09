" PlantUML Live Preview for ascii/unicode art
" @Author: Martin Grenfell <martin.grenfell@gmail.com>
" @Date: 2018-12-07 13:00:22
" @Last Modified by: Tsuyoshi CHO <Tsuyoshi.CHO@Gmail.com>
" @Last Modified time: 2018-12-08 23:04:10
" @License: WTFPL
" PlantUML preview plugin InPlace Updater

" Intro  {{{1
scriptencoding utf-8

" Vital
let s:Writer = vital#slumlord#import('Vim.Buffer.Writer')

" InPlaceUpdater object {{{1
let s:InPlaceUpdater = {}
let s:InPlaceUpdater.divider = "@startuml"

function! slumlord#InPlaceUpdater#new() abort
  return deepcopy(s:InPlaceUpdater)
endfunction

function! s:InPlaceUpdater.update(args) abort dict
    let startLine = line(".")
    let lastLine = line("$")
    let startCol = col(".")

    call self.__deletePreviousDiagram()
    call self.__insertDiagram(b:slumlord_preview_fname)
    let title = slumlord#util#getTitle()
    call slumlord#util#addTitle(title)

    " restore cursor
    call cursor(line("$") - (lastLine - startLine), startCol)

    if a:args['write']
        noautocmd write
    endif
endfunction

function! s:InPlaceUpdater.__deletePreviousDiagram() abort dict
    if self.__dividerLnum() > 1
      call s:Writer.replace('%', 0, (self.__dividerLnum() - 1), [])
    endif
endfunction

function! s:InPlaceUpdater.__insertDiagram(fname) abort dict
    " inert 2 line at top
    call s:Writer.replace('%', 0, 0, [''])
    call s:Writer.replace('%', 0, 0, [''])

    " write start at top
    call cursor(1,1)

    call slumlord#util#readWithoutStoringAsAltFile(a:fname)

    "fix trailing whitespace
    exec '1,' . self.__dividerLnum() . 's/\s\+$//e'

    call slumlord#util#removeLeadingWhitespace()
endfunction

function! s:InPlaceUpdater.__dividerLnum() abort dict
    return search(self.divider, 'wn')
endfunction

" vim:set fdm=marker:
