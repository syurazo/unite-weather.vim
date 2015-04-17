"=============================================================================
" File    : autoload/unite/sources/weather.vim
" Author  : syurazo <syurazo@gmail.com>
" License : MIT license
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

call unite#util#set_default(
\ 'g:unite_weather_directory', unite#get_data_directory().'/weather')
call unite#util#set_default(
\ 'g:unite_weather_open', 'new')
call unite#util#set_default(
\ 'g:unite_weather_default_provider', 'livedoor')

let s:source = {
\  'name': 'weather',
\ }

function! unite#sources#weather#define()
  return s:source
endfunction

function! s:source.gather_candidates(args,context)

  let provider = get(a:args, 0, g:unite_weather_default_provider)
  let area = get(a:args, 1, '')

  let points = unite#sources#weather#{provider}#get_point_list(area)

  let candidates = []
  for val in points
    if val.level == "city"
      call add(candidates, {
      \ "word":   val.name,
      \ "source": "weather",
      \ "kind":   "command",
      \ "action__command":
      \           "call unite#sources#weather#forecast"
      \          ."('".provider."','".val.id."')"
      \ })
    else
      call add(candidates, {
      \ "word":   "[" . val.name . "]",
      \ "source": "weather",
      \ "kind":   "source",
      \ "action__source_name": "weather",
      \ "action__source_args": [provider, val.id],
      \ })
    endif
  endfor
  return candidates
endfunction

function! unite#sources#weather#name_to_id(provider, name)
  let id = unite#sources#weather#{a:provider}#name_to_id(a:name)
  return id
endfunction

function! unite#sources#weather#forecast(provider, id)

  let forecast = unite#sources#weather#{a:provider}#get_forecast(a:id)
  if forecast == {}
    return
  endif

  silent! execute g:unite_weather_open

  setlocal nobuflisted
  setlocal buftype=nofile noswapfile
  setlocal bufhidden=delete
  setlocal nonumber
  setlocal norelativenumber

  setlocal filetype=weather

  let bufname='[weather:' . a:provider . ':' . forecast.title . ']'
  silent! file `=bufname`

  nnoremap <silent> <buffer> q <C-w>c

  let report = []
  call add(report, "【" . forecast.publisher . "】")
  call add(report, '')
  call add(report, forecast.title)
  call add(report, '')
  call add(report, forecast.descripton)

  for daily in forecast.daily
    call add(report, '')
    call add(report, daily.title . "の天気")
    call add(report, "  " . daily.description)
    for item in daily.parameters
      call add(report, "  " . item.title . " " . item.text)
    endfor
  endfor

  call append('$',report)

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

