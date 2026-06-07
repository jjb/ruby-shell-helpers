
# todo: mirror -euxo pipefail features, replicate behavior within each helper

# no weird behavior if using heredocs
# todo: document what the weird behavior is
# todo: use refinements to just replace top-level `system`
def script(body)
  system(body.strip)
end

# just allows heredocs to be used with backtics
# think of it as "capture1" that pairs with Open3's methods https://docs.ruby-lang.org/en/master/Open3.html
def capture(body)
  `#{body.strip}`
  # `#{<<~SCRIPT}`
  #   echo 123
  # SCRIPT
end

