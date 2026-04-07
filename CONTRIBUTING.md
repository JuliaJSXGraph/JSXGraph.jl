# Contributing to JSXGraph.jl

Thank you for your interest in contributing to JSXGraph.jl!

## Getting Started

1. Fork and clone the repository
2. Ensure you have Julia 1.10 or later installed
3. Set up the development environment:

```julia
using Pkg
Pkg.develop(path=".")
Pkg.instantiate()
```

## Development Workflow

- Use [conventional commit](https://www.conventionalcommits.org/) format: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Create feature branches with descriptive names (e.g., `feat/add-point-element`)
- Reference related issues in pull requests when applicable

## Running Tests

```julia
using Pkg
Pkg.test("JSXGraph")
```

## Building Documentation

```bash
julia --project=docs -e '
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    Pkg.instantiate()
'
julia --project=docs docs/make.jl
```

Documentation output will be in `docs/build/`.

## Code Formatting

This project uses [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl) with BlueStyle:

```julia
using JuliaFormatter
format(".")
```

Formatting is checked automatically on pull requests.

## Pull Request Process

Before submitting a pull request, ensure:

1. All tests pass (`Pkg.test()`)
2. Documentation builds without warnings
3. Code is formatted with JuliaFormatter
4. `CHANGELOG.md` is updated with notable changes
5. New public functions and types have docstrings
