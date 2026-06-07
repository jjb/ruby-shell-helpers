# ruby-shell-helpers

Some helpers to facilitate using ruby as a primary tool for shell scripting. Reach for ruby instead of sh/bash/zsh. Messy collection currently, maybe it will eventually be a gem.

### what this is

simple tools to make it easier to reach for ruby instead of shell. make behavior analogous to shell.

### what this is not

1. to invoke shell commands from a ruby app: https://github.com/thoughtbot/terrapin
2. to manage processes:
   * https://www.rubydoc.info/stdlib/core/Process.spawn
   * https://github.com/enkessler/childprocess

### ideas (copy/pasted from previous scratch note, maybe irrelevant for this project)
* mirror `-euxo pipefail` features, replicate behavior within each helper
* `gem exec` in shebang https://github.com/ruby/rubygems/pull/6309
* option to use at_exit to send error from ruby-shell to stderror of calling script
* when return is non-zero, raise exception, print stderror and stdout
* when return is zero, return stdout 
* send stderror of called program to stderror of ruby process? find out what equivalent behavior would be if a shell script called out to a shell program


### similar/related projects
* https://github.com/albertalef/rubyshell
* https://github.com/ruby/shell
* https://github.com/faraazahmad/shellrb

### info
* https://workingwithruby.com/wwup/intro/
* https://writesoftwarewell.com/call-shell-commands-in-ruby/
* http://tech.natemurray.com/2007/03/ruby-shell-commands.html


### scratch area for previous related harebrained ideas

```ruby
# bash is not guaranteed, sh may be used on some systems, so the `set...` will no work
def `(command)
  r = super("set -euo pipefail && #{command}")
  unless $?.success?
    raise "#{command} command was not successful"
  end
  r
end
```

```ruby
def run_command(command, verbose=false)
  puts command.yellow if verbose
  stdout_r, stdout_w = IO.pipe
  stderr_r, stderr_w = IO.pipe
  pid = Process.spawn(command, out: stdout_w, err: stderr_w)
  @commands[pid] = command
  pid, status = Process.wait2(pid)
  @commands.delete pid
  stdout_w.close
  stderr_w.close
  error = stderr_r.read
  out = stdout_r.read.strip
  stderr_r.close
  stdout_r.close
  raise "#{command} exited with status: #{status}\n#{error}" unless 0 == status
  out
end
```

```ruby
# Ruby + UNIX = runix
#
# If return status is 0, returns standard out.
# If return status is non-0, raises an exception with standard error in the message.
# (None of the other methods you know about have this behavior)

# todo, i don't need open4 for this, switch to open3
require 'open4'

def runix(command)
  standard_error_message=nil
  out=""
  status = Open4::popen4(command) do |p, sin, sout, serr|
    standard_error_message=serr.read
    out = sout.read
  end

  # Open4.popen4 will raise an exception in some non-0 return states, but not all
  unless 0 == status
    raise "The shell command:\n\n#{command}\n\nfailed with status #{status} and this message:\n\n#{standard_error_message}\n\n"
  end
  out
end
```
