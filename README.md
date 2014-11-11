This is a Ruby version of [gfx/p5-Data-Validator](https://github.com/gfx/p5-Data-Validator) + [xaicron/p5-Data-Validator-Recursive](https://github.com/xaicron/p5-Data-Validator-Recursive).

Compare below versus https://metacpan.org/pod/Data::Validator

```ruby
rule = Data::Validator.new(
  'uri'        => { isa: String, xor: %w(schema host path_query) },
  'schema'     => { isa: String, default: 'http' },
  'host'       => { isa: String },
  'path_query' => { isa: String, default: '/' },
  'method'     => { isa: String, default: 'GET' },
);

args = rule.validate('uri' => 'http://example.com');
```

and below versus https://metacpan.org/pod/Data::Validator::Recursive

```ruby
# create a new rule
rule = Data::Validator::Recursive.new(
    'foo' => String,
    'bar' => { isa: Integer },
    'baz' => {
        isa: Hash, # default
        rule => {
            'hoge' => { isa: String, optional => 1 },
            'fuga' => Integer
        },
    },
);

# input data for validation
input = {
    'foo' => 'hoge',
    'bar' => 1192,
    'baz' => {
        'hoge' => 'kamakura',
        'fuga' => 1185,
    },
};

# do validation
params = rule.validate(iput) # raises automatically on error
```

#### limitations compared to perl
- `->with('Method')` does not make sense to us, so not supported.
- I don't understand the actual needs of `xor`; all examples seems illustravive to me.  Other validations like JSON Schema (cf [zigorou/perl-JSV](https://github.com/zigorou/perl-JSV)) do not have this.  This can negatively impact.
- I don't understand why @gfx thinks it's fast.
