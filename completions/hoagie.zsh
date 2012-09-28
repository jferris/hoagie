if [[ ! -o interactive ]]; then
    return
fi

compctl -K _hoagie hoagie

_hoagie() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(hoagie commands)"
  else
    completions="$(hoagie completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
