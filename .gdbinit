define shape
  printf "Shape: "
  printf "%i ", size($arg0,1)
  set $dim2 = 0
  set $dim3 = 0
  set $dim4 = 0
  set $error = 0
  python
try:
    gdb.execute("set $dim2 = size(" + gdb.string_to_argv('$arg0')[0] + ",2)")
except:
    pass
try:
    gdb.execute("set $dim3 = size(" + gdb.string_to_argv('$arg0')[0] + ",3)")
except:
    pass
try:
    gdb.execute("set $dim4 = size(" + gdb.string_to_argv('$arg0')[0] + ",4)")
except:
    pass
  end
  if $dim2 > 0
    printf "%i ", $dim2
  end
  if $dim3 > 0
    printf "%i ", $dim3
  end
  if $dim4 > 0
    printf "%i", $dim4
  end
  printf "\n"
end
