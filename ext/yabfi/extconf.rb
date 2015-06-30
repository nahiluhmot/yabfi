require 'mkmf'

%w(calloc malloc memset free).each do |func|
  abort "missing #{func}()" unless have_func(func)
end

create_makefile 'yabfi/vm'
