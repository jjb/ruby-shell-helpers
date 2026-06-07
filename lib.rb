# no weird behavior if using heredocs
# todo: document what the weird behavior is
# todo: detect 1 vs many args
def script(body)
  system(body.strip)
end

# same as above
def exec_stripped(body)
  exec(body.strip)
end

# with one string arg, this is just ```` but allows heredocs
# with one array arg, or multi args, this is ```` in that it returnds stdout and sets $?, but also
# similar to `system` behavior in terms of accepting multiple arguments
# name: think of it as "capture1" that pairs with Open3's methods https://docs.ruby-lang.org/en/master/Open3.html
def capture(*args)
  if args.size == 1 && args[0].is_a?(String)
    `#{args[0].strip}`
  else # mirrors `system` behavior with 1 array arg, or multiple args. mirrors ```` behavior of returning stdout, setting $?
    IO.popen(args, &:read)
  end
end
