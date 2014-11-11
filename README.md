This is a Ruby version of [gfx/p5-Data-Validator](https://github.com/gfx/p5-Data-Validator) + [xaicron/p5-Data-Validator-Recursive](https://github.com/xaicron/p5-Data-Validator-Recursive).

Compare below versus https://metacpan.org/pod/Data::Validator

```ruby
rule = Data::Validator.new(
  'uri'        => { isa: String, xor: %w(schema host path_query) },
  'schema'     => { isa: String, default: 'http' },
  'host'       => { isa: String },
  'path_query' => { isa: String, default: '/' },
  'method'     => { isa: String, default: 'GET' },
)

args = rule.validate('uri' => 'http://example.com')
```

and below versus https://metacpan.org/pod/Data::Validator::Recursive

```ruby
# create a new rule
rule = Data::Validator.new(
    'foo' => String,
    'bar' => { isa: Integer },
    'baz' => {
        isa: Hash, # default
        rule: {
            'hoge' => { isa: String, optional: 1 },
            'fuga' => Integer
        },
    },
)

# input data for validation
input = {
    'foo' => 'hoge',
    'bar' => 1192,
    'baz' => {
        'hoge' => 'kamakura',
        'fuga' => 1185,
    },
}

# do validation
params = rule.validate(input) # raises automatically on error
```

#### limitations
- `Data::Validator` is recursive by default.  There is no such thing like a nonrecursive validator.
- `->with('Method')` does not make sense to us, so not supported.
- We do distinguish arrays and hashes unlike perl.  There also are no `->with('Sequenced')`.
- I don't understand the actual needs of `xor`; all examples seems illustravive to me.  Other validators like JSON Schema (cf [zigorou/perl-JSV](https://github.com/zigorou/perl-JSV)) do not have this.  This lack of understanding can negatively impact.
- I don't understand why @gfx thinks it's fast.
