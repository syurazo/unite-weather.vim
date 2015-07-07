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
call unite#util#set_default(
\ 'g:unite_weather_template_file', '')

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

  if strlen(g:unite_weather_template_file) > 0
    let template = readfile(g:unite_weather_template_file)
  else
    let template = s:default_template()
  endif

  call append('$',s:fit_template(template, forecast))

endfunction

function! s:fit_template(template, vars)
  let mark = '{{\([\[\]a-zA-Z0-9.]\+\)}}'
  return map(copy(a:template), "
  \ substitute(v:val, mark,
  \  '\\=exists(''a:vars.'' . submatch(1)) ? eval(''a:vars.'' . submatch(1)) : '''' ', 'g')
  \")
endfunction

function! s:default_template()
    return [
\     "【 {{publisher}} 】",
\     "",
\     "{{title}}",
\     "",
\     "{{description}}",
\     "",
\     "今日の天気",
\     "{{daily.today.description}}",
\     "最高気温 {{daily.today.temperature.max.text}} ／ 最低気温 {{daily.today.temperature.min.text}}",
\     "",
\     "明日の天気",
\     "{{daily.tomorrow.description}}",
\     "最高気温 {{daily.tomorrow.temperature.max.text}} ／ 最低気温 {{daily.tomorrow.temperature.min.text}}",
\     ""
\   ]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

