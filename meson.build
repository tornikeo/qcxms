# This file is part of QCxMS.

project(
  'qcxms',
  'fortran',
  version: '5.2.0',
  license: 'LGPL-3.0-or-later',
  meson_version: '>=0.55',
  default_options: [
    'buildtype=debugoptimized',
    # 'default_library=static',
  ],
)


install = not (meson.is_subproject() and get_option('default_library') == 'static')

# General configuration information
exe_deps = []
subdir('config')

srcs = []
prog = []
# Collect sources
subdir('src')

# Create library target
qcxms_lib = library(
  meson.project_name(),
  sources: srcs,
  dependencies: exe_deps,
  include_directories: include_directories('include'),
)

# Export as dependency
qcxms_inc = qcxms_lib.private_dir_include()
qcxms_dep = declare_dependency(
  link_with: qcxms_lib,
  include_directories: qcxms_inc,
  dependencies: exe_deps,
)

# Create executable target
qcxms_exe = executable(
  meson.project_name(),
  sources: prog,
  dependencies: qcxms_dep,
  install: install,
  # link_args: ['-pg','-lgcov'],
  link_language: 'fortran',
)

if install
  install_data(
    files(
      'bin/pqcxms',
      'bin/q-batch',
      'bin/getres',
    ),
    install_mode: 'rwxr-xr-x',
    install_dir: get_option('bindir'),
  )
endif

# Test qcxms in one of the directories
test('check', 
  qcxms_exe, 
  args: ['--prod'],
  suite: 'qcxms', 
  # timeout: 10,
  workdir : meson.source_root() + '/tests/ei_sample_trajectory/TMPQCXMS/TMP.1'
)
