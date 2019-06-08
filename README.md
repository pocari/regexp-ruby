# regexp test

# setup

```
git clone git@github.com:pocari/regexp-ruby.git
cd regexp-ruby.git
bundle install --path=vendor/bundle
```
# test

```
bundle exec rspec
```


# sample(ast, opcodes)

```
bundle exec ruby main.rb
[:pattern, "a*b"]
[:ast, [(* a) b]]
:ir
0 [:push, 2]
1 [:char, "a"]
2 [:jump, -3]
3 [:char, "b"]
4 [:match, nil]
[:match, "b", "matched"]
[:match, "ab", "matched"]
[:match, "aab", "matched"]
[:match, "cb", "unmatched"]

[:pattern, "a+b"]
[:ast, [(+ a) b]]
:ir
0 [:char, "a"]
1 [:push, 1]
2 [:jump, -3]
3 [:char, "b"]
4 [:match, nil]
[:match, "b", "unmatched"]
[:match, "ab", "matched"]
[:match, "aab", "matched"]
[:match, "cb", "unmatched"]

[:pattern, "abc|def"]
[:ast, (B [a b c] [d e f])]
:ir
0 [:push, 4]
1 [:char, "a"]
2 [:char, "b"]
3 [:char, "c"]
4 [:jump, 3]
5 [:char, "d"]
6 [:char, "e"]
7 [:char, "f"]
8 [:match, nil]
[:match, "abc", "matched"]
[:match, "def", "matched"]
[:match, "aef", "unmatched"]

[:pattern, "((ab)+|(cd)+)ef"]
[:ast, [(B (+ [a b]) (+ [c d])) e f]]
:ir
0 [:push, 5]
1 [:char, "a"]
2 [:char, "b"]
3 [:push, 1]
4 [:jump, -4]
5 [:jump, 4]
6 [:char, "c"]
7 [:char, "d"]
8 [:push, 1]
9 [:jump, -4]
10 [:char, "e"]
11 [:char, "f"]
12 [:match, nil]
[:match, "abef", "matched"]
[:match, "cdef", "matched"]
[:match, "ababef", "matched"]
[:match, "cdcdef", "matched"]
[:match, "ababxef", "unmatched"]
[:match, "abcdef", "unmatched"]
`e`
