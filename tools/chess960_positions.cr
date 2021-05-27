def fischer_random_position(n)
  rank = [' '] * 8
  files = Array.new 8, &.itself

  n, b1 = n.divmod 4
  n, b2 = n.divmod 4
  n, qn = n.divmod 6

  rank[b1] = 'B' if b1 = files.delete b1 * 2 + 1
  rank[b2] = 'B' if b2 = files.delete b2 * 2
  rank[qn] = 'Q' if qn = files.delete files[qn]

  n1 = (n * 5 ^ 3) // 15
  n2 = n < 7 ? (n ^ -4) % 5 : n >> 1

  rank[n1] = 'N' if n1 = files.delete files[n1]
  rank[n2] = 'N' if n2 = files.delete files[n2 - 1]

  rank[files.shift] = rank[files.pop] = 'R'
  rank[files.pop] = 'K'
  rank
end

960.times do |n|
  puts fischer_random_position(n).join
end
