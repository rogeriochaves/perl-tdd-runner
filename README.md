# Perl TDD Runner

## How to use

```bash
provetdd t/path/to/Test.t
```

You can also add any Perl arguments you need

```bash
provetdd -Ilib t/path/to/Test.t
```

## How to install it from source

First install cpanm and Dist::Zilla

```bash
sudo cpan install App::cpanminus Dist::Zilla
```

If it fails you can force it

```bash
sudo cpan

> force install Dist::Zilla
```

Then you can install it locally

```bash
sudo dzil install
```

## For development

You can run the examples with:

```bash
cd example
perl -Ilib ../lib/Test/Tdd.pm --watch lib t/Test.t
```
